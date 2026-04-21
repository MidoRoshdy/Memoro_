import 'package:cloud_firestore/cloud_firestore.dart';

class ChatChannel {
  const ChatChannel({
    required this.id,
    required this.doctorId,
    required this.patientUid,
    required this.doctorName,
    required this.patientName,
    required this.doctorImageUrl,
    required this.patientImageUrl,
    required this.participantIds,
    this.requestId,
    this.lastMessageText,
    this.lastMessageSenderId,
    this.lastMessageAt,
    this.updatedAt,
  });

  final String id;
  final String doctorId;
  final String patientUid;
  final String doctorName;
  final String patientName;
  final String doctorImageUrl;
  final String patientImageUrl;
  final List<String> participantIds;
  final String? requestId;
  final String? lastMessageText;
  final String? lastMessageSenderId;
  final DateTime? lastMessageAt;
  final DateTime? updatedAt;

  static DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  factory ChatChannel.fromFirestore(String id, Map<String, dynamic> data) {
    final rawParticipants = data['participantIds'];
    final participantIds = rawParticipants is List
        ? rawParticipants
              .whereType<String>()
              .map((id) => id.trim())
              .where((id) => id.isNotEmpty)
              .toList()
        : const <String>[];

    return ChatChannel(
      id: id,
      doctorId: (data['doctorId'] as String?)?.trim() ?? '',
      patientUid: (data['patientUid'] as String?)?.trim() ?? '',
      doctorName: (data['doctorName'] as String?)?.trim() ?? '',
      patientName: (data['patientName'] as String?)?.trim() ?? '',
      doctorImageUrl: (data['doctorImageUrl'] as String?)?.trim() ?? '',
      patientImageUrl: (data['patientImageUrl'] as String?)?.trim() ?? '',
      participantIds: participantIds,
      requestId: (data['requestId'] as String?)?.trim(),
      lastMessageText: (data['lastMessageText'] as String?)?.trim(),
      lastMessageSenderId: (data['lastMessageSenderId'] as String?)?.trim(),
      lastMessageAt: _toDate(data['lastMessageAt']),
      updatedAt: _toDate(data['updatedAt']),
    );
  }
}
