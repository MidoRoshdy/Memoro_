import 'package:flutter/material.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/models/activity_item.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../core/services/activity_service.dart';
import '../../../../l10n/app_localizations.dart';
import 'doctor_assign_activity_page.dart';

class DoctorActivityDetailsPage extends StatelessWidget {
  const DoctorActivityDetailsPage({
    super.key,
    required this.activityDocId,
    required this.activityItemId,
    required this.doctorUid,
    required this.patientUid,
    required this.patientName,
  });

  final String activityDocId;
  final String activityItemId;
  final String doctorUid;
  final String patientUid;
  final String patientName;

  String _statusLine(ActivityItem item, AppLocalizations l10n) {
    if (item.isCompleted) return l10n.doctorActivityDoneButton;
    if (item.isCancelled) return l10n.doctorActivityStatusCancelled;
    return l10n.doctorMedStatusUpcoming;
  }

  bool _isGameActivity(ActivityItem item) {
    final type = item.type.trim().toLowerCase();
    final title = item.title.trim().toLowerCase();
    const gameKeywords = <String>[
      'game',
      'memory',
      'math',
      'sequence',
      'recall',
      'sudoku',
      'simon',
      'chess',
      'puzzle',
    ];
    return gameKeywords.any((k) => type.contains(k) || title.contains(k));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.doctorActivityAssignDetails),
      ),
      body: SafeArea(
        child: Padding(
          padding: appPadding,
          child: StreamBuilder<ActivityItem?>(
            stream: ActivityService.watchActivityItem(activityDocId, activityItemId),
            builder: (context, snap) {
              final item = snap.data;
              if (!snap.hasData || item == null) {
                return const Center(child: CircularProgressIndicator(strokeWidth: 2));
              }

              final assignedDate = item.createdAt != null
                  ? MaterialLocalizations.of(
                      context,
                    ).formatMediumDate(item.createdAt!.toLocal())
                  : '--';

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(Dimensions.verticalSpacingRegular),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF7EE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColorPalette.emerald,
                            child: Icon(Icons.check, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: Dimensions.horizontalSpacingRegular),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _statusLine(item, l10n),
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: AppColorPalette.emerald,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  l10n.doctorActivityFinishedOnTime,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${item.scorePercent}%\n${l10n.doctorActivityScoreLabel}',
                            textAlign: TextAlign.end,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColorPalette.emerald,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingRegular),
                    Container(
                      padding: const EdgeInsets.all(Dimensions.verticalSpacingRegular),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 16,
                                backgroundColor: Color(0xFFEAF3FA),
                                child: Icon(
                                  Icons.water_drop_outlined,
                                  color: AppColorPalette.blueSteel,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: Dimensions.horizontalSpacingRegular),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.doctorActivityTypeLabel,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColorPalette.grey,
                                      ),
                                    ),
                                    Text(
                                      item.title,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppColorPalette.blueSteel,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: Dimensions.verticalSpacingRegular),
                          _metaRow(context, l10n.doctorActivityLevel, '${item.level}'),
                          _metaRow(context, l10n.doctorActivityAssignedDate, assignedDate),
                          _metaRow(
                            context,
                            l10n.doctorActivityScheduledTime,
                            item.scheduledTime,
                          ),
                          _metaRow(
                            context,
                            l10n.doctorActivityDuration,
                            '${item.timeTakenMinutes} ${l10n.doctorActivityMinutesUnit}',
                          ),
                          _metaRow(
                            context,
                            l10n.doctorActivityAssignedBy,
                            item.assignedByName.isNotEmpty
                                ? item.assignedByName
                                : patientName,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingRegular),
                    if (_isGameActivity(item)) ...[
                      Container(
                        padding: const EdgeInsets.all(
                          Dimensions.verticalSpacingRegular,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.doctorActivityPerformanceSummary,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: Dimensions.verticalSpacingRegular),
                            GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: Dimensions.horizontalSpacingRegular,
                              mainAxisSpacing: Dimensions.verticalSpacingRegular,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              childAspectRatio: 1.5,
                              children: [
                                _scoreTile(
                                  context,
                                  color: const Color(0xFFEAF7EE),
                                  value: '${item.scorePercent}%',
                                  label: l10n.doctorActivityFinalScore,
                                ),
                                _scoreTile(
                                  context,
                                  color: const Color(0xFFEAF1FB),
                                  value: '${item.timeTakenMinutes}m',
                                  label: l10n.doctorActivityTimeTaken,
                                ),
                                _scoreTile(
                                  context,
                                  color: const Color(0xFFF3ECFA),
                                  value: '${item.correctMatches}/${item.totalAttempts}',
                                  label: l10n.doctorActivityCorrectMatches,
                                ),
                                _scoreTile(
                                  context,
                                  color: const Color(0xFFFCEFD7),
                                  value: '${item.totalAttempts}',
                                  label: l10n.doctorActivityTotalAttempts,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Dimensions.verticalSpacingRegular),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.horizontalSpacingRegular,
                        vertical: Dimensions.verticalSpacingShort,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SwitchListTile(
                        value: item.isVisibleForPatient,
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.doctorActivityVisibleForPatient),
                        onChanged: (v) => ActivityService.setVisibilityForPatient(
                          activityDocId: activityDocId,
                          activityItemId: activityItemId,
                          isVisibleForPatient: v,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingRegular),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => DoctorAssignActivityPage(
                                activityDocId: activityDocId,
                                doctorUid: doctorUid,
                                patientUid: patientUid,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_rounded),
                        label: Text(l10n.doctorActivityEditActivity),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColorPalette.blueSteel,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingShort),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => ActivityService.cancelActivity(
                          activityDocId: activityDocId,
                          activityItemId: activityItemId,
                        ),
                        icon: const Icon(Icons.close_rounded),
                        label: Text(l10n.doctorActivityCancelActivity),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF2F2),
                          foregroundColor: AppColorPalette.redBright,
                        ),
                      ),
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

  Widget _metaRow(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.verticalSpacingShort),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColorPalette.grey,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _scoreTile(
    BuildContext context, {
    required Color color,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.verticalSpacingRegular),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColorPalette.blueSteel,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: Dimensions.verticalSpacingExtraShort),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
