import 'package:cloud_firestore/cloud_firestore.dart';

abstract final class EmergencyRequestService {
  EmergencyRequestService._();

  static const String collectionName = 'emergencyRequests';
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String buildEmergencyRequestDocId(String uidA, String uidB) {
    final a = uidA.trim();
    final b = uidB.trim();
    if (a.isEmpty || b.isEmpty) {
      throw ArgumentError('Both user IDs are required.');
    }
    final sorted = <String>[a, b]..sort();
    return '${sorted.first}_${sorted.last}';
  }

  static DocumentReference<Map<String, dynamic>> requestRef(String requestDocId) {
    return _db.collection(collectionName).doc(requestDocId);
  }

  static Stream<Map<String, dynamic>?> watchRequest(String requestDocId) {
    return requestRef(requestDocId).snapshots().map((snap) => snap.data());
  }
}
