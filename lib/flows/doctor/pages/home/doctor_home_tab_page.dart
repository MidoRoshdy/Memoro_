import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/models/patient_public_profile.dart';
import '../../../../core/providers/user_profile_provider.dart';
import '../../../../core/services/chat_service.dart';
import '../../../../core/services/doctor_link_request_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../pationt/widgets/app_notifications_action.dart';
import '../../doctor_patient_link_stage.dart';
import 'doctor_connect_with_patient_page.dart';
import 'doctor_patient_access_pending_page.dart';
import 'doctor_patient_care_dashboard_page.dart';

enum _DoctorHomePatientStage { connect, pending, dashboard }

class DoctorHomeTabPage extends ConsumerStatefulWidget {
  const DoctorHomeTabPage({
    super.key,
    this.onSelectTab,
    this.onLinkStageChanged,
  });

  final ValueChanged<int>? onSelectTab;

  /// Notifies the parent when connect / pending / linked (dashboard) changes.
  final ValueChanged<DoctorPatientLinkStage>? onLinkStageChanged;

  @override
  ConsumerState<DoctorHomeTabPage> createState() => _DoctorHomeTabPageState();
}

class _DoctorHomeTabPageState extends ConsumerState<DoctorHomeTabPage> {
  _DoctorHomePatientStage _stage = _DoctorHomePatientStage.connect;
  String _patientCode = '';
  PatientPublicProfile? _resolvedPatient;

  bool _bootstrapLoading = true;

  StreamSubscription<DoctorLinkStreamState>? _linkSub;
  StreamSubscription<User?>? _authUserSub;

  Future<void> _ensureLinkedChatChannel(DoctorLinkStreamState state) async {
    final data = state.requestData;
    if (state.phase != DoctorLinkUiPhase.linked || data == null) return;
    final doctorId = (data['doctorId'] as String?)?.trim() ?? '';
    final patientUid = (data['patientUid'] as String?)?.trim() ?? '';
    if (doctorId.isEmpty || patientUid.isEmpty) return;
    await ChatService.ensureChannelForDoctorPatient(
      doctorId: doctorId,
      patientUid: patientUid,
      doctorName: (data['doctorName'] as String?)?.trim() ?? '',
      doctorImageUrl: (data['doctorImageUrl'] as String?)?.trim() ?? '',
      patientName: (data['patientName'] as String?)?.trim() ?? '',
      patientImageUrl: (data['patientImageUrl'] as String?)?.trim() ?? '',
      requestId: state.requestId,
    );
  }

  @override
  void initState() {
    super.initState();
    _authUserSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      _linkSub?.cancel();
      _linkSub = null;
      if (user == null) {
        if (mounted) {
          setState(_applySignedOutState);
          widget.onLinkStageChanged?.call(DoctorPatientLinkStage.connect);
        } else {
          _applySignedOutState();
        }
        return;
      }
      _bindDoctorRequestStream(user.uid);
    });
  }

  @override
  void dispose() {
    _authUserSub?.cancel();
    _linkSub?.cancel();
    super.dispose();
  }

  DoctorPatientLinkStage _publicStageFor(_DoctorHomePatientStage stage) {
    switch (stage) {
      case _DoctorHomePatientStage.connect:
        return DoctorPatientLinkStage.connect;
      case _DoctorHomePatientStage.pending:
        return DoctorPatientLinkStage.pending;
      case _DoctorHomePatientStage.dashboard:
        return DoctorPatientLinkStage.linked;
    }
  }

  void _applyLinkStreamState(DoctorLinkStreamState state) {
    switch (state.phase) {
      case DoctorLinkUiPhase.connect:
        _stage = _DoctorHomePatientStage.connect;
        _resolvedPatient = null;
        _patientCode = '';
        break;
      case DoctorLinkUiPhase.pending:
        _stage = _DoctorHomePatientStage.pending;
        final data = state.requestData;
        if (data != null) {
          _resolvedPatient = PatientPublicProfile.fromDoctorLinkRequest(data);
          _patientCode = _resolvedPatient!.patientId;
        }
        break;
      case DoctorLinkUiPhase.linked:
        _stage = _DoctorHomePatientStage.dashboard;
        final data = state.requestData;
        if (data != null) {
          _resolvedPatient = PatientPublicProfile.fromDoctorLinkRequest(data);
          _patientCode = _resolvedPatient!.patientId;
        }
        break;
    }
  }

  void _bindDoctorRequestStream(String doctorUid) {
    _linkSub?.cancel();
    if (mounted) {
      setState(() => _bootstrapLoading = true);
    }
    _linkSub = DoctorLinkRequestService.watchDoctorLinkUiState(doctorUid)
        .listen(
          (state) {
            unawaited(_ensureLinkedChatChannel(state));
            if (!mounted) return;
            setState(() {
              _bootstrapLoading = false;
              _applyLinkStreamState(state);
            });
            widget.onLinkStageChanged?.call(_publicStageFor(_stage));
          },
          onError: (_) {
            if (!mounted) return;
            setState(() {
              _bootstrapLoading = false;
              _stage = _DoctorHomePatientStage.connect;
              _resolvedPatient = null;
              _patientCode = '';
            });
            widget.onLinkStageChanged?.call(DoctorPatientLinkStage.connect);
          },
        );
  }

  void _applySignedOutState() {
    _linkSub?.cancel();
    _linkSub = null;
    _resolvedPatient = null;
    _patientCode = '';
    _stage = _DoctorHomePatientStage.connect;
    _bootstrapLoading = false;
  }

  static String _greetingForNow(AppLocalizations l10n) {
    final h = DateTime.now().hour;
    if (h < 12) return l10n.homeGreetingGoodMorning;
    if (h < 18) return l10n.homeGreetingGoodAfternoon;
    return l10n.homeGreetingGoodEvening;
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n, User? user) {
    final displayName = user?.displayName?.trim() ?? '';
    final emailLocal = user?.email?.split('@').first.trim() ?? '';
    final name = displayName.isNotEmpty
        ? displayName
        : (emailLocal.isNotEmpty ? emailLocal : l10n.guestUser);
    final imageUrl = user?.photoURL ?? '';
    final date = MaterialLocalizations.of(
      context,
    ).formatFullDate(DateTime.now());

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white,
          backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
          child: imageUrl.isEmpty
              ? const Icon(
                  Icons.person_outline,
                  size: 26,
                  color: Colors.black87,
                )
              : null,
        ),
        const SizedBox(width: Dimensions.verticalSpacingRegular),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_greetingForNow(l10n)}, $name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingExtraShort),
              Text(
                date,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        const AppNotificationsAction(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authAsync = ref.watch(authStateChangesProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(appHorizontalPadding),
        child: authAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          error: (_, __) => _buildShell(context, l10n, null),
          data: (user) => _buildShell(context, l10n, user),
        ),
      ),
    );
  }

  Widget _buildShell(BuildContext context, AppLocalizations l10n, User? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context, l10n, user),
        const SizedBox(height: Dimensions.verticalSpacingMedium),
        Expanded(
          child: _bootstrapLoading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: KeyedSubtree(
                    key: ValueKey(_stage),
                    child: _stageBody(),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _stageBody() {
    switch (_stage) {
      case _DoctorHomePatientStage.connect:
        return const DoctorConnectWithPatientPage();
      case _DoctorHomePatientStage.pending:
        return DoctorPatientAccessPendingPage(
          patientCode: _patientCode,
          patient: _resolvedPatient,
        );
      case _DoctorHomePatientStage.dashboard:
        return DoctorPatientCareDashboardPage(
          patient: _resolvedPatient!,
          onOpenChatTab: () => widget.onSelectTab?.call(1),
          onOpenMedicineTab: () => widget.onSelectTab?.call(3),
        );
    }
  }
}
