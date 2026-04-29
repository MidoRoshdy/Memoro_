import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_message.dart';

abstract final class ChatService {
  ChatService._();

  static const String chatsCollection = 'chats';
  static const String messagesSubcollection = 'messages';

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String buildChatIdFromUids(String uidA, String uidB) {
    final a = uidA.trim();
    final b = uidB.trim();
    if (a.isEmpty || b.isEmpty) {
      throw ArgumentError('Both user IDs must be non-empty.');
    }
    final sorted = [a, b]..sort();
    return '${sorted.first}_${sorted.last}';
  }

  static DocumentReference<Map<String, dynamic>> chatRef(String chatId) {
    return _db.collection(chatsCollection).doc(chatId);
  }

  static CollectionReference<Map<String, dynamic>> messagesRef(String chatId) {
    return chatRef(chatId).collection(messagesSubcollection);
  }

  static int unreadCountForUser(Map<String, dynamic>? chatData, String uid) {
    final cleanUid = uid.trim();
    if (chatData == null || cleanUid.isEmpty) return 0;
    if (inChatForUser(chatData, cleanUid)) {
      // While user is inside this chat, always hide unread badge.
      return 0;
    }
    var mapValue = 0;
    final unreadCounts = chatData['unreadCounts'];
    if (unreadCounts is Map) {
      final raw = unreadCounts[cleanUid];
      if (raw is num) {
        mapValue = raw.toInt();
      }
    }
    final legacyRaw = chatData['unreadCounts.$cleanUid'];
    final legacyValue = legacyRaw is num ? legacyRaw.toInt() : 0;
    // Transitional behavior:
    // - prefer map once non-zero
    // - if map is zero but legacy still has value, use legacy.
    if (mapValue > 0) return mapValue;
    if (legacyValue > 0) return legacyValue;
    return mapValue;
  }

  static bool inChatForUser(Map<String, dynamic>? chatData, String uid) {
    final cleanUid = uid.trim();
    if (chatData == null || cleanUid.isEmpty) return false;
    var mapValue = false;
    final inChat = chatData['inChat'];
    if (inChat is Map) {
      final raw = inChat[cleanUid];
      if (raw is bool) mapValue = raw;
    }
    final legacyRaw = chatData['inChat.$cleanUid'];
    final legacyValue = legacyRaw is bool ? legacyRaw : false;
    // Transitional behavior: true in either source means in-chat.
    return mapValue || legacyValue;
  }

  /// Real-time unread count derived from the `messages` subcollection so it
  /// always matches reality regardless of legacy/dotted fields in the chat doc.
  ///
  /// Rules:
  /// - if `inChat[uid] == true` -> emits 0 (counter hidden while inside chat)
  /// - else counts messages where `senderId != uid` and
  ///   `createdAt > lastReadAt[uid]`.
  static Stream<int> watchUnreadCountFromMessages({
    required String chatId,
    required String uid,
  }) {
    final cleanChatId = chatId.trim();
    final cleanUid = uid.trim();
    if (cleanChatId.isEmpty || cleanUid.isEmpty) {
      return Stream<int>.value(0);
    }
    return chatRef(cleanChatId).snapshots().asyncMap((chatSnap) async {
      final data = chatSnap.data();
      if (inChatForUser(data, cleanUid)) return 0;

      DateTime? lastRead;
      final lastReadMap = data?['lastReadAt'];
      if (lastReadMap is Map) {
        final raw = lastReadMap[cleanUid];
        if (raw is Timestamp) {
          lastRead = raw.toDate();
        } else if (raw is DateTime) {
          lastRead = raw;
        }
      }
      final legacyRaw = data?['lastReadAt.$cleanUid'];
      if (lastRead == null) {
        if (legacyRaw is Timestamp) {
          lastRead = legacyRaw.toDate();
        } else if (legacyRaw is DateTime) {
          lastRead = legacyRaw;
        }
      }

      Query<Map<String, dynamic>> query = messagesRef(cleanChatId);
      if (lastRead != null) {
        query = query.where(
          'createdAt',
          isGreaterThan: Timestamp.fromDate(lastRead),
        );
      }
      final snap = await query.get();
      var count = 0;
      for (final doc in snap.docs) {
        final senderId = (doc.data()['senderId'] as String?)?.trim() ?? '';
        if (senderId.isNotEmpty && senderId != cleanUid) {
          count += 1;
        }
      }
      return count;
    });
  }

  static Future<String> ensureChannelForDoctorPatient({
    required String doctorId,
    required String patientUid,
    required String doctorName,
    required String doctorImageUrl,
    required String patientName,
    required String patientImageUrl,
    String? requestId,
  }) async {
    final chatId = buildChatIdFromUids(doctorId, patientUid);
    final participants = <String>[doctorId.trim(), patientUid.trim()]..sort();
    await chatRef(chatId).set(<String, dynamic>{
      'chatId': chatId,
      'doctorId': doctorId.trim(),
      'patientUid': patientUid.trim(),
      'doctorName': doctorName.trim(),
      'doctorImageUrl': doctorImageUrl.trim(),
      'patientName': patientName.trim(),
      'patientImageUrl': patientImageUrl.trim(),
      'participantIds': participants,
      'inChat': <String, bool>{for (final id in participants) id: false},
      'unreadCounts': <String, int>{for (final id in participants) id: 0},
      'lastReadAt': <String, dynamic>{},
      if (requestId != null && requestId.trim().isNotEmpty)
        'requestId': requestId.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return chatId;
  }

  static Stream<List<ChatMessage>> watchMessages(String chatId) {
    return messagesRef(chatId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (d) =>
                    ChatMessage.fromFirestore(d.id, d.data(), chatId: chatId),
              )
              .toList(),
        );
  }

  static Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final content = text.trim();
    if (content.isEmpty) return;

    final msgRef = messagesRef(chatId).doc();
    final now = FieldValue.serverTimestamp();
    await _db.runTransaction((tx) async {
      final chatSnap = await tx.get(chatRef(chatId));
      final chatData = chatSnap.data();
      final rawParticipants = chatData?['participantIds'];
      final participants = rawParticipants is List
          ? rawParticipants
                .whereType<String>()
                .map((id) => id.trim())
                .where((id) => id.isNotEmpty)
                .toSet()
          : <String>{};

      if (participants.isEmpty) {
        participants.addAll(
          chatId.split('_').map((id) => id.trim()).where((id) => id.isNotEmpty),
        );
      }

      final unreadMap = <String, dynamic>{};
      for (final participantId in participants) {
        unreadMap[participantId] = unreadCountForUser(chatData, participantId);
      }
      for (final participantId in participants) {
        if (participantId == senderId.trim()) continue;
        final recipientInChat = inChatForUser(chatData, participantId);
        final currentUnread = unreadMap[participantId];
        final currentValue = currentUnread is num ? currentUnread.toInt() : 0;
        unreadMap[participantId] = recipientInChat ? 0 : currentValue + 1;
      }

      tx.set(msgRef, <String, dynamic>{
        'messageId': msgRef.id,
        'chatId': chatId,
        'senderId': senderId.trim(),
        'text': content,
        'type': 'text',
        'createdAt': now,
      });
      tx.set(chatRef(chatId), <String, dynamic>{
        'lastMessageText': content,
        'lastMessageSenderId': senderId.trim(),
        'lastMessageAt': now,
        'updatedAt': now,
        'unreadCounts': unreadMap,
      }, SetOptions(merge: true));
    });
  }

  static Future<void> resetUnreadCount({
    required String chatId,
    required String uid,
  }) async {
    final cleanUid = uid.trim();
    if (cleanUid.isEmpty) return;
    final ref = chatRef(chatId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data();
      final current = unreadCountForUser(data, cleanUid);
      if (current <= 0) return;
      final unreadMap = <String, dynamic>{
        ...(data?['unreadCounts'] is Map
            ? Map<String, dynamic>.from(data!['unreadCounts'] as Map)
            : <String, dynamic>{}),
      };
      unreadMap[cleanUid] = 0;
      final lastReadMap = <String, dynamic>{
        ...(data?['lastReadAt'] is Map
            ? Map<String, dynamic>.from(data!['lastReadAt'] as Map)
            : <String, dynamic>{}),
      };
      lastReadMap[cleanUid] = FieldValue.serverTimestamp();
      tx.set(ref, <String, dynamic>{
        'unreadCounts': unreadMap,
        'lastReadAt': lastReadMap,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  static Future<void> setInChatPresence({
    required String chatId,
    required String uid,
    required bool inChat,
  }) async {
    final cleanUid = uid.trim();
    if (cleanUid.isEmpty) return;
    final ref = chatRef(chatId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data();
      final inChatMap = <String, dynamic>{
        ...(data?['inChat'] is Map
            ? Map<String, dynamic>.from(data!['inChat'] as Map)
            : <String, dynamic>{}),
      };
      inChatMap[cleanUid] = inChat;

      final payload = <String, dynamic>{
        'inChat': inChatMap,
        'inChatUpdatedAt': <String, dynamic>{
          ...(data?['inChatUpdatedAt'] is Map
              ? Map<String, dynamic>.from(data!['inChatUpdatedAt'] as Map)
              : <String, dynamic>{}),
          cleanUid: FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (inChat) {
        final unreadMap = <String, dynamic>{
          ...(data?['unreadCounts'] is Map
              ? Map<String, dynamic>.from(data!['unreadCounts'] as Map)
              : <String, dynamic>{}),
        };
        unreadMap[cleanUid] = 0;
        final lastReadMap = <String, dynamic>{
          ...(data?['lastReadAt'] is Map
              ? Map<String, dynamic>.from(data!['lastReadAt'] as Map)
              : <String, dynamic>{}),
        };
        lastReadMap[cleanUid] = FieldValue.serverTimestamp();
        payload['unreadCounts'] = unreadMap;
        payload['lastReadAt'] = lastReadMap;
      }
      tx.set(ref, payload, SetOptions(merge: true));
    });
  }
}
