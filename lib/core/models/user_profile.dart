import 'package:firebase_auth/firebase_auth.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.patientId,
  });

  final String uid;
  final String name;
  final String email;
  final String imageUrl;
  final String patientId;

  factory UserProfile.fromSources({
    required String uid,
    required Map<String, dynamic> data,
    User? authUser,
  }) {
    final mapName = (data['name'] as String?)?.trim() ?? '';
    final mapEmail = (data['email'] as String?)?.trim() ?? '';
    final mapImage = (data['imageUrl'] as String?)?.trim() ?? '';
    final mapPatientId = (data['patientId'] as String?)?.trim() ?? '';

    return UserProfile(
      uid: uid,
      name: _resolveName(
        mapName: mapName,
        authDisplayName: authUser?.displayName,
        email: mapEmail.isNotEmpty ? mapEmail : (authUser?.email ?? ''),
      ),
      email: mapEmail.isNotEmpty ? mapEmail : (authUser?.email ?? ''),
      imageUrl: mapImage.isNotEmpty ? mapImage : (authUser?.photoURL ?? ''),
      patientId: mapPatientId,
    );
  }

  factory UserProfile.fromAuth(User user) {
    return UserProfile(
      uid: user.uid,
      name: _resolveName(
        mapName: '',
        authDisplayName: user.displayName,
        email: user.email ?? '',
      ),
      email: user.email ?? '',
      imageUrl: user.photoURL ?? '',
      patientId: '',
    );
  }

  bool get hasPrimaryData => name.trim().isNotEmpty || email.trim().isNotEmpty;

  static String _resolveName({
    required String mapName,
    required String? authDisplayName,
    required String email,
  }) {
    if (mapName.trim().isNotEmpty) return mapName.trim();

    final displayName = authDisplayName?.trim() ?? '';
    if (displayName.isNotEmpty) return displayName;

    final normalizedEmail = email.trim();
    if (normalizedEmail.contains('@')) {
      final localPart = normalizedEmail.split('@').first.trim();
      if (localPart.isNotEmpty) return localPart;
    }

    return 'Guest';
  }
}
