import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activity_item.dart';

abstract final class ActivityService {
  ActivityService._();

  static const String collectionName = 'activity';
  static const String itemsSubcollection = 'items';

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String buildActivityDocId(String uidA, String uidB) {
    final a = uidA.trim();
    final b = uidB.trim();
    if (a.isEmpty || b.isEmpty) {
      throw ArgumentError('Both user IDs are required.');
    }
    final sorted = <String>[a, b]..sort();
    return '${sorted.first}_${sorted.last}';
  }

  static DocumentReference<Map<String, dynamic>> activityRef(
    String activityDocId,
  ) {
    return _db.collection(collectionName).doc(activityDocId);
  }

  static CollectionReference<Map<String, dynamic>> _itemsRef(
    String activityDocId,
  ) {
    return activityRef(activityDocId).collection(itemsSubcollection);
  }

  static Future<void> ensureActivityDocument({
    required String activityDocId,
    required String doctorUid,
    required String patientUid,
  }) async {
    final participants = <String>[doctorUid.trim(), patientUid.trim()]..sort();
    final ref = activityRef(activityDocId);
    final existing = await ref.get();
    if (existing.exists) {
      await ref.set(<String, dynamic>{
        'activityId': activityDocId,
        'doctorUid': doctorUid.trim(),
        'patientUid': patientUid.trim(),
        'participantIds': participants,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }
    await ref.set(<String, dynamic>{
      'activityId': activityDocId,
      'doctorUid': doctorUid.trim(),
      'patientUid': patientUid.trim(),
      'participantIds': participants,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'itemsCount': 0,
    }, SetOptions(merge: true));
  }

  static Stream<List<ActivityItem>> watchActivities(String activityDocId) {
    return _itemsRef(activityDocId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ActivityItem.fromFirestore(d.id, d.data()))
              .toList(),
        );
  }

  static Stream<String?> watchLatestActivityDocIdForPatient(String patientUid) {
    final uid = patientUid.trim();
    if (uid.isEmpty) return Stream<String?>.value(null);
    return _db
        .collection(collectionName)
        .where('participantIds', arrayContains: uid)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return null;
          final sorted = [...snap.docs]
            ..sort((a, b) {
              final aUpdated = a.data()['updatedAt'];
              final bUpdated = b.data()['updatedAt'];
              if (aUpdated is! Timestamp && bUpdated is! Timestamp) return 0;
              if (aUpdated is! Timestamp) return 1;
              if (bUpdated is! Timestamp) return -1;
              return bUpdated.compareTo(aUpdated);
            });
          return sorted.first.id;
        });
  }

  static Stream<ActivityItem?> watchActivityItem(
    String activityDocId,
    String activityItemId,
  ) {
    return _itemsRef(activityDocId).doc(activityItemId).snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return null;
      return ActivityItem.fromFirestore(snap.id, data);
    });
  }

  static Future<void> addActivity({
    required String activityDocId,
    required String doctorUid,
    required String patientUid,
    required String createdByUid,
    required String title,
    required String type,
    required String target,
    required String notes,
    required String scheduledTime,
    String assignedByName = '',
  }) async {
    await ensureActivityDocument(
      activityDocId: activityDocId,
      doctorUid: doctorUid,
      patientUid: patientUid,
    );

    final ref = _itemsRef(activityDocId).doc();
    await ref.set(<String, dynamic>{
      'activityItemId': ref.id,
      'title': title.trim(),
      'type': type.trim(),
      'target': target.trim(),
      'notes': notes.trim(),
      'scheduledTime': scheduledTime.trim(),
      'status': 'assigned',
      'level': 3,
      'scorePercent': 85,
      'timeTakenMinutes': 12,
      'correctMatches': 17,
      'totalAttempts': 20,
      'isVisibleForPatient': true,
      'assignedByName': assignedByName.trim(),
      'createdByUid': createdByUid.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await activityRef(activityDocId).set(<String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
      'itemsCount': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  static Future<void> markCompleted({
    required String activityDocId,
    required String activityItemId,
  }) async {
    await _itemsRef(activityDocId).doc(activityItemId).set(<String, dynamic>{
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await activityRef(activityDocId).set(<String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> setVisibilityForPatient({
    required String activityDocId,
    required String activityItemId,
    required bool isVisibleForPatient,
  }) async {
    await _itemsRef(activityDocId).doc(activityItemId).set(<String, dynamic>{
      'isVisibleForPatient': isVisibleForPatient,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> cancelActivity({
    required String activityDocId,
    required String activityItemId,
  }) async {
    await _itemsRef(activityDocId).doc(activityItemId).set(<String, dynamic>{
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
