import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRoleMismatchException implements Exception {
  AuthRoleMismatchException({required this.expectedCaregiver});

  final bool expectedCaregiver;
}

class AuthService {
  AuthService._();

  static const String testEmail = 'test@memoro.app';
  static const String testPassword = 'Test@123456';

  static const String _rememberMeKey = 'remember_me';
  static const String _savedEmailKey = 'saved_email';
  static const String caregiverCollection = 'careGiver';

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final math.Random _patientIdRandom = math.Random();

  /// Top-level `users` collection.
  static const String usersCollection = 'users';

  /// Hub doc id under [usersCollection] for all patients: `users/patients/…`.
  static const String patientsHubDocId = 'patients';

  /// Subcollection under `users/patients/` holding one doc per auth uid.
  static const String patientUsersSubcollection = 'users';

  /// Global serial for public patient ids (`p-1`, `p-2`, …). See [firestore.rules].
  static const String countersCollection = 'counters';
  static const String patientSerialDocId = 'patients';

  /// Legacy: `users/{uid}/patients/profile` (fallback writes / migration).
  static const String legacyPerUserPatientsSub = 'patients';
  static const String legacyPerUserPatientDocId = 'profile';

  /// Legacy: top-level `patients/{uid}` (fallback writes / migration).
  static const String legacyRootPatientsCollection = 'patients';

  /// Storage path prefix — must match [storage.rules] (`profileImages/{uid}/…`).
  static const String profileImagesStoragePrefix = 'profileImages';

  /// Canonical patient profile: `users/patients/users/{uid}`.
  static DocumentReference<Map<String, dynamic>> patientProfileRef(String uid) {
    return _firestore
        .collection(usersCollection)
        .doc(patientsHubDocId)
        .collection(patientUsersSubcollection)
        .doc(uid);
  }

  /// Caregiver profile: top-level `careGiver/{uid}`.
  static DocumentReference<Map<String, dynamic>> caregiverProfileRef(
    String uid,
  ) {
    return _firestore.collection(caregiverCollection).doc(uid);
  }

  /// Legacy `users/{uid}/patients/profile`.
  static DocumentReference<Map<String, dynamic>> legacyPerUserPatientRef(
    String uid,
  ) {
    return _firestore
        .collection(usersCollection)
        .doc(uid)
        .collection(legacyPerUserPatientsSub)
        .doc(legacyPerUserPatientDocId);
  }

  static User? get currentUser => _auth.currentUser;

  /// Next public id `p-{n}` from [countersCollection]/[patientSerialDocId] (`last`).
  static Future<String> _allocatePatientPublicId() async {
    final ref = _firestore
        .collection(countersCollection)
        .doc(patientSerialDocId);
    final n = await _firestore.runTransaction<int>((transaction) async {
      final snap = await transaction.get(ref);
      final last = (snap.data()?['last'] as int?) ?? 0;
      final next = last + 1;
      transaction.set(ref, <String, dynamic>{
        'last': next,
      }, SetOptions(merge: true));
      return next;
    });
    return 'p-$n';
  }

  /// When the Firestore counter is unavailable, use a short id: `p-` + 6
  /// lowercase letters/digits (e.g. `p-k3x9m2`).
  static String _fallbackPatientPublicId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final b = StringBuffer('p-');
    for (var i = 0; i < 6; i++) {
      b.write(chars[_patientIdRandom.nextInt(chars.length)]);
    }
    return b.toString();
  }

  /// Like [_allocatePatientPublicId] but never throws on [permission-denied]
  /// (e.g. [firestore.rules] for `counters/` not deployed yet).
  static Future<String> _allocatePatientPublicIdOrFallback() async {
    try {
      return await _allocatePatientPublicId();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        debugPrint(
          'Firestore: $countersCollection/$patientSerialDocId denied '
          '(${e.message}). Deploy firestore.rules. Using fallback patientId.',
        );
        return _fallbackPatientPublicId();
      }
      rethrow;
    }
  }

  static Future<void> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
    required String gender,
    required int age,
    required bool termsAccepted,
    XFile? profilePhoto,
    bool isCaregiver = false,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) return;

    await user.updateDisplayName(name);

    var imageUrl = '';
    if (profilePhoto != null) {
      try {
        final signedIn = _auth.currentUser;
        if (signedIn == null || signedIn.uid != user.uid) {
          debugPrint(
            'Profile image upload skipped: currentUser is null or uid mismatch '
            '(signedIn=${signedIn?.uid}, credential=${user.uid})',
          );
        } else {
          await signedIn.getIdToken(true);
          final pathLower = profilePhoto.path.toLowerCase();
          final ext = pathLower.endsWith('.png')
              ? '.png'
              : pathLower.endsWith('.webp')
              ? '.webp'
              : pathLower.endsWith('.gif')
              ? '.gif'
              : pathLower.endsWith('.heic') || pathLower.endsWith('.heif')
              ? '.heic'
              : (pathLower.endsWith('.jpeg') || pathLower.endsWith('.jpg'))
              ? '.jpg'
              : '.jpg';
          final contentType = ext == '.png'
              ? 'image/png'
              : ext == '.webp'
              ? 'image/webp'
              : ext == '.gif'
              ? 'image/gif'
              : ext == '.heic'
              ? 'image/heic'
              : 'image/jpeg';
          // profileImages/{uid}/profile.<ext> — matches storage.rules
          final ref = _storage.ref(
            '$profileImagesStoragePrefix/${signedIn.uid}/profile$ext',
          );
          final bytes = await profilePhoto.readAsBytes();
          final uploadTask = ref.putData(
            bytes,
            SettableMetadata(contentType: contentType),
          );
          final snapshot = await uploadTask;
          imageUrl = await snapshot.ref.getDownloadURL();
          await user.updatePhotoURL(imageUrl);
        }
      } on FirebaseException catch (e, st) {
        debugPrint(
          'Profile image upload failed: [firebase_storage/${e.code}] ${e.message}\n$st',
        );
      } catch (e, st) {
        debugPrint('Profile image upload failed: $e\n$st');
      }
    }

    try {
      if (isCaregiver) {
        await _upsertCaregiverProfile(
          uid: user.uid,
          name: name,
          email: email,
          phone: phone,
          gender: gender,
          age: age,
          termsAccepted: termsAccepted,
          imageUrl: imageUrl,
        );
      } else {
        await _upsertPatientProfile(
          uid: user.uid,
          name: name,
          email: email,
          phone: phone,
          gender: gender,
          age: age,
          termsAccepted: termsAccepted,
          imageUrl: imageUrl,
        );
      }
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        debugPrint(
          'Register: Firestore profile write failed; removing Auth user '
          '${user.uid}. Deploy firestore.rules.',
        );
        try {
          await user.delete();
        } catch (e2, st) {
          debugPrint('Register: Auth rollback failed: $e2\n$st');
        }
      }
      rethrow;
    }
  }

  static Future<void> login({
    required String email,
    required String password,
    bool expectCaregiver = false,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) return;

    final uid = user.uid;
    final roleMatches = expectCaregiver
        ? await _isCaregiverUser(uid)
        : await _isPatientUser(uid);
    if (roleMatches) return;

    await _auth.signOut();
    throw AuthRoleMismatchException(expectedCaregiver: expectCaregiver);
  }

  static Future<bool> _isPatientUser(String uid) async {
    try {
      final canonical = await patientProfileRef(uid).get();
      if (canonical.exists) return true;
    } catch (_) {}

    try {
      final legacyPerUser = await legacyPerUserPatientRef(uid).get();
      if (legacyPerUser.exists) return true;
    } catch (_) {}

    try {
      final legacyRoot = await _firestore
          .collection(legacyRootPatientsCollection)
          .doc(uid)
          .get();
      if (legacyRoot.exists) return true;
    } catch (_) {}

    return false;
  }

  static Future<bool> _isCaregiverUser(String uid) async {
    try {
      final byDocId = await caregiverProfileRef(uid).get();
      if (byDocId.exists) return true;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        debugPrint(
          'Firestore: caregiver role check denied for '
          '${caregiverProfileRef(uid).path} (${e.message})',
        );
        rethrow;
      }
    }

    return false;
  }

  static Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  static Future<void> loginWithTestAccount() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code != 'user-not-found' && e.code != 'invalid-credential') {
        rethrow;
      }
      final credential = await _auth.createUserWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );
      final user = credential.user;
      if (user == null) return;
      await user.updateDisplayName('Test User');
      await _upsertPatientProfile(
        uid: user.uid,
        name: 'Test User',
        email: testEmail,
        phone: '0000000000',
        gender: '',
        age: 0,
        termsAccepted: false,
        imageUrl: '',
      );
    }
  }

  static Future<void> logout({bool clearCachedAuthData = true}) async {
    await _auth.signOut();
    if (clearCachedAuthData) {
      await clearAuthCache();
    }
  }

  /// Clears locally cached auth/session data used for auto-login.
  static Future<void> clearAuthCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_rememberMeKey);
      await prefs.remove(_savedEmailKey);
    } on MissingPluginException {
      // Plugin not ready yet (usually after hot restart).
    }
  }

  static Future<void> saveRememberMe({
    required bool rememberMe,
    required String email,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_rememberMeKey, rememberMe);
      if (rememberMe) {
        await prefs.setString(_savedEmailKey, email);
      } else {
        await prefs.remove(_savedEmailKey);
      }
    } on MissingPluginException {
      // Plugin not ready yet (usually after hot restart).
    }
  }

  static Future<bool> getRememberMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_rememberMeKey) ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<String> getSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_savedEmailKey) ?? '';
    } on MissingPluginException {
      return '';
    }
  }

  static Future<bool> shouldAutoLogin() async {
    final remember = await getRememberMe();
    return remember && _auth.currentUser != null;
  }

  static Future<bool> isCurrentUserCaregiver() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    return _isCaregiverUser(user.uid);
  }

  /// Ensures canonical `users/patients/users/{uid}` exists when rules allow it.
  ///
  /// Migrates legacy `users/{uid}/patients/profile`, root `patients/{uid}`, or
  /// flat `users/{uid}` profile data into the canonical path, otherwise seeds
  /// from [FirebaseAuth].
  static Future<void> ensurePatientDocument() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final uid = user.uid;
    final patientRef = patientProfileRef(uid);

    try {
      final patientSnap = await patientRef.get();
      final pdata = patientSnap.data();
      final email = (pdata?['email'] as String?)?.trim() ?? '';
      if (email.isNotEmpty &&
          pdata != null &&
          pdata.containsKey('termsAccepted')) {
        return;
      }

      DocumentSnapshot<Map<String, dynamic>>? legacyPerUserSnap;
      try {
        legacyPerUserSnap = await legacyPerUserPatientRef(uid).get();
      } on FirebaseException catch (e) {
        if (e.code != 'permission-denied') rethrow;
        legacyPerUserSnap = null;
      }
      if (legacyPerUserSnap?.exists == true &&
          legacyPerUserSnap!.data() != null) {
        final d = legacyPerUserSnap.data()!;
        if ((d['email'] as String?)?.trim().isNotEmpty == true &&
            d.containsKey('termsAccepted')) {
          final merged = Map<String, dynamic>.from(d);
          merged['uid'] = uid;
          if ((merged['patientId'] as String?)?.trim().isEmpty ?? true) {
            merged['patientId'] = await _allocatePatientPublicIdOrFallback();
          }
          merged['userType'] = 'patient';
          merged['updatedAt'] = FieldValue.serverTimestamp();
          await _writePatientProfileWithFallback(uid: uid, payload: merged);
          debugPrint(
            'Firestore: migrated users/$uid/$legacyPerUserPatientsSub/'
            '$legacyPerUserPatientDocId -> '
            'users/$patientsHubDocId/$patientUsersSubcollection/$uid',
          );
          return;
        }
      }

      DocumentSnapshot<Map<String, dynamic>>? legacyRootPatient;
      try {
        legacyRootPatient = await _firestore
            .collection(legacyRootPatientsCollection)
            .doc(uid)
            .get();
      } on FirebaseException catch (e) {
        if (e.code != 'permission-denied') rethrow;
        legacyRootPatient = null;
      }
      if (legacyRootPatient?.exists == true &&
          legacyRootPatient!.data() != null) {
        final merged = Map<String, dynamic>.from(legacyRootPatient.data()!);
        merged['uid'] = uid;
        if ((merged['patientId'] as String?)?.trim().isEmpty ?? true) {
          merged['patientId'] = await _allocatePatientPublicIdOrFallback();
        }
        merged['userType'] = 'patient';
        merged['updatedAt'] = FieldValue.serverTimestamp();
        await _writePatientProfileWithFallback(uid: uid, payload: merged);
        debugPrint(
          'Firestore: migrated $legacyRootPatientsCollection/$uid -> '
          'users/$patientsHubDocId/$patientUsersSubcollection/$uid',
        );
        return;
      }

      DocumentSnapshot<Map<String, dynamic>>? legacyFlatUser;
      try {
        legacyFlatUser = await _firestore
            .collection(usersCollection)
            .doc(uid)
            .get();
      } on FirebaseException catch (e) {
        if (e.code != 'permission-denied') rethrow;
        legacyFlatUser = null;
      }
      if (legacyFlatUser?.exists == true && legacyFlatUser!.data() != null) {
        final d = legacyFlatUser.data()!;
        if ((d['email'] as String?)?.trim().isNotEmpty == true &&
            d.containsKey('termsAccepted')) {
          final merged = Map<String, dynamic>.from(d);
          merged['uid'] = uid;
          if ((merged['patientId'] as String?)?.trim().isEmpty ?? true) {
            merged['patientId'] = await _allocatePatientPublicIdOrFallback();
          }
          merged['userType'] = 'patient';
          merged['updatedAt'] = FieldValue.serverTimestamp();
          await _writePatientProfileWithFallback(uid: uid, payload: merged);
          debugPrint(
            'Firestore: migrated flat users/$uid -> '
            'users/$patientsHubDocId/$patientUsersSubcollection/$uid',
          );
          return;
        }
      }

      await _writePatientProfileWithFallback(
        uid: uid,
        payload: {
          'uid': uid,
          'patientId': await _allocatePatientPublicIdOrFallback(),
          'email': user.email ?? '',
          'name': user.displayName ?? '',
          'imageUrl': user.photoURL ?? '',
          'userType': 'patient',
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
      debugPrint(
        'Firestore: seeded users/$patientsHubDocId/$patientUsersSubcollection/'
        '$uid from Auth (minimal)',
      );
    } on FirebaseException catch (e) {
      debugPrint('ensurePatientDocument: ${e.code} ${e.message}');
    }
  }

  static Future<void> _upsertPatientProfile({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String gender,
    required int age,
    required bool termsAccepted,
    required String imageUrl,
  }) async {
    String? existingPatientId;
    final readOrder = <DocumentReference<Map<String, dynamic>>>[
      patientProfileRef(uid),
      legacyPerUserPatientRef(uid),
      _firestore.collection(legacyRootPatientsCollection).doc(uid),
    ];
    for (final ref in readOrder) {
      try {
        final existing = await ref.get();
        final id = (existing.data()?['patientId'] as String?)?.trim();
        if (id != null && id.isNotEmpty) {
          existingPatientId = id;
          break;
        }
      } on FirebaseException catch (e) {
        debugPrint('Firestore: read ${ref.path} ${e.code} ${e.message}');
        if (e.code != 'permission-denied') {
          rethrow;
        }
      }
    }

    final patientId =
        (existingPatientId != null && existingPatientId.isNotEmpty)
        ? existingPatientId
        : await _allocatePatientPublicIdOrFallback();

    final payload = <String, dynamic>{
      'uid': uid,
      'patientId': patientId,
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'age': age,
      'termsAccepted': termsAccepted,
      'imageUrl': imageUrl,
      'userType': 'patient',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _writePatientProfileWithFallback(uid: uid, payload: payload);
  }

  static Future<void> _upsertCaregiverProfile({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String gender,
    required int age,
    required bool termsAccepted,
    required String imageUrl,
  }) async {
    final payload = <String, dynamic>{
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'age': age,
      'termsAccepted': termsAccepted,
      'imageUrl': imageUrl,
      'userType': 'caregiver',
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await caregiverProfileRef(uid).set(payload, SetOptions(merge: true));
  }

  /// Writes canonical `users/patients/users/{uid}`, then legacy per-user
  /// profile, then root `patients/{uid}` if denied.
  static Future<void> _writePatientProfileWithFallback({
    required String uid,
    required Map<String, dynamic> payload,
  }) async {
    try {
      await patientProfileRef(uid).set(payload, SetOptions(merge: true));
      return;
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') {
        rethrow;
      }
      debugPrint(
        'Firestore: users/$patientsHubDocId/$patientUsersSubcollection/$uid '
        'write denied (${e.message}); trying users/$uid/'
        '$legacyPerUserPatientsSub/$legacyPerUserPatientDocId',
      );
    }
    try {
      await legacyPerUserPatientRef(uid).set(payload, SetOptions(merge: true));
      debugPrint(
        'Firestore: wrote legacy users/$uid/$legacyPerUserPatientsSub/'
        '$legacyPerUserPatientDocId',
      );
      return;
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') {
        rethrow;
      }
      debugPrint(
        'Firestore: legacy per-user write denied (${e.message}); '
        'trying $legacyRootPatientsCollection/$uid',
      );
    }
    try {
      await _firestore
          .collection(legacyRootPatientsCollection)
          .doc(uid)
          .set(payload, SetOptions(merge: true));
      debugPrint(
        'Firestore: wrote $legacyRootPatientsCollection/$uid (fallback path)',
      );
    } on FirebaseException catch (e2) {
      debugPrint(
        'Firestore: $legacyRootPatientsCollection/$uid also denied '
        '(${e2.message}). Publish firestore.rules.',
      );
      rethrow;
    }
  }
}
