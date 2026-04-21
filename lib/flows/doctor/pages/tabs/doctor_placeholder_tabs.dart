import 'package:flutter/material.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../medicine/doctor_medicine_page.dart';

/// Patient-style “coming soon” shell for caregiver tabs that are not implemented yet.
class DoctorChatTabPage extends StatelessWidget {
  const DoctorChatTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _DoctorComingSoonTab(
      icon: Icons.chat_bubble_outline_rounded,
      title: l10n.tabChat,
    );
  }
}

class DoctorGamesTabPage extends StatelessWidget {
  const DoctorGamesTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _DoctorComingSoonTab(
      icon: Icons.sports_esports_outlined,
      title: l10n.tabGames,
    );
  }
}

class DoctorMedicineTabPage extends StatelessWidget {
  const DoctorMedicineTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DoctorMedicinePage();
  }
}

class _DoctorComingSoonTab extends StatelessWidget {
  const _DoctorComingSoonTab({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: appPadding,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 56, color: Colors.white.withValues(alpha: 0.92)),
              const SizedBox(height: Dimensions.verticalSpacingMedium),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingShort),
              Text(
                l10n.comingSoonLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              Container(
                width: double.infinity,
                padding: appPadding,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(
                    Dimensions.cardCornerRadius,
                  ),
                ),
                child: Text(
                  l10n.chooseFlowCaregiverComingSoon,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColorPalette.grey,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
