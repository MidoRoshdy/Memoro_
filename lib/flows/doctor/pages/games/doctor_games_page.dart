import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/models/activity_item.dart';
import '../../../../core/services/doctor_link_request_service.dart';
import '../../../../core/services/activity_service.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../core/services/games_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../activity/doctor_assign_activity_page.dart';
import '../activity/doctor_activity_details_page.dart';
import 'doctor_assigned_games_page.dart';

class DoctorGamesPage extends StatefulWidget {
  const DoctorGamesPage({super.key});

  @override
  State<DoctorGamesPage> createState() => _DoctorGamesPageState();
}

class _DoctorGamesPageState extends State<DoctorGamesPage> {
  (int, int)? _parse24HourTime(String value) {
    final parts = value.trim().split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return (hour, minute);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final doctorUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (doctorUid.isEmpty) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<DoctorLinkStreamState>(
      stream: DoctorLinkRequestService.watchDoctorLinkUiState(doctorUid),
      builder: (context, linkSnap) {
        final linkState = linkSnap.data;
        final linkData = linkState?.requestData;
        final linked = linkState?.phase == DoctorLinkUiPhase.linked;
        final patientUid = linked
            ? (linkData?['patientUid'] as String?)?.trim() ?? ''
            : '';
        if (patientUid.isEmpty) {
          return SafeArea(
            child: Padding(
              padding: appPadding,
              child: Center(
                child: Text(
                  l10n.doctorMedConnectFirst,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }

        final activityDocId = ActivityService.buildActivityDocId(
          doctorUid,
          patientUid,
        );
        final patientName =
            (linkData?['patientName'] as String?)?.trim().isNotEmpty == true
            ? (linkData!['patientName'] as String).trim()
            : l10n.profilePlaceholderUserName;
        final gamesDocId = GamesService.buildGamesDocId(doctorUid, patientUid);

        return SafeArea(
          child: StreamBuilder<List<ActivityItem>>(
            stream: ActivityService.watchActivities(activityDocId),
            builder: (context, snap) {
              final activities = snap.data ?? const <ActivityItem>[];
              final now = DateTime.now();
              final totalActivities = activities.length;
              final takenToday = activities.where((e) => e.isCompleted).length;
              final missed = activities.where((e) {
                if (e.isCompleted) return false;
                final parsed = _parse24HourTime(e.scheduledTime);
                if (parsed == null) return false;
                final scheduled = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  parsed.$1,
                  parsed.$2,
                );
                return scheduled.isBefore(now);
              }).length;
              final progressValue = totalActivities == 0
                  ? 0.0
                  : (takenToday / totalActivities).clamp(0.0, 1.0);
              final firstMissed = activities.firstWhere(
                (e) {
                  if (e.isCompleted) return false;
                  final parsed = _parse24HourTime(e.scheduledTime);
                  if (parsed == null) return false;
                  final scheduled = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    parsed.$1,
                    parsed.$2,
                  );
                  return scheduled.isBefore(now);
                },
                orElse: () => const ActivityItem(
                  id: '',
                  title: '',
                  type: '',
                  target: '',
                  notes: '',
                  scheduledTime: '',
                  status: '',
                  level: 0,
                  scorePercent: 0,
                  timeTakenMinutes: 0,
                  correctMatches: 0,
                  totalAttempts: 0,
                  isVisibleForPatient: true,
                  assignedByName: '',
                  createdByUid: '',
                  createdAt: null,
                  updatedAt: null,
                  completedAt: null,
                ),
              );

              return SingleChildScrollView(
                padding: appPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.tabActivity,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        IconButton(
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
                          icon: const CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.add_rounded,
                              color: AppColorPalette.blueSteel,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingRegular),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                        Dimensions.verticalSpacingRegular,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: AppColorPalette.redBright,
                          ),
                          const SizedBox(
                            width: Dimensions.horizontalSpacingShort,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.doctorMedRequiresAttention,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: AppColorPalette.redDark,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(
                                  height: Dimensions.verticalSpacingExtraShort,
                                ),
                                Text(
                                  firstMissed.id.isEmpty
                                      ? l10n.doctorActivityNoMissedNow
                                      : l10n.doctorActivityLatestWithTime(
                                          firstMissed.title,
                                          firstMissed.scheduledTime,
                                        ),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColorPalette.redDark,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: Dimensions.horizontalSpacingShort,
                          ),
                          FilledButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => DoctorAssignedGamesPage(
                                    gamesDocId: gamesDocId,
                                    doctorUid: doctorUid,
                                    patientUid: patientUid,
                                  ),
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColorPalette.redBright,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(86, 36),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            child: Text(l10n.doctorActivityAssignedGames),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingRegular),
                    _statCard(
                      context: context,
                      title: l10n.doctorActivityTotal,
                      value: totalActivities.toString().padLeft(2, '0'),
                      icon: Icons.assignment_outlined,
                      cardColor: Colors.white.withValues(alpha: 0.95),
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingShort),
                    _statCard(
                      context: context,
                      title: l10n.doctorActivityTakenToday,
                      value: takenToday.toString().padLeft(2, '0'),
                      icon: Icons.check_circle_outline_rounded,
                      cardColor: Colors.white.withValues(alpha: 0.95),
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingShort),
                    _statCard(
                      context: context,
                      title: l10n.doctorActivityMissed,
                      value: missed.toString().padLeft(2, '0'),
                      icon: Icons.event_busy_outlined,
                      cardColor: const Color(0xFFFFF2F2),
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingRegular),
                    Container(
                      width: double.infinity,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.doctorActivityWeeklyProgress,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              Text(
                                '${takenToday}/$totalActivities',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: AppColorPalette.blueSteel,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: Dimensions.verticalSpacingShort,
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: progressValue,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFE8EEF2),
                              color: AppColorPalette.blueSteel,
                            ),
                          ),
                          const SizedBox(
                            height: Dimensions.verticalSpacingShort,
                          ),
                          Text(
                            l10n.doctorActivityWeeklySubtitle,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColorPalette.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingRegular),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.doctorActivitiesTitle,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        Text(
                          MaterialLocalizations.of(
                            context,
                          ).formatMediumDate(DateTime.now()),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingShort),
                    if (activities.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(
                          Dimensions.verticalSpacingRegular,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(l10n.doctorActivityNoActivitiesYet),
                      )
                    else
                      ...activities
                          .take(4)
                          .map(
                            (item) => InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => DoctorActivityDetailsPage(
                                      activityDocId: activityDocId,
                                      activityItemId: item.id,
                                      doctorUid: doctorUid,
                                      patientUid: patientUid,
                                      patientName: patientName,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                margin: const EdgeInsets.only(
                                  bottom: Dimensions.verticalSpacingShort,
                                ),
                                padding: const EdgeInsets.all(
                                  Dimensions.verticalSpacingRegular,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.94),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title.isEmpty
                                                ? l10n.doctorAssignActivity
                                                : item.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const SizedBox(
                                            height: Dimensions
                                                .verticalSpacingExtraShort,
                                          ),
                                          Text(
                                            item.scheduledTime,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: AppColorPalette.grey,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      item.isCompleted
                                          ? l10n.doctorActivityDoneButton
                                          : l10n.doctorMedStatusUpcoming,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color: item.isCompleted
                                                ? AppColorPalette.emerald
                                                : AppColorPalette.brownOlive,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: Dimensions.verticalSpacingShort),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                        Dimensions.verticalSpacingLarge,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.doctorActivityRecentResultTitle,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: AppColorPalette.blueSteel,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(
                            height: Dimensions.verticalSpacingRegular,
                          ),
                          Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: AppColorPalette.blueSteel,
                                  width: 5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  l10n.doctorWellnessPercent(
                                    '${(progressValue * 100).round()}',
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: AppColorPalette.blueSteel,
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: Dimensions.verticalSpacingShort,
                                ),
                                Text(
                                  activities.isNotEmpty
                                      ? activities.first.title
                                      : patientName,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  l10n.doctorActivityRecentResultSubtitle,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppColorPalette.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                        icon: const Icon(Icons.add_rounded),
                        label: Text(l10n.doctorAssignActivity),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColorPalette.blueSteel,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingShort),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => DoctorAssignedGamesPage(
                                gamesDocId: gamesDocId,
                                doctorUid: doctorUid,
                                patientUid: patientUid,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.insights_outlined),
                        label: Text(l10n.doctorActivityAssignedGames),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColorPalette.blueSteel,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          backgroundColor: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _statCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color cardColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.verticalSpacingRegular),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColorPalette.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: Dimensions.verticalSpacingExtraShort),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColorPalette.blueSteel,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: AppColorPalette.lightGrey),
        ],
      ),
    );
  }
}
