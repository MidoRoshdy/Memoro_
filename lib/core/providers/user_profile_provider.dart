import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges().asyncExpand((user) {
    if (user == null) {
      return Stream<UserProfile?>.value(null);
    }
    return _profileStreamForUser(user);
  });
});

Stream<UserProfile?> _profileStreamForUser(User user) async* {
  await AuthService.ensurePatientDocument();

  final initialProfile = await _resolveProfile(user);
  yield initialProfile ?? UserProfile.fromAuth(user);

  // Live updates from canonical path when rules allow it.
  try {
    await for (final canonicalSnap in AuthService.patientProfileRef(
      user.uid,
    ).snapshots()) {
      final canonical = _profileFromDoc(canonicalSnap, user);
      if (canonical != null) {
        yield canonical;
      }
    }
  } on FirebaseException catch (e) {
    if (e.code == 'permission-denied') {
      debugPrint('Canonical profile stream denied: ${e.message}');
      return;
    }
    rethrow;
  }
}

Future<UserProfile?> _resolveProfile(User user) async {
  final canonicalSnap = await _safeGet(AuthService.patientProfileRef(user.uid));
  final canonical = _profileFromDoc(canonicalSnap, user);
  if (canonical != null) return canonical;

  final legacyPerUserSnap = await _safeGet(AuthService.legacyPerUserPatientRef(user.uid));
  final perUserProfile = _profileFromDoc(legacyPerUserSnap, user);
  if (perUserProfile != null) return perUserProfile;

  final legacyRootSnap = await _safeGet(
    FirebaseFirestore.instance
        .collection(AuthService.legacyRootPatientsCollection)
        .doc(user.uid),
  );
  return _profileFromDoc(legacyRootSnap, user);
}

Future<DocumentSnapshot<Map<String, dynamic>>?> _safeGet(
  DocumentReference<Map<String, dynamic>> ref,
) async {
  try {
    return await ref.get();
  } on FirebaseException catch (e) {
    if (e.code == 'permission-denied') {
      debugPrint('Profile read denied on ${ref.path}: ${e.message}');
      return null;
    }
    rethrow;
  }
}

UserProfile? _profileFromDoc(
  DocumentSnapshot<Map<String, dynamic>>? snap,
  User authUser,
) {
  if (snap == null) return null;
  final data = snap.data();
  if (data == null) return null;
  return UserProfile.fromSources(uid: authUser.uid, data: data, authUser: authUser);
}
