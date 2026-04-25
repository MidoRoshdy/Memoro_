import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityItem {
  const ActivityItem({
    required this.id,
    required this.title,
    required this.type,
    required this.target,
    required this.notes,
    required this.scheduledTime,
    required this.status,
    required this.level,
    required this.scorePercent,
    required this.timeTakenMinutes,
    required this.correctMatches,
    required this.totalAttempts,
    required this.isVisibleForPatient,
    required this.assignedByName,
    required this.createdByUid,
    required this.createdAt,
    required this.updatedAt,
    required this.completedAt,
  });

  final String id;
  final String title;
  final String type;
  final String target;
  final String notes;
  final String scheduledTime;
  final String status;
  final int level;
  final int scorePercent;
  final int timeTakenMinutes;
  final int correctMatches;
  final int totalAttempts;
  final bool isVisibleForPatient;
  final String assignedByName;
  final String createdByUid;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  bool get isCompleted => status == 'completed';
  bool get isAssigned => status == 'assigned';
  bool get isCancelled => status == 'cancelled';

  static DateTime? _readDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    return null;
    }

  factory ActivityItem.fromFirestore(String id, Map<String, dynamic> data) {
    return ActivityItem(
      id: id,
      title: (data['title'] as String?)?.trim() ?? '',
      type: (data['type'] as String?)?.trim() ?? 'Other',
      target: (data['target'] as String?)?.trim() ?? '',
      notes: (data['notes'] as String?)?.trim() ?? '',
      scheduledTime: (data['scheduledTime'] as String?)?.trim() ?? '',
      status: (data['status'] as String?)?.trim().toLowerCase() ?? 'assigned',
      level: (data['level'] as num?)?.toInt() ?? 3,
      scorePercent: (data['scorePercent'] as num?)?.toInt() ?? 85,
      timeTakenMinutes: (data['timeTakenMinutes'] as num?)?.toInt() ?? 12,
      correctMatches: (data['correctMatches'] as num?)?.toInt() ?? 17,
      totalAttempts: (data['totalAttempts'] as num?)?.toInt() ?? 20,
      isVisibleForPatient: (data['isVisibleForPatient'] as bool?) ?? true,
      assignedByName: (data['assignedByName'] as String?)?.trim() ?? '',
      createdByUid: (data['createdByUid'] as String?)?.trim() ?? '',
      createdAt: _readDate(data['createdAt']),
      updatedAt: _readDate(data['updatedAt']),
      completedAt: _readDate(data['completedAt']),
    );
  }
}
