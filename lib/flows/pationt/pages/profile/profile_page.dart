import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/string_assets.dart';
import '../../../../core/providers/user_profile_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../../widgets/language_picker_sheet.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Widget _infoCard({
    required BuildContext context,
    required Widget icon,
    required Color iconBg,
    required String title,
    required String subtitle,
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
          CircleAvatar(
            radius: 16,
            backgroundColor: iconBg,
            child: Padding(
              padding: const EdgeInsets.all(
                Dimensions.horizontalSpacingExtraShort,
              ),
              child: icon,
            ),
          ),
          const SizedBox(width: Dimensions.horizontalSpacingRegular),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColorPalette.grey),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
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
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: Dimensions.horizontalSpacingRegular),
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileState = ref.watch(currentUserProfileProvider);
    final user = profileState.asData?.value;
    final name = user?.name.trim().isNotEmpty == true
        ? user!.name
        : l10n.profilePlaceholderUserName;

    return SafeArea(
      child: Padding(
        padding: appPadding,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.profileTitleMyProfile,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColorPalette.blueSteel.withValues(
                    alpha: 0.7,
                  ),
                  backgroundImage: (user?.imageUrl ?? '').isNotEmpty
                      ? NetworkImage(user!.imageUrl)
                      : null,
                  child: (user?.imageUrl ?? '').isEmpty
                      ? const Icon(Icons.person, color: Colors.white, size: 38)
                      : null,
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              Text(
                name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(containerRadius),
                ),
                child: Text(
                  l10n.profileYouAreSafe,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColorPalette.blueSteel,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 58,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.call),
                        label: Text(l10n.profileCallCaregiver),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColorPalette.blueSteel,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.horizontalSpacingRegular),
                  Expanded(
                    child: SizedBox(
                      height: 58,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.chat_bubble_outline_rounded),
                        label: Text(l10n.profileMessageButton),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColorPalette.blueSteel,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              _infoCard(
                context: context,
                icon: Image.asset(AppAssets.caregiverIcon, fit: BoxFit.contain),
                iconBg: const Color(0xFFE8F3FF),
                title: l10n.profileYourCaregiver,
                subtitle: l10n.profilePlaceholderCaregiverName,
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              _infoCard(
                context: context,
                icon: Image.asset(
                  AppAssets.greenMedicineIcon,
                  fit: BoxFit.contain,
                ),
                iconBg: const Color(0xFFE4F8EA),
                title: l10n.profileNextMedication,
                subtitle: l10n.profilePlaceholderNextMedTime,
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              _infoCard(
                context: context,
                icon: const Icon(
                  Icons.favorite,
                  size: 16,
                  color: AppColorPalette.violet,
                ),
                iconBg: const Color(0xFFEDE7FF),
                title: l10n.profileTodaysActivity,
                subtitle: l10n.profilePlaceholderActivity,
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              _menuTile(
                context: context,
                icon: Icons.settings,
                iconColor: AppColorPalette.grey,
                title: l10n.settingsScreenTitle,
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRouter.settings),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              _menuTile(
                context: context,
                icon: Icons.shield_outlined,
                iconColor: AppColorPalette.redBright,
                title: l10n.profileSosSettings,
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRouter.sosSettings),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              _menuTile(
                context: context,
                icon: Icons.language,
                iconColor: AppColorPalette.grey,
                title: l10n.languageLabel,
                onTap: () => showLanguagePickerSheet(context),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
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
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(
                      Dimensions.cardCornerRadius,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.logout,
                        color: AppColorPalette.redBright,
                      ),
                      const SizedBox(
                        width: Dimensions.horizontalSpacingRegular,
                      ),
                      Text(
                        l10n.logoutButton,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
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
}
