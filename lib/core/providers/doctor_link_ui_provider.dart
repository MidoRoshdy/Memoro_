import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/doctor_link_request_service.dart';
import 'user_profile_provider.dart';

final doctorLinkUiStateProvider = StreamProvider<DoctorLinkStreamState>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges().asyncExpand((user) {
    if (user == null) {
      return Stream.value(
        const DoctorLinkStreamState(phase: DoctorLinkUiPhase.connect),
      );
    }
    return DoctorLinkRequestService.watchDoctorLinkUiState(user.uid);
  });
});
