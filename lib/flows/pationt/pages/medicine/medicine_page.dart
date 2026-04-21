import 'package:flutter/material.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/string_assets.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../../widgets/app_notifications_action.dart';

class MedicinePage extends StatelessWidget {
  const MedicinePage({super.key});

  static Widget _summaryCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: appPadding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(Dimensions.cardCornerRadius),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(
                  Dimensions.horizontalSpacingMedium,
                ),
                decoration: BoxDecoration(
                  color: AppColorPalette.white,
                  borderRadius: BorderRadius.circular(containerRadius),
                ),
                child: Image.asset(
                  AppAssets.medcineicon,
                  width: 25,
                  height: 25,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: Dimensions.horizontalSpacingRegular),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.medMedicationsCount(3),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColorPalette.blueSteel,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      l10n.medDueToday,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColorPalette.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.verticalSpacingRegular),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.medProgressLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                l10n.medProgressFraction(1, 3),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColorPalette.blueSteel,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.verticalSpacingShort),
          ClipRRect(
            borderRadius: BorderRadius.circular(
              Dimensions.verticalSpacingLarge,
            ),
            child: const LinearProgressIndicator(
              minHeight: 12,
              value: 0.34,
              backgroundColor: Color(0xFFEBEEF2),
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColorPalette.emerald,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _sectionTitle(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: Dimensions.horizontalSpacingShort),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  static Widget _medCard(
    BuildContext context, {
    required Color bgColor,
    required String name,
    required String subtitle,
    required String time,
    required String buttonText,
    required Color buttonColor,
    required Color iconColor,
    required bool isTaken,
    required Color borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: appPadding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(Dimensions.cardCornerRadius),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColorPalette.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                width: 50,
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.all(
                    Dimensions.horizontalSpacingMedium,
                  ),
                  child: Image.asset(
                    AppAssets.medcineicon,
                    width: 25,
                    height: 25,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.horizontalSpacingRegular),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: Dimensions.verticalSpacingExtraShort,
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColorPalette.grey,
                      ),
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingShort),
                    Row(
                      children: [
                        const Icon(
                          Icons.watch_later_outlined,
                          size: 15,
                          color: AppColorPalette.grey,
                        ),
                        const SizedBox(
                          width: Dimensions.horizontalSpacingShort,
                        ),
                        Text(
                          time,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.verticalSpacingRegular),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(
                isTaken ? Icons.check_circle : Icons.check,
                size: 16,
                color: iconColor,
              ),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: iconColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(containerRadius),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: appPadding,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      l10n.medScreenTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const AppNotificationsAction(
                    diameter: AppNotificationsAction.compactDiameter,
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              _summaryCard(context, l10n),
              const SizedBox(height: Dimensions.verticalSpacingLarge),
              _sectionTitle(
                context,
                title: l10n.medSectionMorning,
                icon: Icons.wb_sunny_rounded,
                iconColor: AppColorPalette.emerald,
              ),
              const SizedBox(height: Dimensions.verticalSpacingShort),
              _medCard(
                context,
                bgColor: const Color(0xFFE5F5EE),
                name: l10n.medDrugAspirin,
                subtitle: l10n.medDose100mgTablet,
                time: l10n.medTime800Am,
                buttonText: l10n.homeTakenButton,
                buttonColor: const Color(0xFFB9EAD2),
                iconColor: AppColorPalette.emerald,
                isTaken: true,
                borderColor: AppColorPalette.emerald,
              ),
              const SizedBox(height: Dimensions.verticalSpacingMedium),
              _sectionTitle(
                context,
                title: l10n.medSectionAfternoon,
                icon: Icons.wb_twilight_rounded,
                iconColor: AppColorPalette.brownOlive,
              ),
              const SizedBox(height: Dimensions.verticalSpacingShort),
              _medCard(
                context,
                bgColor: const Color(0xFFF4F0DF),
                name: l10n.medDrugMetformin,
                subtitle: l10n.medDose500mgTablet,
                time: l10n.medTime200Pm,
                buttonText: l10n.medMarkAsTaken,
                buttonColor: const Color(0xFFF9E3B9),
                iconColor: AppColorPalette.brownOlive,
                isTaken: false,
                borderColor: AppColorPalette.brownOlive,
              ),
              const SizedBox(height: Dimensions.verticalSpacingMedium),
              _sectionTitle(
                context,
                title: l10n.medSectionEvening,
                icon: Icons.nights_stay_rounded,
                iconColor: AppColorPalette.blueBright,
              ),
              const SizedBox(height: Dimensions.verticalSpacingShort),
              _medCard(
                context,
                bgColor: const Color(0xFFEBEFF7),
                name: l10n.medDrugVitaminD,
                subtitle: l10n.medDose1000IuCapsule,
                time: l10n.medTime700Pm,
                buttonText: l10n.medMarkAsTaken,
                buttonColor: const Color(0xFFD6DFF4),
                iconColor: AppColorPalette.blueBright,
                isTaken: false,
                borderColor: AppColorPalette.blueBright,
              ),
              const SizedBox(height: bottomNavigationBarPadding),
            ],
          ),
        ),
      ),
    );
  }
}
