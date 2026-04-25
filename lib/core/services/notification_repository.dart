import '../models/app_notification.dart';

abstract class NotificationRepository {
  Stream<List<AppNotification>> watchInbox(String uid);

  Stream<int> watchUnreadCount(String uid);

  Future<void> markAsRead({
    required String uid,
    required String notificationId,
  });

  Future<void> markAsOpened({
    required String uid,
    required String notificationId,
  });

  Future<void> clearInbox(String uid);
}
