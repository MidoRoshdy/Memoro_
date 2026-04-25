import 'package:cloud_firestore/cloud_firestore.dart';

class GameLinkItem {
  const GameLinkItem({
    required this.id,
    required this.title,
    required this.url,
    required this.isVisible,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String url;
  final bool isVisible;
  final DateTime? createdAt;

  factory GameLinkItem.fromFirestore(String id, Map<String, dynamic> data) {
    final rawCreatedAt = data['createdAt'];
    DateTime? createdAt;
    if (rawCreatedAt is Timestamp) {
      createdAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is DateTime) {
      createdAt = rawCreatedAt;
    }

    return GameLinkItem(
      id: id,
      title: (data['title'] as String?)?.trim() ?? '',
      url: (data['url'] as String?)?.trim() ?? '',
      isVisible: (data['isVisible'] as bool?) ?? true,
      createdAt: createdAt,
    );
  }
}
