import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final DateTime? createdAt;

  factory ChatMessage.fromFirestore(
    String id,
    Map<String, dynamic> data, {
    required String chatId,
  }) {
    final rawCreatedAt = data['createdAt'];
    DateTime? createdAt;
    if (rawCreatedAt is Timestamp) {
      createdAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is DateTime) {
      createdAt = rawCreatedAt;
    }

    return ChatMessage(
      id: id,
      chatId: chatId,
      senderId: (data['senderId'] as String?)?.trim() ?? '',
      text: (data['text'] as String?)?.trim() ?? '',
      createdAt: createdAt,
    );
  }
}
