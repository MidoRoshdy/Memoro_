import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/models/activity_item.dart';
import '../../../../core/services/activity_service.dart';
import '../../../../core/services/doctor_link_request_service.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../core/usecases/notification_usecases.dart';
import '../../../../l10n/app_localizations.dart';

class PatientActivityPage extends StatelessWidget {
  const PatientActivityPage({super.key});

  Widget _activityCard(
    BuildContext context, {
    required ActivityItem item,
    required String activityDocId,
    required AppLocalizations l10n,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final scheduledTime = item.scheduledTime.trim();
    final subtitleParts = <String>[
      item.type,
      if (item.target.trim().isNotEmpty) item.target.trim(),
    ];

    return Container(
      margin: const EdgeInsets.only(
        left: appHorizontalPadding,
        right: appHorizontalPadding,
        bottom: Dimensions.verticalSpacingRegular,
      ),
      padding: const EdgeInsets.all(Dimensions.verticalSpacingRegular),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColorPalette.gold.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_walk_rounded,
                  color: AppColorPalette.brownOlive,
                ),
              ),
              const SizedBox(width: Dimensions.verticalSpacingShort),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(
                      height: Dimensions.verticalSpacingExtraShort,
                    ),
                    Text(
                      subtitleParts.join(' . '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColorPalette.grey,
                        fontWeight: FontWeight.w500,
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColorPalette.blueSteel.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: AppColorPalette.blueSteel,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      scheduledTime.isEmpty ? '--:--' : scheduledTime,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColorPalette.blueSteel,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              item.isCompleted
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColorPalette.emerald.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColorPalette.emerald,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.doctorActivityDoneButton,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColorPalette.emerald,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    )
                  : FilledButton(
                      onPressed: () => MarkActivityDoneUseCase().execute(
                        activityDocId: activityDocId,
                        activityItemId: item.id,
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColorPalette.blueSteel,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(108, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(l10n.doctorActivityDoneButton),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList(
    BuildContext context, {
    required String activityDocId,
    required AppLocalizations l10n,
  }) {
    return StreamBuilder<List<ActivityItem>>(
      stream: ActivityService.watchActivities(activityDocId),
      builder: (context, snap) {
        final activities = (snap.data ?? const <ActivityItem>[])
            .where((e) => e.isVisibleForPatient)
            .toList();
        Future.microtask(() async {
          final scheduler = ScheduleActivityReminderUseCase();
          for (final activity in activities.where((e) => !e.isCompleted)) {
            await scheduler.execute(item: activity, pairId: activityDocId);
          }
        });
        if (activities.isEmpty) {
          return Center(child: Text(l10n.doctorActivityNoActivitiesYet));
        }
        return ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final item = activities[index];
            return _activityCard(
              context,
              item: item,
              activityDocId: activityDocId,
              l10n: l10n,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final patientUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (patientUid.isEmpty) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.quickActionActivity,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: StreamBuilder<QueryDocumentSnapshot<Map<String, dynamic>>?>(
        stream: DoctorLinkRequestService.watchLatestAcceptedForPatient(
          patientUid,
        ),
        builder: (context, linkSnap) {
          final request = linkSnap.data;
          final data = request?.data();
          final doctorUid = (data?['doctorId'] as String?)?.trim() ?? '';
          if (doctorUid.isNotEmpty) {
            final activityDocId = ActivityService.buildActivityDocId(
              doctorUid,
              patientUid,
            );
            return Padding(
              padding: EdgeInsets.only(top: appVerticalPadding + 16),
              child: _buildActivityList(
                context,
                activityDocId: activityDocId,
                l10n: l10n,
              ),
            );
          }

          return Center(
            child: Text(
              l10n.doctorMedConnectFirst,
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }
}
