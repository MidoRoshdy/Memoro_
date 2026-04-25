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

  static int unreadCountForUser(
    Map<String, dynamic>? chatData,
    String uid,
  ) {
    final cleanUid = uid.trim();
    if (chatData == null || cleanUid.isEmpty) return 0;
    final unreadCounts = chatData['unreadCounts'];
    if (unreadCounts is Map) {
      final raw = unreadCounts[cleanUid];
      if (raw is num) return raw.toInt();
    }
    return 0;
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
              .map((d) => ChatMessage.fromFirestore(d.id, d.data(), chatId: chatId))
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
          chatId
              .split('_')
              .map((id) => id.trim())
              .where((id) => id.isNotEmpty),
        );
      }

      final unreadUpdates = <String, dynamic>{};
      for (final participantId in participants) {
        if (participantId == senderId.trim()) continue;
        unreadUpdates['unreadCounts.$participantId'] = FieldValue.increment(1);
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
        ...unreadUpdates,
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
      tx.set(ref, <String, dynamic>{
        'unreadCounts.$cleanUid': 0,
        'lastReadAt.$cleanUid': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }
}
