import 'package:flutter/material.dart';
import 'package:memoro/core/constants/string_assets.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/models/patient_public_profile.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';

const double _doctorCardRadius = 16;

const Color _doctorAccentBlue = Color(0xFF7EC8EB);

const double _emergencyButtonRadius = 8;

/// Pinkish-white emergency card surface.
const Color _emergencyCardSurface = Color(0xFFFFF7F7);

/// Medium red for patient name and timestamp on the emergency card.
const Color _emergencySecondaryRed = Color(0xFFC62828);

class DoctorPatientCareDashboardPage extends StatelessWidget {
  const DoctorPatientCareDashboardPage({
    super.key,
    required this.patient,
    required this.onOpenChatTab,
    required this.onOpenMedicineTab,
  });

  final PatientPublicProfile patient;
  final VoidCallback onOpenChatTab;
  final VoidCallback onOpenMedicineTab;

  static Widget _doctorSolidCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: appPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_doctorCardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  static Widget _doctorDashedCard({required Widget child}) {
    return CustomPaint(
      foregroundPainter: _DoctorDashBorderPainter(
        radius: _doctorCardRadius,
        color: _doctorAccentBlue.withValues(alpha: 0.85),
      ),
      child: _doctorSolidCard(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final displayName = patient.name.trim().isNotEmpty
        ? patient.name.trim()
        : l10n.profilePlaceholderUserName;
    final ageLabel = patient.age != null ? '${patient.age}' : '—';
    final imageUrl = patient.imageUrl.trim();
    final subtitleLines = l10n.doctorEmergencyRequestSubtitle.split('\n');
    final emergencyNameLine = subtitleLines.isNotEmpty
        ? subtitleLines.first.trim()
        : '';
    final emergencyTimeLine = subtitleLines.length > 1
        ? subtitleLines[1].trim()
        : '';

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: Dimensions.verticalSpacingShort),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _emergencyCardSurface,
                  borderRadius: BorderRadius.circular(_doctorCardRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(width: 6, color: AppColorPalette.redBright),
                      Expanded(
                        child: Padding(
                          padding: appPadding,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.warning_rounded,
                                    size: 30,
                                    color: AppColorPalette.redBright,
                                  ),
                                  const SizedBox(
                                    width: Dimensions.verticalSpacingRegular,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.doctorEmergencyRequestTitle,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  color:
                                                      AppColorPalette.redDark,
                                                  height: 1.2,
                                                ),
                                          ),
                                          if (emergencyNameLine.isNotEmpty) ...[
                                            const SizedBox(
                                              height: Dimensions
                                                  .verticalSpacingExtraShort,
                                            ),
                                            Text(
                                              emergencyNameLine,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        _emergencySecondaryRed,
                                                    height: 1.25,
                                                  ),
                                            ),
                                          ],
                                          if (emergencyTimeLine.isNotEmpty) ...[
                                            const SizedBox(
                                              height: Dimensions
                                                  .verticalSpacingExtraShort,
                                            ),
                                            Text(
                                              emergencyTimeLine,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        _emergencySecondaryRed,
                                                    height: 1.25,
                                                  ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: Dimensions.verticalSpacingRegular,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.call_rounded,
                                        size: 18,
                                      ),
                                      label: Text(l10n.doctorCallButton),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFE53935,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            _emergencyButtonRadius,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: Dimensions.verticalSpacingShort,
                                  ),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.location_on_outlined,
                                        size: 18,
                                      ),
                                      label: Text(l10n.doctorLocationButton),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(
                                          0xFFE53935,
                                        ),
                                        backgroundColor: Colors.white,
                                        side: BorderSide(
                                          color: AppColorPalette.redBright
                                              .withValues(alpha: 0.45),
                                          width: 1.2,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            _emergencyButtonRadius,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: Dimensions.verticalSpacingShort,
                                  ),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        size: 18,
                                      ),
                                      label: Text(l10n.doctorMessageButton),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(
                                          0xFFE53935,
                                        ),
                                        backgroundColor: Colors.white,
                                        side: BorderSide(
                                          color: AppColorPalette.redBright
                                              .withValues(alpha: 0.45),
                                          width: 1.2,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            _emergencyButtonRadius,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              _doctorDashedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _doctorAccentBlue,
                              width: 4,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColorPalette.blueSteel
                                .withValues(alpha: 0.12),
                            backgroundImage: imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : null,
                            child: imageUrl.isEmpty
                                ? Icon(
                                    Icons.person_rounded,
                                    size: 44,
                                    color: AppColorPalette.blueSteel,
                                  )
                                : null,
                          ),
                        ),
                        PositionedDirectional(
                          end: 4,
                          bottom: 4,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingRegular),
                    Text(
                      displayName,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF4A90E2),
                      ),
                    ),
                    const SizedBox(
                      height: Dimensions.verticalSpacingExtraShort,
                    ),
                    Text(
                      l10n.doctorPatientAgeRoom(ageLabel, '—'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingRegular),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.verticalSpacingShort + 4,
                        vertical: Dimensions.verticalSpacingExtraShort + 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColorPalette.mint.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.doctorStatusStable,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: AppColorPalette.tealDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              _doctorDashedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.doctorPatientProgressTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4A90E2),
                          ),
                        ),
                        Text(
                          l10n.doctorWellnessPercent('70'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF4A90E2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingShort),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: 0.7,
                        minHeight: 14,
                        backgroundColor: const Color(0xFFE8EEF2),
                        color: const Color(0xFF4A90E2),
                      ),
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingShort),
                    Text(
                      l10n.doctorWellnessScoreLine,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColorPalette.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingLarge),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.doctorAlertsSectionTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    l10n.doctorActiveAlertsCount(2),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColorPalette.blueSteel,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              _doctorSolidCard(
                child: Column(
                  children: [
                    _alertDetailBlock(
                      context,
                      icon: Icons.error_outline_rounded,
                      iconColor: AppColorPalette.redBright,
                      iconBg: AppColorPalette.peachPink,
                      title: l10n.doctorAlertMissedMedication,
                      detail: l10n.doctorAlertMissedMedDetail,
                      meta: l10n.doctorAlertMissedMedOverdue,
                      metaColor: AppColorPalette.redBright,
                    ),
                    Divider(
                      height: Dimensions.verticalSpacingLarge,
                      color: AppColorPalette.lightGrey.withValues(alpha: 0.5),
                    ),
                    _alertDetailBlock(
                      context,
                      icon: Icons.notifications_active_outlined,
                      iconColor: const Color(0xFFEA580C),
                      iconBg: AppColorPalette.gold.withValues(alpha: 0.45),
                      title: l10n.doctorAlertActivityReminder,
                      detail: l10n.doctorAlertActivityDetail,
                      meta: l10n.doctorAlertActivityDue,
                      metaColor: const Color(0xFFEA580C),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingLarge),
              _doctorSolidCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.medScreenTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: onOpenMedicineTab,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColorPalette.blueSteel,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            l10n.doctorMedViewAll,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppColorPalette.blueSteel,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingRegular),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.verticalSpacingRegular,
                        vertical: Dimensions.verticalSpacingRegular,
                      ),
                      decoration: BoxDecoration(
                        color: AppColorPalette.lightGrey.withValues(
                          alpha: 0.32,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.medication_rounded,
                            color: AppColorPalette.blueSteel,
                            size: 28,
                          ),
                          const SizedBox(
                            width: Dimensions.verticalSpacingRegular,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.doctorNextDoseLabel,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColorPalette.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(
                                  height: Dimensions.verticalSpacingExtraShort,
                                ),
                                Text(
                                  l10n.doctorNextDoseSchedule,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            l10n.doctorNextDoseIn,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppColorPalette.blueSteel,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingRegular),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onOpenMedicineTab,
                        icon: const Icon(Icons.add_rounded, size: 22),
                        label: Text(
                          l10n.doctorAddMedication,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColorPalette.blueSteel,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              containerRadius,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              _doctorSolidCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.doctorActivitiesTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          l10n.doctorActivitiesCompletedCount(3),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppColorPalette.emerald,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingShort),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColorPalette.mint.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: AppColorPalette.emerald,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: Dimensions.verticalSpacingShort),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.doctorTodaysProgressLabel,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColorPalette.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.verticalSpacingExtraShort,
                              ),
                              Text(
                                l10n.doctorTodaysProgressDone,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingRegular),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.calendar_month_rounded,
                          size: 22,
                        ),
                        label: Text(
                          l10n.doctorAssignActivity,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColorPalette.blueSteel,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              containerRadius,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              _doctorSolidCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.doctorFamilyMembersTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingRegular),
                    SizedBox(
                      height: 48,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: List.generate(3, (i) {
                          return PositionedDirectional(
                            start: i * 28,
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 22,
                                backgroundColor: AppColorPalette.blueSteel
                                    .withValues(alpha: 0.12 + i * 0.06),
                                child: Icon(
                                  Icons.person_outline_rounded,
                                  color: AppColorPalette.blueSteel,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingShort),
                    Text(
                      l10n.doctorFamilyAccessLine(3),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColorPalette.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingRegular),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColorPalette.blueSteel,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              containerRadius,
                            ),
                          ),
                        ),
                        child: Text(
                          l10n.doctorManageFamily,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: bottomNavigationBarPadding + 56),
            ],
          ),
        ),
        PositionedDirectional(
          end: 0,
          bottom: bottomNavigationBarPadding - 8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _roundFab(
                icon: Icons.chat_bubble_outline_rounded,
                label: l10n.doctorFloatingChat,
                onTap: onOpenChatTab,
              ),
              const SizedBox(height: Dimensions.verticalSpacingShort),
              _roundFab(
                icon: Icons.phone_in_talk_rounded,
                label: l10n.doctorFloatingCall,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _alertDetailBlock(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String detail,
    required String meta,
    required Color metaColor,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: Dimensions.verticalSpacingRegular),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingExtraShort),
              Text(
                detail,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColorPalette.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingExtraShort),
              Text(
                meta,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: metaColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _roundFab({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: label,
      child: Material(
        color: AppColorPalette.blueSteel,
        shape: const CircleBorder(),
        elevation: 4,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 52,
            height: 52,
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}

class _DoctorDashBorderPainter extends CustomPainter {
  _DoctorDashBorderPainter({required this.radius, required this.color});

  final double radius;
  final Color color;

  static const double _strokeWidth = 1.25;
  static const double _dashLength = 5;
  static const double _gapLength = 4;

  static void _paintDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    double dash,
    double gap,
  ) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final inset = _strokeWidth / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - _strokeWidth,
      size.height - _strokeWidth,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;
    _paintDashedPath(canvas, path, paint, _dashLength, _gapLength);
  }

  @override
  bool shouldRepaint(covariant _DoctorDashBorderPainter oldDelegate) {
    return oldDelegate.radius != radius || oldDelegate.color != color;
  }
}
