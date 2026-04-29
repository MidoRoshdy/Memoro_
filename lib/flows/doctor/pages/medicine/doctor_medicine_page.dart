import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/models/medicine_item.dart';
import '../../../../core/services/doctor_link_request_service.dart';
import '../../../../core/services/medicine_service.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../core/usecases/notification_usecases.dart';
import '../../../../l10n/app_localizations.dart';
import 'doctor_add_medicine_page.dart';
import 'doctor_medicine_details_page.dart';

class DoctorMedicinePage extends StatelessWidget {
  const DoctorMedicinePage({super.key});

  static Widget _alertCard(
    BuildContext context,
    AppLocalizations l10n,
    int missedCount,
    VoidCallback onViewDetails,
  ) {
    final hasMissed = missedCount > 0;
    final backgroundColor = hasMissed
        ? const Color(0xFFFDF0F0)
        : const Color(0xFFE8F7EF);
    final accentColor = hasMissed
        ? const Color(0xFFB93C3C)
        : AppColorPalette.emerald;
    final iconColor = hasMissed
        ? const Color(0xFFD84A4A)
        : AppColorPalette.emerald;
    final iconData = hasMissed
        ? Icons.warning_amber_rounded
        : Icons.check_circle_rounded;
    final buttonColor = hasMissed
        ? const Color(0xFFEF5B5B)
        : AppColorPalette.emerald;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.horizontalSpacingMedium,
        vertical: Dimensions.verticalSpacingRegular,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(iconData, color: iconColor, size: 20),
          const SizedBox(width: Dimensions.horizontalSpacingShort),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.doctorMedDosesMissedToday(missedCount),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
                Text(
                  hasMissed
                      ? l10n.doctorMedRequiresAttention
                      : l10n.doctorMedAllGoodToday,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: accentColor),
                ),
              ],
            ),
          ),
          if (hasMissed)
            FilledButton(
              onPressed: onViewDetails,
              style: FilledButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(88, 34),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(l10n.doctorMedViewDetails),
            ),
        ],
      ),
    );
  }

  static Widget _statCard(
    BuildContext context, {
    required String title,
    required String value,
    required Color valueColor,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.horizontalSpacingMedium,
        vertical: Dimensions.verticalSpacingRegular,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColorPalette.grey),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Icon(icon, color: AppColorPalette.lightGrey),
        ],
      ),
    );
  }

  static Widget _scheduleTile(
    BuildContext context,
    MedicineItem item, {
    VoidCallback? onTap,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final dotColor = item.isTaken
        ? AppColorPalette.emerald
        : (item.isMissed
              ? AppColorPalette.redBright
              : AppColorPalette.blueSteel);
    final status = item.isTaken
        ? l10n.doctorMedStatusTaken
        : (item.isMissed
              ? l10n.doctorMedStatusMissed
              : l10n.doctorMedStatusUpcoming);
    final badgeBg = item.isTaken
        ? const Color(0xFFE5F4EA)
        : (item.isMissed ? const Color(0xFFFDE6E6) : const Color(0xFFE2EEF7));
    final badgeFg = item.isTaken
        ? AppColorPalette.emerald
        : (item.isMissed
              ? AppColorPalette.redBright
              : AppColorPalette.blueSteel);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: Dimensions.verticalSpacingShort),
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.horizontalSpacingRegular,
          vertical: Dimensions.verticalSpacingRegular,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.isTaken
                    ? Icons.check_rounded
                    : (item.isMissed
                          ? Icons.priority_high_rounded
                          : Icons.watch_later_outlined),
                size: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: Dimensions.horizontalSpacingRegular),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name.isEmpty
                        ? l10n.doctorMedTitleMedication
                        : item.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${item.primaryTime}${item.secondaryTime.isNotEmpty ? ' & ${item.secondaryTime}' : ''}${item.thirdTime.isNotEmpty ? ' & ${item.thirdTime}' : ''}  .  ${item.formattedDose}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColorPalette.grey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                status,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: badgeFg,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _allMedicationTile(
    BuildContext context,
    MedicineItem item, {
    VoidCallback? onTap,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: Dimensions.verticalSpacingShort),
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.horizontalSpacingRegular,
          vertical: Dimensions.verticalSpacingRegular,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name.isEmpty
                        ? l10n.doctorMedTitleMedication
                        : item.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.formattedDose.isEmpty
                        ? item.frequency
                        : '${item.formattedDose}  .  ${item.frequency}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColorPalette.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.doctorMedNextAt(item.primaryTime),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColorPalette.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.open_in_new_rounded,
              size: 16,
              color: AppColorPalette.grey,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return SafeArea(
      child: Padding(
        padding: appPadding,
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: currentUid.isEmpty
              ? const Stream<QuerySnapshot<Map<String, dynamic>>>.empty()
              : FirebaseFirestore.instance
                    .collection(DoctorLinkRequestService.collectionName)
                    .where('doctorId', isEqualTo: currentUid)
                    .snapshots(),
          builder: (context, linkSnap) {
            final acceptedDoc = linkSnap.hasData
                ? DoctorLinkRequestService.pickLatestWithStatus(
                    linkSnap.data!.docs,
                    DoctorLinkRequestService.requestStatusAccepted,
                  )
                : null;
            final linkedData = acceptedDoc?.data();
            final doctorUid =
                (linkedData?['doctorId'] as String?)?.trim() ?? currentUid;
            final patientUid =
                (linkedData?['patientUid'] as String?)?.trim() ?? '';
            if (patientUid.isEmpty) {
              return Center(
                child: Text(
                  l10n.doctorMedConnectFirst,
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
                final meds = medSnap.data ?? const <MedicineItem>[];
                Future.microtask(() async {
                  final scheduler = ScheduleMedicationReminderUseCase();
                  for (final med in meds.where((m) => !m.isTaken)) {
                    await scheduler.execute(item: med, pairId: medicineDocId);
                  }
                });
                final takenCount = meds.where((m) => m.isTaken).length;
                final missedCount = meds.where((m) => m.isMissed).length;
                final scheduleItems = meds.take(3).toList();
                void openMedicineDetails(MedicineItem item) {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => DoctorMedicineDetailsPage(
                        medicineDocId: medicineDocId,
                        medicineItemId: item.id,
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 18),
                          Expanded(
                            child: Text(
                              l10n.doctorMedTitleMedication,

                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          Container(
                            width: 34,
                            height: 34,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => DoctorAddMedicinePage(
                                      medicineDocId: medicineDocId,
                                      doctorUid: doctorUid,
                                      patientUid: patientUid,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.add_rounded,
                                color: AppColorPalette.blueSteel,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.verticalSpacingRegular),
                      _alertCard(context, l10n, missedCount, () {
                        final missed = meds.where((m) => m.isMissed).toList();
                        if (missed.isNotEmpty) {
                          openMedicineDetails(missed.first);
                        }
                      }),
                      const SizedBox(height: Dimensions.verticalSpacingRegular),
                      _statCard(
                        context,
                        title: l10n.doctorMedTotalMedication,
                        value: meds.length.toString().padLeft(2, '0'),
                        valueColor: AppColorPalette.blueSteel,
                        icon: Icons.assignment_outlined,
                      ),
                      const SizedBox(height: Dimensions.verticalSpacingShort),
                      _statCard(
                        context,
                        title: l10n.doctorMedTakenToday,
                        value: takenCount.toString().padLeft(2, '0'),
                        valueColor: AppColorPalette.blueSteel,
                        icon: Icons.check_circle_outline_rounded,
                      ),
                      const SizedBox(height: Dimensions.verticalSpacingShort),
                      _statCard(
                        context,
                        title: l10n.doctorMedMissed,
                        value: missedCount.toString().padLeft(2, '0'),
                        valueColor: AppColorPalette.redBright,
                        icon: Icons.disabled_by_default_outlined,
                      ),
                      const SizedBox(height: Dimensions.verticalSpacingRegular),
                      Text(
                        l10n.doctorMedTodaySchedule,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: Dimensions.verticalSpacingShort),
                      if (scheduleItems.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(
                            Dimensions.verticalSpacingRegular,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(l10n.doctorMedNoMedicationYet),
                        ),
                      for (final item in scheduleItems)
                        _scheduleTile(
                          context,
                          item,
                          onTap: () => openMedicineDetails(item),
                        ),
                      const SizedBox(height: Dimensions.verticalSpacingRegular),
                      Row(
                        children: [
                          Text(
                            l10n.doctorMedAllMedications,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            l10n.quickActionViewAll,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: const Color(0xFF7A3253),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.verticalSpacingShort),
                      for (final item in meds)
                        _allMedicationTile(
                          context,
                          item,
                          onTap: () => openMedicineDetails(item),
                        ),
                      const SizedBox(height: Dimensions.verticalSpacingRegular),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => DoctorAddMedicinePage(
                                  medicineDocId: medicineDocId,
                                  doctorUid: doctorUid,
                                  patientUid: patientUid,
                                ),
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColorPalette.blueSteel,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.add_rounded, size: 20),
                          label: Text(
                            l10n.doctorMedAddMedication,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.verticalSpacingShort),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.92,
                            ),
                            foregroundColor: AppColorPalette.blueSteel,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            l10n.doctorMedMedicationDetailsButton,
                            style: const TextStyle(fontWeight: FontWeight.w700),
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
