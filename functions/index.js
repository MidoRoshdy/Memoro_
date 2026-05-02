const crypto = require("crypto");
const admin = require("firebase-admin");
const {
  onDocumentCreated,
  onDocumentUpdated,
  onDocumentWritten,
} = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const { logger } = require("firebase-functions");
const nodemailer = require("nodemailer");

const SMTP_EMAIL = defineSecret("SMTP_EMAIL");
const SMTP_PASSWORD = defineSecret("SMTP_PASSWORD");
const SMTP_FROM_NAME = defineSecret("SMTP_FROM_NAME");

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
        ...(hasCoords
          ? { latitude: String(latitude), longitude: String(longitude) }
          : {}),
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

const PASSWORD_RESET_OTPS = "passwordResetOtps";
const OTP_TTL_MINUTES = 10;
const OTP_MAX_ATTEMPTS = 5;
const OTP_RESEND_COOLDOWN_SECONDS = 30;

function normalizeEmail(raw) {
  return (raw || "").toString().trim().toLowerCase();
}

function generateOtpCode() {
  // Cryptographically random 6-digit code, padded if leading zeros.
  const value = crypto.randomInt(0, 1_000_000);
  return value.toString().padStart(6, "0");
}

function hashOtp(code, salt) {
  return crypto.createHash("sha256").update(`${salt}:${code}`).digest("hex");
}

async function findAuthUserByEmail(email) {
  try {
    return await admin.auth().getUserByEmail(email);
  } catch (err) {
    if (err && err.code === "auth/user-not-found") return null;
    throw err;
  }
}

async function findProfileRoleByUid(uid) {
  try {
    const caregiver = await db.collection("careGiver").doc(uid).get();
    if (caregiver.exists) return "caregiver";
  } catch (_) {}
  try {
    const patient = await db
      .collection("users")
      .doc("patients")
      .collection("users")
      .doc(uid)
      .get();
    if (patient.exists) return "patient";
  } catch (_) {}
  try {
    const legacyPatient = await db.collection("patients").doc(uid).get();
    if (legacyPatient.exists) return "patient";
  } catch (_) {}
  return "unknown";
}

function buildOtpEmail({ code, displayName }) {
  const greeting = displayName ? `Hi ${displayName},` : "Hi,";
  const text = [
    greeting,
    "",
    `Your Memoro password reset code is: ${code}`,
    "",
    `This code expires in ${OTP_TTL_MINUTES} minutes.`,
    "If you did not request this, you can ignore this email.",
    "",
    "— Memoro",
  ].join("\n");
  const html = `
    <div style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;color:#1f2937;max-width:480px;margin:0 auto;padding:24px;">
      <h2 style="color:#0f766e;margin:0 0 16px;">Memoro password reset</h2>
      <p style="margin:0 0 16px;">${greeting}</p>
      <p style="margin:0 0 12px;">Use the code below to reset your Memoro password:</p>
      <div style="font-size:32px;font-weight:800;letter-spacing:8px;background:#f0fdfa;color:#0f766e;border:1px solid #99f6e4;border-radius:12px;padding:16px;text-align:center;margin:16px 0;">
        ${code}
      </div>
      <p style="margin:0 0 8px;color:#4b5563;">This code expires in <strong>${OTP_TTL_MINUTES} minutes</strong>.</p>
      <p style="margin:0;color:#9ca3af;font-size:13px;">If you didn't request this, you can safely ignore this email.</p>
    </div>
  `;
  return { text, html };
}

function createTransport() {
  const user = SMTP_EMAIL.value();
  const pass = SMTP_PASSWORD.value();
  if (!user || !pass) {
    throw new HttpsError(
      "failed-precondition",
      "Email service is not configured. Set the SMTP_EMAIL and SMTP_PASSWORD secrets.",
    );
  }
  return nodemailer.createTransport({
    service: "gmail",
    auth: { user, pass },
  });
}

exports.requestEmailOtp = onCall(
  {
    region: "us-central1",
    secrets: [SMTP_EMAIL, SMTP_PASSWORD, SMTP_FROM_NAME],
  },
  async (request) => {
    const email = normalizeEmail(request.data && request.data.email);
    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      throw new HttpsError("invalid-argument", "A valid email is required.");
    }

    const authUser = await findAuthUserByEmail(email);
    if (!authUser) {
      // Do not leak existence — but we need to fail somewhere meaningful for UX.
      // The client surfaces a generic message either way.
      throw new HttpsError(
        "not-found",
        "No account is registered with this email.",
      );
    }

    const otpRef = db.collection(PASSWORD_RESET_OTPS).doc(email);
    const existingSnap = await otpRef.get();
    const existing = existingSnap.exists ? existingSnap.data() : null;
    if (existing && existing.lastSentAt && existing.lastSentAt.toMillis) {
      const sinceLastSendSec =
        (Date.now() - existing.lastSentAt.toMillis()) / 1000;
      if (sinceLastSendSec < OTP_RESEND_COOLDOWN_SECONDS) {
        const wait = Math.ceil(OTP_RESEND_COOLDOWN_SECONDS - sinceLastSendSec);
        throw new HttpsError(
          "resource-exhausted",
          `Please wait ${wait}s before requesting a new code.`,
        );
      }
    }

    const code = generateOtpCode();
    const salt = crypto.randomBytes(16).toString("hex");
    const codeHash = hashOtp(code, salt);
    const now = Date.now();
    const expiresAt = admin.firestore.Timestamp.fromMillis(
      now + OTP_TTL_MINUTES * 60 * 1000,
    );

    try {
      const transport = createTransport();
      const fromName = SMTP_FROM_NAME.value() || "Memoro";
      const fromAddress = SMTP_EMAIL.value();
      const message = buildOtpEmail({
        code,
        displayName: authUser.displayName || "",
      });
      await transport.sendMail({
        from: `"${fromName}" <${fromAddress}>`,
        to: email,
        subject: "Your Memoro password reset code",
        text: message.text,
        html: message.html,
      });
    } catch (err) {
      logger.error("requestEmailOtp sendMail failed", err);
      throw new HttpsError(
        "internal",
        "Could not send the verification email. Please try again.",
      );
    }

    await otpRef.set({
      email,
      uid: authUser.uid,
      codeHash,
      salt,
      attempts: 0,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      lastSentAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt,
    });

    return { ok: true, expiresInSeconds: OTP_TTL_MINUTES * 60 };
  },
);

exports.verifyEmailOtp = onCall({ region: "us-central1" }, async (request) => {
  const email = normalizeEmail(request.data && request.data.email);
  const otp = ((request.data && request.data.otp) || "").toString().trim();

  if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new HttpsError("invalid-argument", "A valid email is required.");
  }
  if (!/^\d{6}$/.test(otp)) {
    throw new HttpsError("invalid-argument", "Invalid verification code.");
  }

  const otpRef = db.collection(PASSWORD_RESET_OTPS).doc(email);
  const snap = await otpRef.get();
  if (!snap.exists) {
    throw new HttpsError("not-found", "Invalid or expired verification code.");
  }
  const data = snap.data();

  if (!data || !data.expiresAt || data.expiresAt.toMillis() < Date.now()) {
    await otpRef.delete().catch(() => {});
    throw new HttpsError(
      "deadline-exceeded",
      "Verification code expired. Please request a new one.",
    );
  }

  const attempts = (data.attempts || 0) + 1;
  if (attempts > OTP_MAX_ATTEMPTS) {
    await otpRef.delete().catch(() => {});
    throw new HttpsError(
      "resource-exhausted",
      "Too many incorrect attempts. Please request a new code.",
    );
  }

  const expectedHash = hashOtp(otp, data.salt || "");
  if (expectedHash !== data.codeHash) {
    await otpRef.set({ attempts }, { merge: true });
    throw new HttpsError("permission-denied", "Invalid verification code.");
  }

  await otpRef.set(
    {
      verified: true,
      verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  return { ok: true };
});

exports.verifyEmailOtpAndResetPassword = onCall(
  { region: "us-central1" },
  async (request) => {
    const email = normalizeEmail(request.data && request.data.email);
    const otp = ((request.data && request.data.otp) || "").toString().trim();
    const newPassword = (request.data && request.data.newPassword) || "";

    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      throw new HttpsError("invalid-argument", "A valid email is required.");
    }
    if (!/^\d{6}$/.test(otp)) {
      throw new HttpsError("invalid-argument", "Invalid verification code.");
    }
    if (typeof newPassword !== "string" || newPassword.length < 6) {
      throw new HttpsError(
        "invalid-argument",
        "Password must be at least 6 characters long.",
      );
    }

    const otpRef = db.collection(PASSWORD_RESET_OTPS).doc(email);
    const snap = await otpRef.get();
    if (!snap.exists) {
      throw new HttpsError(
        "not-found",
        "Invalid or expired verification code.",
      );
    }
    const data = snap.data();

    if (!data || !data.expiresAt || data.expiresAt.toMillis() < Date.now()) {
      await otpRef.delete().catch(() => {});
      throw new HttpsError(
        "deadline-exceeded",
        "Verification code expired. Please request a new one.",
      );
    }

    const attempts = (data.attempts || 0) + 1;
    if (attempts > OTP_MAX_ATTEMPTS) {
      await otpRef.delete().catch(() => {});
      throw new HttpsError(
        "resource-exhausted",
        "Too many incorrect attempts. Please request a new code.",
      );
    }

    const expectedHash = hashOtp(otp, data.salt || "");
    if (expectedHash !== data.codeHash) {
      await otpRef.set({ attempts }, { merge: true });
      throw new HttpsError("permission-denied", "Invalid verification code.");
    }

    const uid = data.uid;
    if (!uid) {
      throw new HttpsError("internal", "OTP record is missing the user id.");
    }

    try {
      await admin.auth().updateUser(uid, { password: newPassword });
    } catch (err) {
      logger.error("verifyEmailOtpAndResetPassword updateUser failed", err);
      throw new HttpsError(
        "internal",
        "Could not update the password. Please try again.",
      );
    }

    await otpRef.delete().catch(() => {});

    const role = await findProfileRoleByUid(uid);
    return { ok: true, role };
  },
);
