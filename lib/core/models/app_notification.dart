import 'package:cloud_firestore/cloud_firestore.dart';

enum AppNotificationType {
  activityAssigned,
  activityDone,
  chatMessage,
  helpRequest,
  helpRequestResolved,
  medicationAdded,
  medicationTaken,
  medicationReminder,
  activityReminder,
  general,
}

enum AppNotificationPriority { normal, high }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.rawType,
    required this.type,
    required this.title,
    required this.body,
    required this.priority,
    required this.recipientUid,
    required this.actorUid,
    required this.pairId,
    required this.entityId,
    required this.deepLink,
    required this.payloadVersion,
    required this.data,
    required this.status,
    required this.retryCount,
    required this.sentAt,
    required this.createdAt,
    this.readAt,
    this.openedAt,
  });

  final String id;
  final String rawType;
  final AppNotificationType type;
  final String title;
  final String body;
  final AppNotificationPriority priority;
  final String recipientUid;
  final String actorUid;
  final String pairId;
  final String entityId;
  final String deepLink;
  final int payloadVersion;
  final Map<String, dynamic> data;
  final String status;
  final int retryCount;
  final DateTime? sentAt;
  final DateTime? createdAt;
  final DateTime? readAt;
  final DateTime? openedAt;

  bool get isRead => readAt != null;

  bool get isReminder =>
      type == AppNotificationType.activityReminder ||
      type == AppNotificationType.medicationReminder;

  factory AppNotification.fromFirestore(
    String id,
    Map<String, dynamic> json,
  ) {
    return AppNotification(
      id: id,
      rawType: (json['type'] as String?)?.trim() ?? 'general',
      type: _parseType((json['type'] as String?)?.trim()),
      title: (json['title'] as String?)?.trim() ?? '',
      body: (json['body'] as String?)?.trim() ?? '',
      priority: _parsePriority((json['priority'] as String?)?.trim()),
      recipientUid: (json['recipientUid'] as String?)?.trim() ?? '',
      actorUid: (json['actorUid'] as String?)?.trim() ?? '',
      pairId: (json['pairId'] as String?)?.trim() ?? '',
      entityId: (json['entityId'] as String?)?.trim() ?? '',
      deepLink: (json['deepLink'] as String?)?.trim() ?? '',
      payloadVersion: (json['payloadVersion'] as num?)?.toInt() ?? 1,
      data: Map<String, dynamic>.from(json['data'] as Map? ?? const {}),
      status: (json['status'] as String?)?.trim() ?? 'queued',
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
      sentAt: _parseDate(json['sentAt']),
      createdAt: _parseDate(json['createdAt']),
      readAt: _parseDate(json['readAt']),
      openedAt: _parseDate(json['openedAt']),
    );
  }

  static AppNotificationType _parseType(String? raw) {
    switch (raw) {
      case 'activity_assigned':
        return AppNotificationType.activityAssigned;
      case 'activity_done':
        return AppNotificationType.activityDone;
      case 'chat_message':
        return AppNotificationType.chatMessage;
      case 'help_request':
        return AppNotificationType.helpRequest;
      case 'help_request_resolved':
        return AppNotificationType.helpRequestResolved;
      case 'medication_added':
        return AppNotificationType.medicationAdded;
      case 'medication_taken':
        return AppNotificationType.medicationTaken;
      case 'medication_reminder':
        return AppNotificationType.medicationReminder;
      case 'activity_reminder':
        return AppNotificationType.activityReminder;
      default:
        return AppNotificationType.general;
    }
  }

  static AppNotificationPriority _parsePriority(String? raw) {
    switch (raw) {
      case 'high':
        return AppNotificationPriority.high;
      default:
        return AppNotificationPriority.normal;
    }
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
