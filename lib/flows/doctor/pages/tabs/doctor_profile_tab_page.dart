import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/models/activity_item.dart';
import '../../../../core/models/medicine_item.dart';
import '../../../../core/models/patient_public_profile.dart';
import '../../../../core/providers/doctor_link_ui_provider.dart';
import '../../../../core/providers/user_profile_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/activity_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/doctor_link_request_service.dart';
import '../../../../core/services/medicine_service.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../pationt/widgets/language_picker_sheet.dart';

/// Caregiver profile: gradient shell (from [MemoroApp]) + frosted cards, quick info,
/// and settings rows aligned with the caregiver profile spec.
class DoctorProfileTabPage extends ConsumerWidget {
  const DoctorProfileTabPage({super.key, this.onBackToHome});

  final VoidCallback? onBackToHome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final authAsync = ref.watch(authStateChangesProvider);
    final linkAsync = ref.watch(doctorLinkUiStateProvider);

    final user = authAsync.asData?.value;
    final doctorUid = user?.uid.trim() ?? '';
    final displayName = _resolveDisplayName(l10n, user);
    final photoUrl = user?.photoURL?.trim() ?? '';

    final linkState =
        linkAsync.asData?.value ??
        const DoctorLinkStreamState(phase: DoctorLinkUiPhase.connect);
    final linkedProfile = _linkedPatientProfile(linkState);
    final linkedPatientUid = linkedProfile?.uid.trim() ?? '';
    final linkedPatientLabel = _linkedPatientLabel(l10n, linkState);

    return SafeArea(
      child: Padding(
        padding: appPadding,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).maybePop();
                      } else {
                        onBackToHome?.call();
                      }
                    },
                  ),
                  Expanded(
                    child: Text(
                      l10n.tabProfile,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    tooltip: l10n.doctorProfileEditProfileTooltip,
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRouter.settings);
                    },
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColorPalette.blueSteel.withValues(
                        alpha: 0.7,
                      ),
                      backgroundImage: photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : null,
                      child: photoUrl.isEmpty
                          ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 38,
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              Text(
                displayName,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingShort),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.horizontalSpacingMedium,
                  vertical: Dimensions.verticalSpacingShort,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E5D78),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.doctorProfileCaregiverRole,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              Text(
                l10n.doctorProfileQuickInfoTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingShort),
              _infoCard(
                context: context,
                icon: const Icon(
                  Icons.person_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                iconBg: AppColorPalette.blueSteel,
                title: l10n.doctorProfileLinkedPatientTitle,
                subtitle: linkedPatientLabel,
                onTap: () {
                  if (linkedProfile == null || linkedPatientUid.isEmpty) return;
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => _LinkedPatientProfilePage(
                        patientUid: linkedPatientUid,
                        fallbackProfile: linkedProfile,
                      ),
                    ),
                  );
                },
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColorPalette.grey,
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingShort),
              _managedTasksCard(
                context: context,
                l10n: l10n,
                theme: theme,
                doctorUid: doctorUid,
                patientUid: linkedPatientUid,
                onTap: onBackToHome,
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              Text(
                l10n.settingsScreenTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingShort),
              _menuTile(
                context: context,
                icon: Icons.settings_rounded,
                iconColor: AppColorPalette.grey,
                iconBackgroundColor: const Color(0xFFF3F4F6),
                title: l10n.settingsScreenTitle,
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRouter.settings),
              ),
              const SizedBox(height: Dimensions.verticalSpacingShort),
              _menuTile(
                context: context,
                icon: Icons.warning_amber_rounded,
                iconColor: AppColorPalette.redBright,
                iconBackgroundColor: const Color(0xFFFFE4E4),
                title: l10n.profileSosSettings,
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRouter.sosSettings),
              ),
              const SizedBox(height: Dimensions.verticalSpacingShort),
              _menuTile(
                context: context,
                icon: Icons.notifications_outlined,
                iconColor: const Color(0xFFB45309),
                iconBackgroundColor: const Color(0xFFFFF4D6),
                title: l10n.settingsNotificationsTitle,
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRouter.notifications),
              ),
              const SizedBox(height: Dimensions.verticalSpacingShort),
              _menuTile(
                context: context,
                icon: Icons.language_rounded,
                iconColor: AppColorPalette.grey,
                iconBackgroundColor: const Color(0xFFF3F4F6),
                title: l10n.languageLabel,
                onTap: () => showLanguagePickerSheet(context),
              ),
              const SizedBox(height: Dimensions.verticalSpacingShort),
              InkWell(
                onTap: () async {
                  await AuthService.logout();
                  if (!context.mounted) return;
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(AppRouter.chooseFlow, (_) => false);
                },
                borderRadius: BorderRadius.circular(
                  Dimensions.cardCornerRadius,
                ),
                child: Container(
                  width: double.infinity,
                  padding: appPadding,
                  decoration: BoxDecoration(
                    color: AppColorPalette.peachPink.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(
                      Dimensions.cardCornerRadius,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFFFD5D8),
                        child: const Icon(
                          Icons.logout_rounded,
                          color: AppColorPalette.redBright,
                          size: 20,
                        ),
                      ),
                      const SizedBox(
                        width: Dimensions.horizontalSpacingRegular,
                      ),
                      Text(
                        l10n.logoutButton,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColorPalette.redBright,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: bottomNavigationBarPadding),
            ],
          ),
        ),
      ),
    );
  }

  static String _resolveDisplayName(AppLocalizations l10n, User? user) {
    if (user == null) return l10n.guestUser;
    final dn = user.displayName?.trim() ?? '';
    if (dn.isNotEmpty) return dn;
    final email = user.email?.trim() ?? '';
    if (email.isNotEmpty) return email.split('@').first;
    return l10n.guestUser;
  }

  static String _linkedPatientLabel(
    AppLocalizations l10n,
    DoctorLinkStreamState state,
  ) {
    if (state.phase != DoctorLinkUiPhase.linked || state.requestData == null) {
      return l10n.doctorProfileNotLinkedPatient;
    }
    final profile = PatientPublicProfile.fromDoctorLinkRequest(
      state.requestData!,
    );
    final n = profile.name.trim();
    if (n.isEmpty) return l10n.doctorProfileNotLinkedPatient;
    return n;
  }

  static PatientPublicProfile? _linkedPatientProfile(DoctorLinkStreamState state) {
    if (state.phase != DoctorLinkUiPhase.linked || state.requestData == null) {
      return null;
    }
    return PatientPublicProfile.fromDoctorLinkRequest(state.requestData!);
  }

  static Widget _managedTasksCard({
    required BuildContext context,
    required AppLocalizations l10n,
    required ThemeData theme,
    required String doctorUid,
    required String patientUid,
    required VoidCallback? onTap,
  }) {
    final canLoad = doctorUid.isNotEmpty && patientUid.isNotEmpty;
    if (!canLoad) {
      return _infoCard(
        context: context,
        icon: Icon(
          Icons.checklist_rounded,
          size: 18,
          color: AppColorPalette.tealDark,
        ),
        iconBg: const Color(0xFFE4F8EA),
        title: l10n.doctorProfileManagedTasksTitle,
        subtitle: l10n.doctorProfileManagedTasksSubtitle(0),
        onTap: () => onTap?.call(),
        trailing: Text(
          '0',
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppColorPalette.emerald,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
    }
    final medicineDocId = MedicineService.buildMedicineDocId(doctorUid, patientUid);
    final activityDocId = ActivityService.buildActivityDocId(doctorUid, patientUid);
    return StreamBuilder<List<MedicineItem>>(
      stream: MedicineService.watchMedicines(medicineDocId),
      builder: (context, medSnap) {
        final meds = medSnap.data ?? const <MedicineItem>[];
        final medsActive = meds.where((m) => !m.isTaken).length;
        return StreamBuilder<List<ActivityItem>>(
          stream: ActivityService.watchActivities(activityDocId),
          builder: (context, actSnap) {
            final activities = actSnap.data ?? const <ActivityItem>[];
            final actActive = activities.where((a) => !a.isCompleted && !a.isCancelled).length;
            final managedTaskCount = medsActive + actActive;
            return _infoCard(
              context: context,
              icon: Icon(
                Icons.checklist_rounded,
                size: 18,
                color: AppColorPalette.tealDark,
              ),
              iconBg: const Color(0xFFE4F8EA),
              title: l10n.doctorProfileManagedTasksTitle,
              subtitle: l10n.doctorProfileManagedTasksSubtitle(managedTaskCount),
              onTap: () => onTap?.call(),
              trailing: Text(
                '$managedTaskCount',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColorPalette.emerald,
                  fontWeight: FontWeight.w900,
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _infoCard({
    required BuildContext context,
    required Widget icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Widget trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.cardCornerRadius),
      child: Container(
        width: double.infinity,
        padding: appPadding,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(Dimensions.cardCornerRadius),
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 18, backgroundColor: iconBg, child: icon),
            const SizedBox(width: Dimensions.horizontalSpacingRegular),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColorPalette.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColorPalette.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  static Widget _menuTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBackgroundColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.cardCornerRadius),
      child: Container(
        width: double.infinity,
        padding: appPadding,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(Dimensions.cardCornerRadius),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: iconBackgroundColor,
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: Dimensions.horizontalSpacingRegular),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColorPalette.black,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColorPalette.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkedPatientProfilePage extends StatelessWidget {
  const _LinkedPatientProfilePage({
    required this.patientUid,
    required this.fallbackProfile,
  });

  final String patientUid;
  final PatientPublicProfile fallbackProfile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final patientRef = FirebaseFirestore.instance
        .collection(AuthService.usersCollection)
        .doc(AuthService.patientsHubDocId)
        .collection(AuthService.patientUsersSubcollection)
        .doc(patientUid);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.doctorProfileLinkedPatientTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: appPadding,
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: patientRef.snapshots(),
            builder: (context, snap) {
              final fromDb = snap.hasData
                  ? PatientPublicProfile.fromDocumentSnapshot(snap.data!)
                  : null;
              final profile = fromDb ?? fallbackProfile;
              final imageUrl = profile.imageUrl.trim();
              final name = profile.name.trim().isNotEmpty
                  ? profile.name.trim()
                  : l10n.profilePlaceholderUserName;
              final age = profile.age != null ? '${profile.age}' : '—';
              final gender = profile.gender.trim().isNotEmpty
                  ? profile.gender.trim()
                  : '—';
              final patientId = profile.patientId.trim().isNotEmpty
                  ? profile.patientId.trim()
                  : '—';
              final phone = profile.phone.trim().isNotEmpty
                  ? profile.phone.trim()
                  : '—';

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: Colors.white,
                      backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                      child: imageUrl.isEmpty
                          ? const Icon(
                              Icons.person_rounded,
                              size: 44,
                              color: AppColorPalette.blueSteel,
                            )
                          : null,
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingRegular),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingRegular),
                    _profileDataCard(
                      context,
                      title: l10n.doctorPatientIdLabel,
                      value: patientId,
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingShort),
                    _profileDataCard(
                      context,
                      title: l10n.ageHint,
                      value: age,
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingShort),
                    _profileDataCard(
                      context,
                      title: l10n.genderLabel,
                      value: gender,
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingShort),
                    _profileDataCard(
                      context,
                      title: l10n.phoneHint,
                      value: phone,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _profileDataCard(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: appPadding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(Dimensions.cardCornerRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColorPalette.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColorPalette.blueSteel,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
