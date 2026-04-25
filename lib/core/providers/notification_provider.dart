import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_notification.dart';
import '../services/notification_inbox_service.dart';
import '../services/notification_repository.dart';
import '../services/push_notification_service.dart';
import 'user_profile_provider.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationInboxService();
});

final currentUserUidProvider = Provider<String?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.currentUser?.uid;
});

final notificationsInboxProvider = StreamProvider<List<AppNotification>>((ref) {
  final uid = ref.watch(currentUserUidProvider);
  if (uid == null || uid.isEmpty) {
    return Stream.value(const <AppNotification>[]);
  }
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.watchInbox(uid);
});

final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  final uid = ref.watch(currentUserUidProvider);
  if (uid == null || uid.isEmpty) return Stream.value(0);
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.watchUnreadCount(uid);
});

final notificationBootstrapProvider = FutureProvider<void>((ref) async {
  await PushNotificationService.initialize();
});

final notificationActionsProvider = Provider<NotificationActions>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return NotificationActions(repo: repo, auth: auth);
});

class NotificationActions {
  NotificationActions({required this.repo, required this.auth});

  final NotificationRepository repo;
  final FirebaseAuth auth;

  Future<void> markAsRead(String notificationId) async {
    final uid = auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;
    await repo.markAsRead(uid: uid, notificationId: notificationId);
  }

  Future<void> markAsOpened(String notificationId) async {
    final uid = auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;
    await repo.markAsOpened(uid: uid, notificationId: notificationId);
  }

  Future<void> clearAll() async {
    final uid = auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;
    await repo.clearInbox(uid);
  }
}
