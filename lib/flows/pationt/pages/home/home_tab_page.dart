import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/models/activity_item.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/constants/string_assets.dart';
import '../../../../core/models/medicine_item.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/providers/user_profile_provider.dart';
import '../../../../core/services/activity_service.dart';
import '../../../../core/services/doctor_link_request_service.dart';
import '../../../../core/services/medicine_service.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../games/memory_test_hub_page.dart';
import '../activity/patient_activity_page.dart';
import 'week_progress_calendar_page.dart';
import '../../widgets/app_notifications_action.dart';

class HomeTabPage extends ConsumerWidget {
  const HomeTabPage({super.key, this.onSelectTab});

  final ValueChanged<int>? onSelectTab;

  static int? _parseHour(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return null;
    final normalized = raw.toUpperCase();
    final isAm = normalized.contains('AM');
    final isPm = normalized.contains('PM');
    final clean = normalized.replaceAll('AM', '').replaceAll('PM', '').trim();
    final parts = clean.split(':');
    final h = int.tryParse(parts.first.trim());
    if (h == null) return null;
    if (isAm || isPm) {
      var hour = h % 12;
      if (isPm) hour += 12;
      return hour;
    }
    if (h >= 0 && h <= 23) return h;
    return null;
  }

  static int? _parseMinute(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return null;
    final normalized = raw.toUpperCase();
    final clean = normalized.replaceAll('AM', '').replaceAll('PM', '').trim();
    final parts = clean.split(':');
    if (parts.length < 2) return 0;
    final m = int.tryParse(parts[1].trim());
    if (m == null || m < 0 || m > 59) return null;
    return m;
  }

  static _NextMedicineReminder? _resolveNextReminder(
    List<MedicineItem> medicines,
  ) {
    if (medicines.isEmpty) return null;
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    _NextMedicineReminder? best;
    var bestDiff = 1 << 30;

    for (final medicine in medicines.where((m) => !m.isTaken)) {
      final times = medicine.scheduledTimes.isNotEmpty
          ? medicine.scheduledTimes
          : <String>[medicine.primaryTime, medicine.scheduledTime];
      for (final raw in times) {
        final time = raw.trim();
        if (time.isEmpty) continue;
        final h = _parseHour(time);
        final m = _parseMinute(time);
        if (h == null || m == null) continue;
        final targetMinutes = h * 60 + m;
        final diff = targetMinutes >= nowMinutes
            ? targetMinutes - nowMinutes
            : (24 * 60 - nowMinutes) + targetMinutes;
        if (diff < bestDiff) {
          bestDiff = diff;
          best = _NextMedicineReminder(
            medicine: medicine,
            timeLabel: time,
            minutesUntil: diff,
          );
        }
      }
    }
    return best;
  }

  static String _greetingForNow(AppLocalizations l10n) {
    final h = DateTime.now().hour;
    if (h < 12) return l10n.homeGreetingGoodMorning;
    if (h < 18) return l10n.homeGreetingGoodAfternoon;
    return l10n.homeGreetingGoodEvening;
  }

  static Widget _buildHeader({
    required BuildContext context,
    required AppLocalizations l10n,
    required String name,
    required String imageUrl,
  }) {
    final date = MaterialLocalizations.of(
      context,
    ).formatFullDate(DateTime.now());

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white,
          backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
          child: imageUrl.isEmpty
              ? const Icon(
                  Icons.person_outline,
                  size: 26,
                  color: Colors.black87,
                )
              : null,
        ),
        const SizedBox(width: Dimensions.verticalSpacingRegular),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_greetingForNow(l10n)}, $name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingExtraShort),
              Text(
                date,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        const AppNotificationsAction(),
      ],
    );
  }

  static Widget _buildReminderCard(
    BuildContext context,
    AppLocalizations l10n,
    UserProfile profile,
    ValueChanged<int>? onSelectTab,
  ) {
    final patientUid = profile.uid.trim();
    if (patientUid.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<QueryDocumentSnapshot<Map<String, dynamic>>?>(
      stream: DoctorLinkRequestService.watchLatestAcceptedForPatient(
        patientUid,
      ),
      builder: (context, linkSnap) {
        final doctorUid =
            (linkSnap.data?.data()['doctorId'] as String?)?.trim() ?? '';
        if (doctorUid.isEmpty) {
          return const SizedBox.shrink();
        }
        final medicineDocId = MedicineService.buildMedicineDocId(
          doctorUid,
          patientUid,
        );
        return StreamBuilder<List<MedicineItem>>(
          stream: MedicineService.watchMedicines(medicineDocId),
          builder: (context, medSnap) {
            final medicines = medSnap.data ?? const <MedicineItem>[];
            final reminder = _resolveNextReminder(medicines);
            final hasReminder = reminder != null;
            final minutesText = hasReminder ? '${reminder.minutesUntil}' : '--';

            return Container(
              width: double.infinity,
              padding: appPadding,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.93),
                borderRadius: BorderRadius.circular(
                  Dimensions.cardCornerRadius + 6,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width:
                            Dimensions.verticalSpacingXL +
                            Dimensions.horizontalSpacingExtraShort,
                        height:
                            Dimensions.verticalSpacingXL +
                            Dimensions.horizontalSpacingExtraShort,
                        decoration: BoxDecoration(
                          color: AppColorPalette.blueSteel.withValues(
                            alpha: 0.16,
                          ),
                          borderRadius: BorderRadius.circular(
                            Dimensions.cardCornerRadius,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            AppAssets.medcineicon,
                            fit: BoxFit.contain,
                            height: 10,
                            width: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.verticalSpacingRegular),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasReminder
                                  ? reminder.medicine.name
                                  : l10n.homeMedicationReminderTitle,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(
                              height: Dimensions.verticalSpacingExtraShort,
                            ),
                            Text(
                              hasReminder
                                  ? '${l10n.homeMedicationReminderSubtitle} (${reminder.timeLabel})'
                                  : l10n.doctorMedNoMedicationYet,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColorPalette.grey),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            minutesText,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: AppColorPalette.blueSteel,
                                ),
                          ),
                          Text(
                            l10n.homeMinutesLabel,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColorPalette.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.cardCornerRadius),
                  SizedBox(
                    width: double.infinity,
                    height:
                        Dimensions.verticalSpacingXL +
                        Dimensions.horizontalSpacingRegular,
                    child: ElevatedButton(
                      onPressed: hasReminder
                          ? () async {
                              final m = reminder.medicine;
                              await MedicineService.updateMedicine(
                                medicineDocId: medicineDocId,
                                medicineItemId: m.id,
                                name: m.name,
                                dosage: m.dosage,
                                intakeType: m.intakeType,
                                doseAmount: m.doseAmount,
                                doseUnit: m.doseUnit,
                                scheduledTime: m.scheduledTime,
                                scheduledTimes: m.scheduledTimes,
                                frequency: m.frequency,
                                daysTotal: m.daysTotal,
                                caregiverInstructions: m.caregiverInstructions,
                                status: 'taken',
                                lastDoseVerifiedBy: profile.name,
                              );
                            }
                          : () => onSelectTab?.call(3),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorPalette.blueSteel,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(containerRadius),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 18,
                              color: AppColorPalette.blueSteel,
                            ),
                          ),
                          const SizedBox(
                            width: Dimensions.verticalSpacingShort,
                          ),
                          Text(
                            hasReminder
                                ? l10n.homeTakenButton
                                : l10n.quickActionViewAll,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _quickActionCard({
    required BuildContext context,
    required Widget icon,
    required Color iconBg,
    required String title,
    required String action,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.cardCornerRadius),
      child: Container(
        padding: const EdgeInsets.all(containerRadius),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(Dimensions.cardCornerRadius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(
                  Dimensions.cardCornerRadius,
                ),
              ),
              child: Center(child: icon),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            Container(
              width: double.infinity,
              height:
                  Dimensions.verticalSpacingXL -
                  Dimensions.horizontalSpacingShort,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  Dimensions.verticalSpacingLarge - 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                action,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColorPalette.blueSteel,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildProgressCard(
    BuildContext context,
    AppLocalizations l10n,
    UserProfile profile,
  ) {
    final patientUid = profile.uid.trim();
    if (patientUid.isEmpty) {
      return const SizedBox.shrink();
    }
    return StreamBuilder<QueryDocumentSnapshot<Map<String, dynamic>>?>(
      stream: DoctorLinkRequestService.watchLatestAcceptedForPatient(
        patientUid,
      ),
      builder: (context, linkSnap) {
        final doctorUid =
            (linkSnap.data?.data()['doctorId'] as String?)?.trim() ?? '';
        if (doctorUid.isEmpty) {
          return const SizedBox.shrink();
        }
        final medicineDocId = MedicineService.buildMedicineDocId(
          doctorUid,
          patientUid,
        );
        final activityDocId = ActivityService.buildActivityDocId(
          doctorUid,
          patientUid,
        );
        return StreamBuilder<List<MedicineItem>>(
          stream: MedicineService.watchMedicines(medicineDocId),
          builder: (context, medSnap) {
            final medicines = medSnap.data ?? const <MedicineItem>[];
            return StreamBuilder<List<ActivityItem>>(
              stream: ActivityService.watchActivities(activityDocId),
              builder: (context, actSnap) {
                final activities = actSnap.data ?? const <ActivityItem>[];
                final progress = _buildWeeklyProgress(
                  medicines: medicines,
                  activities: activities,
                );
                final now = DateTime.now();
                final weekStart = DateTime(
                  now.year,
                  now.month,
                  now.day,
                ).subtract(Duration(days: now.weekday - 1));
                final weekEnd = weekStart.add(const Duration(days: 6));
                final todayIndex = now.weekday - 1;
                final dayData = progress.asMap().entries.map((entry) {
                  final date = weekStart.add(Duration(days: entry.key));
                  return WeekProgressDayData(
                    date: date,
                    done: entry.value.done,
                    total: entry.value.total,
                  );
                }).toList();

                return InkWell(
                  borderRadius: BorderRadius.circular(
                    Dimensions.verticalSpacingMedium - 2,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => WeekProgressCalendarPage(
                          title: l10n.homeThisWeekProgressTitle,
                          days: dayData,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: appPadding,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.93),
                      borderRadius: BorderRadius.circular(
                        Dimensions.verticalSpacingMedium - 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.homeThisWeekProgressTitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(
                                    height:
                                        Dimensions.verticalSpacingExtraShort,
                                  ),
                                  Text(
                                    _formatWeekRange(
                                      context,
                                      weekStart,
                                      weekEnd,
                                    ),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColorPalette.grey,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.show_chart_rounded,
                              color: AppColorPalette.purpleDeep,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: Dimensions.verticalSpacingRegular,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.homeWeekdayMon),
                            Text(l10n.homeWeekdayTue),
                            Text(l10n.homeWeekdayWed),
                            Text(l10n.homeWeekdayThu),
                            Text(l10n.homeWeekdayFri),
                            Text(l10n.homeWeekdaySat),
                            Text(l10n.homeWeekdaySun),
                          ],
                        ),
                        const SizedBox(height: containerRadius),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: progress.asMap().entries.map((dayEntry) {
                            final index = dayEntry.key;
                            final entry = dayEntry.value;
                            if (index > todayIndex) {
                              return const CircleAvatar(
                                radius: 16,
                                backgroundColor: Color(0xFFF0F2F5),
                              );
                            }
                            if (index == todayIndex) {
                              return const CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColorPalette.blueSteel,
                              );
                            }
                            if (entry.total <= 0) {
                              return const CircleAvatar(
                                radius: 16,
                                backgroundColor: Color(0xFFF0F2F5),
                              );
                            }
                            final ratio = entry.done / entry.total;
                            Color color;
                            if (ratio < 0.5) {
                              color = Colors.red;
                            } else if (ratio < 0.75) {
                              color = AppColorPalette.gold;
                            } else {
                              color = AppColorPalette.emerald;
                            }
                            return CircleAvatar(
                              radius: 16,
                              backgroundColor: color,
                              child: ratio >= 0.75
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : null,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: containerRadius),
                        Text(
                          l10n.homeAdherenceMessage,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColorPalette.grey,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  static String _formatWeekRange(
    BuildContext context,
    DateTime start,
    DateTime end,
  ) {
    final localizations = MaterialLocalizations.of(context);
    final startText = localizations.formatShortDate(start);
    final endText = localizations.formatShortDate(end);
    return '$startText - $endText';
  }

  static List<_DayProgress> _buildWeeklyProgress({
    required List<MedicineItem> medicines,
    required List<ActivityItem> activities,
  }) {
    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    final perDay = List<_DayProgress>.generate(
      7,
      (index) => _DayProgress(day: start.add(Duration(days: index))),
    );

    for (final day in perDay) {
      day.total += medicines.length;
      day.total += activities.where((a) => !a.isCancelled).length;
    }

    for (final medicine in medicines) {
      final date = medicine.lastDoseAt;
      if (!medicine.isTaken || date == null) continue;
      final idx = date.difference(start).inDays;
      if (idx >= 0 && idx < 7) {
        perDay[idx].done += 1;
      }
    }
    for (final activity in activities) {
      final date = activity.completedAt;
      if (!activity.isCompleted || date == null) continue;
      final idx = date.difference(start).inDays;
      if (idx >= 0 && idx < 7) {
        perDay[idx].done += 1;
      }
    }
    return perDay;
  }

  static Widget _buildHomeContent({
    required BuildContext context,
    required AppLocalizations l10n,
    required UserProfile profile,
    required ValueChanged<int>? onSelectTab,
  }) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
            context: context,
            l10n: l10n,
            name: profile.name,
            imageUrl: profile.imageUrl,
          ),
          const SizedBox(height: Dimensions.verticalSpacingMedium),
          _buildReminderCard(context, l10n, profile, onSelectTab),
          const SizedBox(height: Dimensions.cardCornerRadius),
          SizedBox(
            height: 350,
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: Dimensions.verticalSpacingRegular,
              crossAxisSpacing: Dimensions.verticalSpacingRegular,
              childAspectRatio: 1.08,
              children: [
                _quickActionCard(
                  context: context,
                  icon: Image.asset(
                    AppAssets.medcineicon,
                    fit: BoxFit.contain,
                    width: 24,
                    height: 24,
                  ),
                  iconBg: AppColorPalette.blueSteel.withValues(alpha: 0.16),
                  title: l10n.tabMedicine,
                  action: l10n.quickActionViewAll,
                  onTap: () => onSelectTab?.call(3),
                ),
                _quickActionCard(
                  context: context,
                  icon: const Icon(
                    Icons.directions_walk_rounded,
                    color: AppColorPalette.brownOlive,
                  ),
                  iconBg: AppColorPalette.gold.withValues(alpha: 0.5),
                  title: l10n.quickActionActivity,
                  action: l10n.quickActionStart,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PatientActivityPage(),
                      ),
                    );
                  },
                ),
                _quickActionCard(
                  context: context,
                  icon: const Icon(
                    Icons.extension_rounded,
                    color: AppColorPalette.purpleDeep,
                  ),
                  iconBg: AppColorPalette.purpleLight.withValues(alpha: 0.26),
                  title: l10n.quickActionMemoryTest,
                  action: l10n.quickActionStart,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const MemoryTestHubPage(),
                      ),
                    );
                  },
                ),
                _quickActionCard(
                  context: context,
                  icon: const Icon(
                    Icons.favorite_border_rounded,
                    color: AppColorPalette.redDark,
                  ),
                  iconBg: AppColorPalette.peachPink.withValues(alpha: 0.6),
                  title: l10n.quickActionFamily,
                  action: l10n.quickActionViewAll,
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRouter.family),
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.cardCornerRadius),
          _buildProgressCard(context, l10n, profile),
          const SizedBox(height: bottomNavigationBarPadding),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileState = ref.watch(currentUserProfileProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(appHorizontalPadding),
        child: profileState.when(
          data: (profile) {
            final resolved =
                profile ??
                UserProfile(
                  uid: '',
                  name: l10n.guestUser,
                  email: '',
                  imageUrl: '',
                  patientId: '',
                );
            return _buildHomeContent(
              context: context,
              l10n: l10n,
              profile: resolved,
              onSelectTab: onSelectTab,
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          error: (_, __) => _buildHomeContent(
            context: context,
            l10n: l10n,
            profile: UserProfile(
              uid: '',
              name: l10n.guestUser,
              email: '',
              imageUrl: '',
              patientId: '',
            ),
            onSelectTab: onSelectTab,
          ),
        ),
      ),
    );
  }
}

class _NextMedicineReminder {
  const _NextMedicineReminder({
    required this.medicine,
    required this.timeLabel,
    required this.minutesUntil,
  });

  final MedicineItem medicine;
  final String timeLabel;
  final int minutesUntil;
}

class _DayProgress {
  _DayProgress({required this.day});

  final DateTime day;
  int total = 0;
  int done = 0;
}
