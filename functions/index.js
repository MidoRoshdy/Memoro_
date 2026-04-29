const crypto = require("crypto");
const admin = require("firebase-admin");
const {
  onDocumentCreated,
  onDocumentUpdated,
  onDocumentWritten,
} = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { logger } = require("firebase-functions");

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

const NOTIFICATION_STATUS = {
  QUEUED: "queued",
  SENT: "sent",
  FAILED: "failed",
};

function notificationId(parts) {
  const input = parts.join("|");
  return crypto.createHash("sha1").update(input).digest("hex");
}

async function getActiveTokens(uid) {
  const paths = [
    db.collection("users").doc(uid).collection("devices"),
    db
      .collection("users")
      .doc("patients")
      .collection("users")
      .doc(uid)
      .collection("devices"),
    db.collection("careGiver").doc(uid).collection("devices"),
  ];

  const uniqueByToken = new Map();
  for (const ref of paths) {
    const snap = await ref.where("isActive", "==", true).get();
    for (const doc of snap.docs) {
      const token = (doc.data().fcmToken || "").trim();
      if (!token) continue;
      if (!uniqueByToken.has(token)) {
        uniqueByToken.set(token, {
          deviceId: doc.id,
          token,
          collectionPath: ref.path,
        });
      }
    }
  }
  return Array.from(uniqueByToken.values());
}

async function markInvalidTokens(uid, invalidDevices) {
  if (!invalidDevices.length) return;
  const batch = db.batch();
  for (const item of invalidDevices) {
    const deviceId = item.deviceId;
    const collectionPath = item.collectionPath || `users/${uid}/devices`;
    batch.set(
      db.doc(`${collectionPath}/${deviceId}`),
      {
        isActive: false,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  }
  await batch.commit();
}

async function writeInbox(recipientUid, payload, sendResult) {
  const id =
    payload.notificationId ||
    notificationId([
      payload.type || "general",
      payload.entityId || "",
      recipientUid,
      `${payload.payloadVersion || 1}`,
    ]);
  const ref = db
    .collection("users")
    .doc(recipientUid)
    .collection("notifications")
    .doc(id);
  await ref.set(
    {
      notificationId: id,
      type: payload.type || "general",
      title: payload.title || "Memoro",
      body: payload.body || "",
      priority: payload.priority || "normal",
      recipientUid,
      actorUid: payload.actorUid || "",
      pairId: payload.pairId || "",
      entityId: payload.entityId || "",
      deepLink: payload.deepLink || "",
      payloadVersion: payload.payloadVersion || 1,
      data: payload.data || {},
      status: sendResult.ok
        ? NOTIFICATION_STATUS.SENT
        : NOTIFICATION_STATUS.FAILED,
      retryCount: sendResult.retryCount || 0,
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      errorCode: sendResult.errorCode || "",
    },
    { merge: true },
  );
}

async function sendPushToUser(payload) {
  const recipientUid = (payload.recipientUid || "").trim();
  if (!recipientUid) return { ok: false, errorCode: "missing-recipient" };

  const deviceTokens = await getActiveTokens(recipientUid);
  if (!deviceTokens.length) {
    await writeInbox(recipientUid, payload, {
      ok: false,
      errorCode: "no-device-token",
    });
    return { ok: false, errorCode: "no-device-token" };
  }

  const tokens = deviceTokens.map((d) => d.token);
  const message = {
    tokens,
    notification: {
      title: payload.title || "Memoro",
      body: payload.body || "",
    },
    android: {
      priority: payload.priority === "high" ? "high" : "normal",
      notification: {
        channelId: resolveAndroidChannelId(payload.type),
      },
    },
    apns: {
      headers: {
        "apns-priority": payload.priority === "high" ? "10" : "5",
      },
    },
    data: {
      type: payload.type || "general",
      recipientUid,
      pairId: payload.pairId || "",
      entityId: payload.entityId || "",
      route: payload.route || "",
      argsJson: JSON.stringify(payload.data || {}),
      notificationId: payload.notificationId || "",
      priority: payload.priority || "normal",
      sentAtIso: new Date().toISOString(),
    },
  };

  const res = await messaging.sendEachForMulticast(message);
  const invalidDevices = [];
  res.responses.forEach((r, idx) => {
    if (!r.success) {
      const code = r.error?.code || "";
      if (
        code.includes("invalid-registration-token") ||
        code.includes("registration-token-not-registered")
      ) {
        invalidDevices.push(deviceTokens[idx]);
      }
    }
  });
  await markInvalidTokens(recipientUid, invalidDevices);

  const ok = res.successCount > 0;
  const errorCode = ok
    ? ""
    : res.responses[0]?.error?.code || "fcm-send-failed";
  await writeInbox(recipientUid, payload, { ok, errorCode });
  return { ok, errorCode };
}

function parsePair(docData) {
  const doctorUid = (docData.doctorUid || "").trim();
  const patientUid = (docData.patientUid || "").trim();
  return { doctorUid, patientUid };
}

function resolveAndroidChannelId(type) {
  if (type === "help_request") return "emergency_alerts";
  if (type === "help_request_resolved") return "emergency_alerts";
  if (
    type === "medication_added" ||
    type === "medication_taken" ||
    type === "medication_reminder"
  ) {
    return "medication_reminders";
  }
  return "activity_reminders";
}

exports.onActivityCreated = onDocumentCreated(
  "activity/{pairId}/items/{itemId}",
  async (event) => {
    const pairId = event.params.pairId;
    const itemId = event.params.itemId;
    const item = event.data?.data();
    if (!item) return;

    const parent = await db.collection("activity").doc(pairId).get();
    const pairData = parent.data() || {};
    const { patientUid, doctorUid } = parsePair(pairData);
    if (!patientUid || !doctorUid) return;

    await sendPushToUser({
      notificationId: notificationId([
        "activity_assigned",
        pairId,
        itemId,
        patientUid,
      ]),
      type: "activity_assigned",
      priority: "normal",
      recipientUid: patientUid,
      actorUid: doctorUid,
      pairId,
      entityId: itemId,
      route: "doctor/activity/details",
      deepLink: `memoro://doctor/activity/details?pairId=${pairId}&itemId=${itemId}`,
      title: "New activity assigned",
      body: item.title || "Your therapist assigned a new activity",
      data: {
        doctorUid,
        patientUid,
        patientName: item.patientName || "",
      },
    });
  },
);

exports.onActivityCompleted = onDocumentUpdated(
  "activity/{pairId}/items/{itemId}",
  async (event) => {
    const before = event.data?.before?.data() || {};
    const after = event.data?.after?.data() || {};
    if (
      (before.status || "") === "completed" ||
      (after.status || "") !== "completed"
    ) {
      return;
    }
    const pairId = event.params.pairId;
    const itemId = event.params.itemId;
    const parent = await db.collection("activity").doc(pairId).get();
    const pairData = parent.data() || {};
    const { patientUid, doctorUid } = parsePair(pairData);
    if (!patientUid || !doctorUid) return;

    await sendPushToUser({
      notificationId: notificationId([
        "activity_done",
        pairId,
        itemId,
        doctorUid,
      ]),
      type: "activity_done",
      priority: "normal",
      recipientUid: doctorUid,
      actorUid: patientUid,
      pairId,
      entityId: itemId,
      route: "doctor/activity/details",
      deepLink: `memoro://doctor/activity/details?pairId=${pairId}&itemId=${itemId}`,
      title: "Activity completed",
      body: after.title || "Patient marked an activity as done",
      data: { doctorUid, patientUid },
    });
  },
);

exports.onEmergencyRequestActive = onDocumentWritten(
  "emergencyRequests/{pairId}",
  async (event) => {
    const after = event.data?.after?.data() || {};
    const wasDeleted = !event.data?.after?.exists;
    if (wasDeleted) return;
    const hasRequest = after.hasRequest === true || after.isActive === true;
    if (!hasRequest) return;

    const pairId = event.params.pairId;
    const doctorUid = (after.doctorUid || "").trim();
    const patientUid = (after.patientUid || "").trim();
    if (!doctorUid || !patientUid) return;

    const latitude =
      typeof after.latitude === "number"
        ? after.latitude
        : Number.parseFloat(after.latitude);
    const longitude =
      typeof after.longitude === "number"
        ? after.longitude
        : Number.parseFloat(after.longitude);
    const hasCoords = Number.isFinite(latitude) && Number.isFinite(longitude);
    const mapsUrl = (after.mapsUrl || "").toString().trim();
    const locationText = (after.locationText || "").toString().trim();

    await sendPushToUser({
      notificationId: notificationId([
        "help_request",
        pairId,
        `${after.requestedAt || ""}`,
        doctorUid,
      ]),
      type: "help_request",
      priority: "high",
      recipientUid: doctorUid,
      actorUid: patientUid,
      pairId,
      entityId: pairId,
      route: "doctor/home",
      deepLink: `memoro://doctor/home?pairId=${pairId}&section=emergency`,
      title: "Emergency help request",
      body: after.patientName
        ? `${after.patientName} needs help now`
        : "Patient needs help now",
      data: {
        doctorUid,
        patientUid,
        ...(hasCoords ? { latitude: String(latitude), longitude: String(longitude) } : {}),
        ...(mapsUrl ? { mapsUrl } : {}),
        ...(locationText ? { locationText } : {}),
      },
    });
  },
);

exports.onEmergencyRequestResolved = onDocumentUpdated(
  "emergencyRequests/{pairId}",
  async (event) => {
    const before = event.data?.before?.data() || {};
    const after = event.data?.after?.data() || {};
    const pairId = event.params.pairId;

    const wasResolved =
      (before.requestStatus || "").toString().trim() === "resolved" ||
      before.hasRequest === false ||
      before.isActive === false;
    const isResolved =
      (after.requestStatus || "").toString().trim() === "resolved" ||
      after.hasRequest === false ||
      after.isActive === false;
    if (wasResolved || !isResolved) return;

    const doctorUid = (after.doctorUid || "").trim();
    const patientUid = (after.patientUid || "").trim();
    if (!doctorUid || !patientUid) return;

    await sendPushToUser({
      notificationId: notificationId([
        "help_request_resolved",
        pairId,
        patientUid,
        `${after.resolvedAt || ""}`,
      ]),
      type: "help_request_resolved",
      priority: "normal",
      recipientUid: patientUid,
      actorUid: doctorUid,
      pairId,
      entityId: pairId,
      route: "sos",
      deepLink: `memoro://sos?pairId=${pairId}&status=resolved`,
      title: "SOS request resolved",
      body: "Your caregiver marked your emergency request as resolved",
      data: {
        doctorUid,
        patientUid,
        requestStatus: (after.requestStatus || "").toString().trim(),
        resolvedBy: (after.resolvedBy || "").toString().trim(),
      },
    });
  },
);

exports.onChatMessageCreated = onDocumentCreated(
  "chats/{chatId}/messages/{messageId}",
  async (event) => {
    const chatId = event.params.chatId;
    const messageId = event.params.messageId;
    const message = event.data?.data() || {};
    const senderId = (message.senderId || "").trim();
    const text = (message.text || "").trim();
    if (!senderId) return;

    const chatSnap = await db.collection("chats").doc(chatId).get();
    const chatData = chatSnap.data() || {};
    const participants = Array.isArray(chatData.participantIds)
      ? chatData.participantIds
      : [];
    const recipientUid =
      participants
        .map((id) => (typeof id === "string" ? id.trim() : ""))
        .find((id) => id && id !== senderId) || "";
    if (!recipientUid) return;

    const senderIsDoctor = (chatData.doctorId || "").trim() === senderId;
    const senderName = senderIsDoctor
      ? (chatData.doctorName || "").trim() || "Caregiver"
      : (chatData.patientName || "").trim() || "Patient";

    await sendPushToUser({
      notificationId: notificationId([
        "chat_message",
        chatId,
        messageId,
        recipientUid,
      ]),
      type: "chat_message",
      priority: "normal",
      recipientUid,
      actorUid: senderId,
      pairId: chatId,
      entityId: messageId,
      route: "chat",
      deepLink: `memoro://chat?chatId=${chatId}`,
      title: senderName,
      body: text || "New message",
      data: {
        chatId,
        currentUserId: recipientUid,
        title: senderName,
        avatarUrl: senderIsDoctor
          ? (chatData.doctorImageUrl || "").trim()
          : (chatData.patientImageUrl || "").trim(),
        doctorUid: (chatData.doctorId || "").trim(),
        patientUid: (chatData.patientUid || "").trim(),
      },
    });
  },
);

exports.onMedicineCreated = onDocumentCreated(
  "medicine/{pairId}/items/{itemId}",
  async (event) => {
    const pairId = event.params.pairId;
    const itemId = event.params.itemId;
    const item = event.data?.data() || {};
    const parent = await db.collection("medicine").doc(pairId).get();
    const pairData = parent.data() || {};
    const { patientUid, doctorUid } = parsePair(pairData);
    if (!patientUid || !doctorUid) return;

    await sendPushToUser({
      notificationId: notificationId([
        "medication_added",
        pairId,
        itemId,
        patientUid,
      ]),
      type: "medication_added",
      priority: "normal",
      recipientUid: patientUid,
      actorUid: doctorUid,
      pairId,
      entityId: itemId,
      route: "medicine",
      deepLink: `memoro://medicine?pairId=${pairId}&itemId=${itemId}`,
      title: "New medicine added",
      body: item.name
        ? `${item.name} was added to your plan`
        : "A new medicine was added",
      data: {
        doctorUid,
        patientUid,
        medicineName: (item.name || "").trim(),
        frequency: (item.frequency || "").trim(),
      },
    });
  },
);

exports.onMedicineTaken = onDocumentUpdated(
  "medicine/{pairId}/items/{itemId}",
  async (event) => {
    const before = event.data?.before?.data() || {};
    const after = event.data?.after?.data() || {};
    if ((before.status || "") === "taken" || (after.status || "") !== "taken") {
      return;
    }

    const pairId = event.params.pairId;
    const itemId = event.params.itemId;
    const parent = await db.collection("medicine").doc(pairId).get();
    const pairData = parent.data() || {};
    const { patientUid, doctorUid } = parsePair(pairData);
    if (!patientUid || !doctorUid) return;

    await sendPushToUser({
      notificationId: notificationId([
        "medication_taken",
        pairId,
        itemId,
        doctorUid,
        `${after.updatedAt || ""}`,
      ]),
      type: "medication_taken",
      priority: "normal",
      recipientUid: doctorUid,
      actorUid: patientUid,
      pairId,
      entityId: itemId,
      route: "doctor/medicine/details",
      deepLink: `memoro://doctor/medicine/details?pairId=${pairId}&itemId=${itemId}`,
      title: "Medicine taken",
      body: after.name
        ? `${after.name} marked as taken`
        : "Patient marked medicine as taken",
      data: {
        doctorUid,
        patientUid,
        medicineName: (after.name || "").trim(),
        verifiedBy: (after.lastDoseVerifiedBy || "").trim(),
      },
    });
  },
);

exports.retryFailedNotifications = onSchedule("every 10 minutes", async () => {
  const maxRetries = 3;
  const usersSnap = await db.collection("users").get();
  for (const userDoc of usersSnap.docs) {
    const uid = userDoc.id;
    const failedSnap = await db
      .collection("users")
      .doc(uid)
      .collection("notifications")
      .where("status", "==", NOTIFICATION_STATUS.FAILED)
      .where("retryCount", "<", maxRetries)
      .limit(20)
      .get();
    for (const notifDoc of failedSnap.docs) {
      const payload = notifDoc.data();
      const result = await sendPushToUser({
        ...payload,
        recipientUid: uid,
      });
      await notifDoc.ref.set(
        {
          retryCount: (payload.retryCount || 0) + 1,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          lastRetryAt: admin.firestore.FieldValue.serverTimestamp(),
          status: result.ok
            ? NOTIFICATION_STATUS.SENT
            : NOTIFICATION_STATUS.FAILED,
          errorCode: result.errorCode || "",
        },
        { merge: true },
      );
    }
  }
  logger.info("retryFailedNotifications completed");
});
