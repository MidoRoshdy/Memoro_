import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/patient_public_profile.dart';
import 'auth_service.dart';

class PatientLookupService {
  PatientLookupService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Normalizes user input: trim, strip leading `#`, lowercase.
  static String normalizePublicPatientId(String raw) {
    var s = raw.trim();
    if (s.startsWith('#')) {
      s = s.substring(1).trim();
    }
    return s.toLowerCase();
  }

  static Future<PatientPublicProfile?> findByPublicPatientId(
    String rawInput,
  ) async {
    final patientId = normalizePublicPatientId(rawInput);
    if (patientId.isEmpty) {
      return null;
    }

    final canonical = await _db
        .collection(AuthService.usersCollection)
        .doc(AuthService.patientsHubDocId)
        .collection(AuthService.patientUsersSubcollection)
        .where('patientId', isEqualTo: patientId)
        .limit(1)
        .get();

    if (canonical.docs.isNotEmpty) {
      return PatientPublicProfile.fromDocumentSnapshot(canonical.docs.first);
    }

    final legacy = await _db
        .collection(AuthService.legacyRootPatientsCollection)
        .where('patientId', isEqualTo: patientId)
        .limit(1)
        .get();

    if (legacy.docs.isNotEmpty) {
      return PatientPublicProfile.fromDocumentSnapshot(legacy.docs.first);
    }

    return null;
  }
}
