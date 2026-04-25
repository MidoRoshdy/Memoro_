import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/medicine_item.dart';

abstract final class MedicineService {
  MedicineService._();

  static const String collectionName = 'medicine';
  static const String itemsSubcollection = 'items';

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String buildMedicineDocId(String uidA, String uidB) {
    final a = uidA.trim();
    final b = uidB.trim();
    if (a.isEmpty || b.isEmpty) {
      throw ArgumentError('Both user IDs are required.');
    }
    final sorted = <String>[a, b]..sort();
    return '${sorted.first}_${sorted.last}';
  }

  static DocumentReference<Map<String, dynamic>> medicineRef(String medicineDocId) {
    return _db.collection(collectionName).doc(medicineDocId);
  }

  static CollectionReference<Map<String, dynamic>> _itemsRef(String medicineDocId) {
    return medicineRef(medicineDocId).collection(itemsSubcollection);
  }

  static Future<void> ensureMedicineDocument({
    required String medicineDocId,
    required String doctorUid,
    required String patientUid,
  }) async {
    final participants = <String>[doctorUid.trim(), patientUid.trim()]..sort();
    final ref = medicineRef(medicineDocId);
    final existing = await ref.get();
    if (existing.exists) {
      await ref.set(<String, dynamic>{
        'medicineId': medicineDocId,
        'doctorUid': doctorUid.trim(),
        'patientUid': patientUid.trim(),
        'participantIds': participants,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }
    await ref.set(<String, dynamic>{
      'medicineId': medicineDocId,
      'doctorUid': doctorUid.trim(),
      'patientUid': patientUid.trim(),
      'participantIds': participants,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'itemsCount': 0,
    }, SetOptions(merge: true));
  }

  static Stream<List<MedicineItem>> watchMedicines(String medicineDocId) {
    return _itemsRef(medicineDocId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => MedicineItem.fromFirestore(d.id, d.data()))
              .toList(),
        );
  }

  static Stream<MedicineItem?> watchMedicineItem(
    String medicineDocId,
    String medicineItemId,
  ) {
    return _itemsRef(medicineDocId).doc(medicineItemId).snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return null;
      return MedicineItem.fromFirestore(snap.id, data);
    });
  }

  static Future<void> addMedicine({
    required String medicineDocId,
    required String doctorUid,
    required String patientUid,
    required String createdByUid,
    required String name,
    required String dosage,
    required String intakeType,
    required int doseAmount,
    required String doseUnit,
    required String scheduledTime,
    List<String> scheduledTimes = const <String>[],
    required String frequency,
    required int daysTotal,
    required String caregiverInstructions,
    String status = 'upcoming',
    String lastDoseVerifiedBy = '',
  }) async {
    await ensureMedicineDocument(
      medicineDocId: medicineDocId,
      doctorUid: doctorUid,
      patientUid: patientUid,
    );
    final ref = _itemsRef(medicineDocId).doc();
    final normalizedStatus = status.trim().toLowerCase();
    await ref.set(<String, dynamic>{
      'medicineItemId': ref.id,
      'name': name.trim(),
      'dosage': dosage.trim(),
      'intakeType': intakeType.trim(),
      'doseAmount': doseAmount,
      'doseUnit': doseUnit.trim(),
      'scheduledTime': scheduledTime.trim(),
      'scheduledTimes': scheduledTimes
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList(),
      'frequency': frequency.trim(),
      'daysTotal': daysTotal,
      'caregiverInstructions': caregiverInstructions.trim(),
      'status': normalizedStatus,
      'lastDoseAt': normalizedStatus == 'taken'
          ? FieldValue.serverTimestamp()
          : null,
      'lastDoseVerifiedBy': normalizedStatus == 'taken'
          ? lastDoseVerifiedBy.trim()
          : '',
      'createdByUid': createdByUid.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await medicineRef(medicineDocId).set(<String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
      'itemsCount': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  static Future<void> updateMedicine({
    required String medicineDocId,
    required String medicineItemId,
    required String name,
    required String dosage,
    required String intakeType,
    required int doseAmount,
    required String doseUnit,
    required String scheduledTime,
    List<String> scheduledTimes = const <String>[],
    required String frequency,
    required int daysTotal,
    required String caregiverInstructions,
    required String status,
    String lastDoseVerifiedBy = '',
  }) async {
    final normalizedStatus = status.trim().toLowerCase();
    final updateData = <String, dynamic>{
      'name': name.trim(),
      'dosage': dosage.trim(),
      'intakeType': intakeType.trim(),
      'doseAmount': doseAmount,
      'doseUnit': doseUnit.trim(),
      'scheduledTime': scheduledTime.trim(),
      'scheduledTimes': scheduledTimes
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList(),
      'frequency': frequency.trim(),
      'daysTotal': daysTotal,
      'caregiverInstructions': caregiverInstructions.trim(),
      'status': normalizedStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (normalizedStatus == 'taken') {
      updateData['lastDoseAt'] = FieldValue.serverTimestamp();
      updateData['lastDoseVerifiedBy'] = lastDoseVerifiedBy.trim();
    }
    await _itemsRef(medicineDocId).doc(medicineItemId).set(
      updateData,
      SetOptions(merge: true),
    );
    await medicineRef(medicineDocId).set(<String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> deleteMedicine({
    required String medicineDocId,
    required String medicineItemId,
  }) async {
    await _itemsRef(medicineDocId).doc(medicineItemId).delete();
    await medicineRef(medicineDocId).set(<String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
      'itemsCount': FieldValue.increment(-1),
    }, SetOptions(merge: true));
  }
}
