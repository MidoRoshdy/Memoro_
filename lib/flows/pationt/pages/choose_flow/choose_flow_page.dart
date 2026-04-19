import 'package:flutter/material.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/string_assets.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../../widgets/language_switch_icon.dart';

class ChooseFlowPage extends StatelessWidget {
  const ChooseFlowPage({super.key});

  Widget _flowCard({
    required BuildContext context,
    required String imagePath,
    required String label,
    required VoidCallback onTap,
    bool enabled = true,
    String? badgeText,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(90),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: enabled ? 1 : 0.6,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.85),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(imagePath, fit: BoxFit.cover),
                  ),
                ),
                if (badgeText != null)
                  PositionedDirectional(
                    top: -8,
                    start: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.horizontalSpacingShort,
                        vertical: Dimensions.verticalSpacingExtraShort,
                      ),
                      decoration: BoxDecoration(
                        color: AppColorPalette.blueSteel,
                        borderRadius: BorderRadius.circular(containerRadius),
                      ),
                      child: Text(
                        badgeText,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.verticalSpacingRegular),
          Text(
            label,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              shadows: const [
                Shadow(
                  color: Color(0x4D000000),
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: appPadding,
          child: Column(
            children: [
              const Align(
                alignment: AlignmentDirectional.centerEnd,
                child: LanguageSwitchIcon(),
              ),
              const Spacer(flex: 2),
              Image.asset(
                AppAssets.memoroLogoOnly,
                width: 130,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: Dimensions.verticalSpacingXL),
              Text(
                l10n.chooseFlowTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  shadows: const [
                    Shadow(
                      color: Color(0x4D000000),
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 56),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _flowCard(
                    context: context,
                    imagePath: AppAssets.choosePatientFlow,
                    label: l10n.chooseFlowPatient,
                    onTap: () => Navigator.of(
                      context,
                    ).pushReplacementNamed(AppRouter.login),
                  ),
                  const SizedBox(width: Dimensions.horizontalSpacingMedium),
                  _flowCard(
                    context: context,
                    imagePath: AppAssets.chooseCaregiverFlow,
                    label: l10n.chooseFlowCaregiver,
                    onTap: () => Navigator.of(
                      context,
                    ).pushReplacementNamed(AppRouter.doctorLogin),
                  ),
                ],
              ),
              const Spacer(flex: 17),
            ],
          ),
        ),
      ),
    );
  }
}
