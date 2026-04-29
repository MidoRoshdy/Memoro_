import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/string_assets.dart';
import '../../../../core/models/medicine_item.dart';
import '../../../../core/services/doctor_link_request_service.dart';
import '../../../../core/services/medicine_service.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../../widgets/app_notifications_action.dart';

class MedicinePage extends StatefulWidget {
  const MedicinePage({super.key});

  @override
  State<MedicinePage> createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  List<_MedicineDoseCardData> _expandToDoseCards(List<MedicineItem> medicines) {
    return medicines.expand((item) {
      final rawTimes = item.scheduledTimes
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();
      final times = rawTimes.isNotEmpty
          ? rawTimes
          : <String>[
              item.primaryTime.trim().isNotEmpty
                  ? item.primaryTime.trim()
                  : '--',
            ];
      return times.map((time) => _MedicineDoseCardData(item: item, time: time));
    }).toList();
  }

  Widget _summaryCard(
    BuildContext context,
    AppLocalizations l10n,
    List<MedicineItem> medicines,
  ) {
    final total = medicines.length;
    final taken = medicines.where((m) => m.isTaken).length;
    final progress = total == 0 ? 0.0 : (taken / total).clamp(0.0, 1.0);
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
                      l10n.medMedicationsCount(total),
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
                l10n.medProgressFraction(taken, total),
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
            child: LinearProgressIndicator(
              minHeight: 12,
              value: progress,
              backgroundColor: const Color(0xFFEBEEF2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColorPalette.emerald,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
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

  Widget _medCard(
    BuildContext context, {
    required String medicineDocId,
    required MedicineItem item,
    required Color bgColor,
    required String name,
    required String subtitle,
    required List<String> times,
    required String buttonText,
    required Color buttonColor,
    required Color iconColor,
    required bool isTaken,
    required Color borderColor,
    required String markTakenText,
    required String savedText,
  }) {
    final validTimes = times
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    final displayTimes = validTimes.isEmpty ? <String>['--'] : validTimes;

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
                    Wrap(
                      spacing: Dimensions.horizontalSpacingShort,
                      runSpacing: Dimensions.verticalSpacingExtraShort,
                      children: [
                        for (final doseTime in displayTimes)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: borderColor.withValues(alpha: 0.7),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.watch_later_outlined,
                                  size: 14,
                                  color: AppColorPalette.grey,
                                ),
                                const SizedBox(
                                  width: Dimensions.horizontalSpacingExtraShort,
                                ),
                                Text(
                                  doseTime,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
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
              onPressed: isTaken
                  ? null
                  : () async {
                      await MedicineService.updateMedicine(
                        medicineDocId: medicineDocId,
                        medicineItemId: item.id,
                        name: item.name,
                        dosage: item.dosage,
                        intakeType: item.intakeType,
                        doseAmount: item.doseAmount,
                        doseUnit: item.doseUnit,
                        scheduledTime: item.scheduledTime,
                        scheduledTimes: item.scheduledTimes,
                        frequency: item.frequency,
                        daysTotal: item.daysTotal,
                        caregiverInstructions: item.caregiverInstructions,
                        status: 'taken',
                        lastDoseVerifiedBy:
                            FirebaseAuth.instance.currentUser?.displayName ??
                            '',
                      );
                      if (!mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(savedText)));
                    },
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
                disabledBackgroundColor: buttonColor.withValues(alpha: 0.55),
                disabledForegroundColor: iconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int? _parseHour(String value) {
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

  int? _parseMinute(String value) {
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

  bool _isDoseTaken(MedicineItem item, String doseTime) {
    final takenAt = item.lastDoseAt?.toLocal();
    if (takenAt == null) return false;
    final now = DateTime.now();
    if (takenAt.year != now.year ||
        takenAt.month != now.month ||
        takenAt.day != now.day) {
      return false;
    }
    final hour = _parseHour(doseTime);
    final minute = _parseMinute(doseTime);
    if (hour == null || minute == null) {
      return item.isTaken;
    }
    final scheduledToday = DateTime(now.year, now.month, now.day, hour, minute);
    return takenAt.isAtSameMomentAs(scheduledToday) ||
        takenAt.isAfter(scheduledToday);
  }

  int? _resolveDoseHour(_MedicineDoseCardData dose) {
    final fromTime = _parseHour(dose.time);
    if (fromTime != null) return fromTime;
    return _parseHour(dose.item.scheduledTime);
  }

  ({
    List<_MedicineDoseCardData> morning,
    List<_MedicineDoseCardData> afternoon,
    List<_MedicineDoseCardData> evening,
  })
  _groupByDayPart(List<_MedicineDoseCardData> list) {
    final morning = <_MedicineDoseCardData>[];
    final afternoon = <_MedicineDoseCardData>[];
    final evening = <_MedicineDoseCardData>[];

    for (final m in list) {
      final hour = _resolveDoseHour(m);
      if (hour == null) {
        afternoon.add(m);
      } else if (hour < 12) {
        morning.add(m);
      } else if (hour < 17) {
        afternoon.add(m);
      } else {
        evening.add(m);
      }
    }
    return (morning: morning, afternoon: afternoon, evening: evening);
  }

  Widget _sectionList(
    BuildContext context, {
    required AppLocalizations l10n,
    required String medicineDocId,
    required List<_MedicineDoseCardData> items,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color defaultBg,
    required Color defaultButtonBg,
    required Color defaultBorder,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, title: title, icon: icon, iconColor: iconColor),
        const SizedBox(height: Dimensions.verticalSpacingShort),
        for (var i = 0; i < items.length; i++) ...[
          _medCard(
            context,
            medicineDocId: medicineDocId,
            item: items[i].item,
            bgColor: defaultBg,
            name: items[i].item.name,
            subtitle: items[i].item.formattedDose,
            times: <String>[items[i].time],
            buttonText: _isDoseTaken(items[i].item, items[i].time)
                ? l10n.homeTakenButton
                : l10n.medMarkAsTaken,
            buttonColor: defaultButtonBg,
            iconColor: iconColor,
            isTaken: _isDoseTaken(items[i].item, items[i].time),
            borderColor: defaultBorder,
            markTakenText: l10n.medMarkAsTaken,
            savedText: l10n.doctorMedStatusTaken,
          ),
          if (i != items.length - 1)
            const SizedBox(height: Dimensions.verticalSpacingMedium),
        ],
        const SizedBox(height: Dimensions.verticalSpacingMedium),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final patientUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return SafeArea(
      child: Padding(
        padding: appPadding,
        child: StreamBuilder<QueryDocumentSnapshot<Map<String, dynamic>>?>(
          stream: patientUid.isEmpty
              ? const Stream<
                  QueryDocumentSnapshot<Map<String, dynamic>>?
                >.empty()
              : DoctorLinkRequestService.watchLatestAcceptedForPatient(
                  patientUid,
                ),
          builder: (context, linkSnap) {
            final request = linkSnap.data;
            final data = request?.data();
            final doctorUid = (data?['doctorId'] as String?)?.trim() ?? '';
            if (doctorUid.isEmpty) {
              return Center(
                child: Text(
                  l10n.doctorMedConnectFirst,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }

            final medicineDocId = MedicineService.buildMedicineDocId(
              doctorUid,
              patientUid,
            );

            return StreamBuilder<List<MedicineItem>>(
              stream: MedicineService.watchMedicines(medicineDocId),
              builder: (context, medSnap) {
                final medicines = medSnap.data ?? const <MedicineItem>[];
                final doseCards = _expandToDoseCards(medicines);
                final grouped = _groupByDayPart(doseCards);

                return SingleChildScrollView(
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
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
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
                      _summaryCard(context, l10n, medicines),
                      const SizedBox(height: Dimensions.verticalSpacingLarge),
                      _sectionList(
                        context,
                        l10n: l10n,
                        medicineDocId: medicineDocId,
                        items: grouped.morning,
                        title: l10n.medSectionMorning,
                        icon: Icons.wb_sunny_rounded,
                        iconColor: AppColorPalette.emerald,
                        defaultBg: const Color(0xFFE5F5EE),
                        defaultButtonBg: const Color(0xFFB9EAD2),
                        defaultBorder: AppColorPalette.emerald,
                      ),
                      _sectionList(
                        context,
                        l10n: l10n,
                        medicineDocId: medicineDocId,
                        items: grouped.afternoon,
                        title: l10n.medSectionAfternoon,
                        icon: Icons.wb_twilight_rounded,
                        iconColor: AppColorPalette.brownOlive,
                        defaultBg: const Color(0xFFF4F0DF),
                        defaultButtonBg: const Color(0xFFF9E3B9),
                        defaultBorder: AppColorPalette.brownOlive,
                      ),
                      _sectionList(
                        context,
                        l10n: l10n,
                        medicineDocId: medicineDocId,
                        items: grouped.evening,
                        title: l10n.medSectionEvening,
                        icon: Icons.nights_stay_rounded,
                        iconColor: AppColorPalette.blueBright,
                        defaultBg: const Color(0xFFEBEFF7),
                        defaultButtonBg: const Color(0xFFD6DFF4),
                        defaultBorder: AppColorPalette.blueBright,
                      ),
                      if (medicines.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: Dimensions.verticalSpacingRegular,
                            ),
                            child: Text(
                              l10n.doctorMedNoMedicationYet,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ),
                      const SizedBox(height: bottomNavigationBarPadding),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _MedicineDoseCardData {
  const _MedicineDoseCardData({required this.item, required this.time});

  final MedicineItem item;
  final String time;
}
