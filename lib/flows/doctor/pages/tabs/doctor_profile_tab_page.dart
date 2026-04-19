import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/models/patient_public_profile.dart';
import '../../../../core/providers/doctor_link_ui_provider.dart';
import '../../../../core/providers/user_profile_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/doctor_link_request_service.dart';
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
    final displayName = _resolveDisplayName(l10n, user);
    final photoUrl = user?.photoURL?.trim() ?? '';

    final linkState =
        linkAsync.asData?.value ??
        const DoctorLinkStreamState(phase: DoctorLinkUiPhase.connect);
    final linkedPatientLabel = _linkedPatientLabel(l10n, linkState);
    const managedTaskCount = 0;

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
                onTap: () => onBackToHome?.call(),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColorPalette.grey,
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingShort),
              _infoCard(
                context: context,
                icon: Icon(
                  Icons.checklist_rounded,
                  size: 18,
                  color: AppColorPalette.tealDark,
                ),
                iconBg: const Color(0xFFE4F8EA),
                title: l10n.doctorProfileManagedTasksTitle,
                subtitle: l10n.doctorProfileManagedTasksSubtitle(
                  managedTaskCount,
                ),
                onTap: () => onBackToHome?.call(),
                trailing: Text(
                  '$managedTaskCount',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColorPalette.emerald,
                    fontWeight: FontWeight.w900,
                  ),
                ),
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
