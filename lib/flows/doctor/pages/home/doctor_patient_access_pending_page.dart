import 'package:flutter/material.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/string_assets.dart';
import '../../../../core/models/patient_public_profile.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';

/// Soft cream panel behind the privacy notice (matches caregiver mockup).
const Color _kPrivacyCream = Color(0xFFFFF6E8);

/// Pending pill (warm orange from spec ~ #FFD180).
const Color _kPendingPillBg = Color(0xFFFFD180);

class DoctorPatientAccessPendingPage extends StatelessWidget {
  const DoctorPatientAccessPendingPage({
    super.key,
    required this.patientCode,
    this.patient,
  });

  final String patientCode;
  final PatientPublicProfile? patient;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final normalizedId = patientCode.replaceFirst(RegExp(r'^#'), '').trim();
    final idForDisplay = (patient?.patientId.isNotEmpty ?? false)
        ? patient!.patientId
        : normalizedId;
    final displayName = (patient?.name.trim().isNotEmpty ?? false)
        ? patient!.name.trim()
        : l10n.profilePlaceholderUserName;
    final imageUrl = patient?.imageUrl ?? '';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Dimensions.verticalSpacingMedium),
          Container(
            width: double.infinity,
            padding: appPadding,
            decoration: BoxDecoration(
              color: _kPrivacyCream,
              borderRadius: BorderRadius.circular(
                Dimensions.cardCornerRadius + 4,
              ),
              border: Border.all(
                color: AppColorPalette.brownOlive.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColorPalette.brownOlive,
                  size: 22,
                ),
                const SizedBox(width: Dimensions.verticalSpacingRegular),
                Expanded(
                  child: Text(
                    l10n.doctorPrivacyNoticeBody,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColorPalette.brownOlive,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.verticalSpacingLarge),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              appHorizontalPadding,
              Dimensions.verticalSpacingXL,
              appHorizontalPadding,
              Dimensions.verticalSpacingLarge,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.98),
              borderRadius: BorderRadius.circular(
                Dimensions.cardCornerRadius + 6,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 124,
                  height: 124,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 124,
                        height: 124,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColorPalette.blueSteel,
                            width: 3,
                          ),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: CircleAvatar(
                          radius: 54,
                          backgroundColor: AppColorPalette.blueSteel.withValues(
                            alpha: 0.12,
                          ),
                          backgroundImage: imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : null,
                          child: imageUrl.isEmpty
                              ? Icon(
                                  Icons.person_rounded,
                                  size: 48,
                                  color: AppColorPalette.blueSteel,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColorPalette.blueSteel,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(5),
                          child: Image.asset(
                            AppAssets.caregivershiledIcon,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.verticalSpacingLarge),
                Text(
                  displayName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: Dimensions.verticalSpacingRegular),
                Align(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.verticalSpacingLarge,
                      vertical: Dimensions.verticalSpacingShort,
                    ),
                    decoration: BoxDecoration(
                      color: AppColorPalette.blueSteel.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColorPalette.blueSteel.withValues(
                          alpha: 0.38,
                        ),
                        width: 1.4,
                      ),
                    ),
                    child: Text(
                      l10n.doctorPatientIdDisplay(idForDisplay),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColorPalette.blueSteel,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.verticalSpacingLarge),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.verticalSpacingMedium,
                    vertical: Dimensions.verticalSpacingShort,
                  ),
                  decoration: BoxDecoration(
                    color: _kPendingPillBg,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    l10n.doctorStatusPending.toUpperCase(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.verticalSpacingXL),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.verticalSpacingLarge,
              vertical: Dimensions.verticalSpacingXL + 4,
            ),
            decoration: BoxDecoration(
              color: AppColorPalette.blueSteel,
              borderRadius: BorderRadius.circular(
                Dimensions.cardCornerRadius + 6,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColorPalette.blueSteel.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    AppAssets.caregiverWaittIcon,
                    width: 38,
                    height: 38,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.hourglass_top_rounded,
                      size: 40,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.verticalSpacingRegular),
                Text(
                  l10n.doctorStatusWaitingTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: Dimensions.verticalSpacingShort),
                Text(
                  l10n.doctorStatusWaitingSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.94),
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: Dimensions.verticalSpacingMedium),
                Text(
                  l10n.doctorPendingWaitForPatient,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: bottomNavigationBarPadding),
        ],
      ),
    );
  }
}
