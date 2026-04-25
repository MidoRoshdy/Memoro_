import 'package:flutter/material.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/models/activity_item.dart';
import '../../../../core/services/activity_service.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';
import 'doctor_assign_activity_page.dart';
import 'doctor_activity_details_page.dart';

class DoctorActivityPage extends StatelessWidget {
  const DoctorActivityPage({
    super.key,
    required this.doctorUid,
    required this.patientUid,
    required this.patientName,
  });

  final String doctorUid;
  final String patientUid;
  final String patientName;

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'water':
        return Icons.water_drop_rounded;
      case 'exercise':
        return Icons.directions_run_rounded;
      case 'breathing':
        return Icons.air_rounded;
      default:
        return Icons.checklist_rounded;
    }
  }

  String _typeLabel(AppLocalizations l10n, String type) {
    switch (type.trim().toLowerCase()) {
      case 'water':
        return l10n.doctorActivityTypeWater;
      case 'exercise':
        return l10n.doctorActivityTypeExercise;
      case 'breathing':
        return l10n.doctorActivityTypeBreathing;
      case 'other':
        return l10n.doctorActivityTypeOther;
      default:
        return type.trim().isNotEmpty ? type : l10n.doctorActivityTypeOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activityDocId = ActivityService.buildActivityDocId(doctorUid, patientUid);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.doctorActivitiesTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: appPadding,
          child: StreamBuilder<List<ActivityItem>>(
            stream: ActivityService.watchActivities(activityDocId),
            builder: (context, snap) {
              final items = snap.data ?? const <ActivityItem>[];
              final completed = items.where((e) => e.isCompleted).length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(Dimensions.verticalSpacingRegular),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(0xFFE6F2FF),
                          child: Icon(
                            Icons.person_outline_rounded,
                            color: AppColorPalette.blueSteel,
                          ),
                        ),
                        const SizedBox(width: Dimensions.horizontalSpacingRegular),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patientName,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                l10n.doctorActivitiesCompletedCount(completed),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColorPalette.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensions.verticalSpacingRegular),
                  Expanded(
                    child: items.isEmpty
                        ? Center(
                            child: Text(
                              l10n.doctorActivityNoActivitiesYet,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColorPalette.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final completedColor = item.isCompleted
                                  ? AppColorPalette.emerald
                                  : AppColorPalette.blueSteel;
                              return Container(
                                margin: const EdgeInsets.only(
                                  bottom: Dimensions.verticalSpacingShort,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.93),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
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
                                  leading: CircleAvatar(
                                    backgroundColor: completedColor.withValues(
                                      alpha: 0.15,
                                    ),
                                    child: Icon(
                                      _iconForType(item.type),
                                      color: completedColor,
                                    ),
                                  ),
                                  title: Text(
                                    item.title,
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${_typeLabel(l10n, item.type)} . ${item.scheduledTime}${item.target.isNotEmpty ? ' . ${item.target}' : ''}',
                                  ),
                                  trailing: item.isCompleted
                                      ? const Icon(
                                          Icons.check_circle_rounded,
                                          color: AppColorPalette.emerald,
                                        )
                                      : FilledButton(
                                          onPressed: () async {
                                            await ActivityService.markCompleted(
                                              activityDocId: activityDocId,
                                              activityItemId: item.id,
                                            );
                                          },
                                          style: FilledButton.styleFrom(
                                            backgroundColor: AppColorPalette.blueSteel,
                                            foregroundColor: Colors.white,
                                            minimumSize: const Size(88, 36),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: Text(
                                            l10n.doctorActivityDoneButton,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
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
        backgroundColor: AppColorPalette.blueSteel,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.doctorAssignActivity),
      ),
    );
  }
}
