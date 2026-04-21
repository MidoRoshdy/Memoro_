import 'package:flutter/material.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/models/medicine_item.dart';
import '../../../../core/services/medicine_service.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';
import 'doctor_edit_medicine_page.dart';

class DoctorMedicineDetailsPage extends StatelessWidget {
  const DoctorMedicineDetailsPage({
    super.key,
    required this.medicineDocId,
    required this.medicineItemId,
  });

  final String medicineDocId;
  final String medicineItemId;

  String _statusLabel(MedicineItem item) {
    if (item.isTaken) return 'taken';
    if (item.isMissed) return 'missed';
    return 'upcoming';
  }

  Color _statusColor(MedicineItem item) {
    if (item.isTaken) return AppColorPalette.emerald;
    if (item.isMissed) return AppColorPalette.redBright;
    return AppColorPalette.blueSteel;
  }

  Future<void> _delete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final sure = await showDialog<bool>(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: Text(l10n.doctorMedDeleteTitle),
        content: Text(l10n.doctorMedDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dCtx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dCtx).pop(true),
            child: Text(l10n.doctorMedDeleteButton),
          ),
        ],
      ),
    );
    if (sure != true) return;
    try {
      await MedicineService.deleteMedicine(
        medicineDocId: medicineDocId,
        medicineItemId: medicineItemId,
      );
      if (!context.mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.doctorMedDeleteFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.doctorMedTitleMedication),
      ),
      body: SafeArea(
        child: Padding(
          padding: appPadding,
          child: StreamBuilder<MedicineItem?>(
            stream: MedicineService.watchMedicineItem(
              medicineDocId,
              medicineItemId,
            ),
            builder: (context, snap) {
              final item = snap.data;
              if (!snap.hasData || item == null) {
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }
              final statusColor = _statusColor(item);
              final statusLabel = _statusLabel(item);
              final localizedStatus = statusLabel == 'taken'
                  ? l10n.doctorMedStatusTaken
                  : (statusLabel == 'missed'
                        ? l10n.doctorMedStatusMissed
                        : l10n.doctorMedStatusUpcoming);
              final doseUnit = item.doseUnit == 'tablet'
                  ? (item.doseAmount == 1
                        ? l10n.doctorMedUnitTabletSingular
                        : l10n.doctorMedUnitTabletPlural)
                  : l10n.doctorMedUnitMl;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                        Dimensions.verticalSpacingRegular,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.93),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              localizedStatus,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.name,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: AppColorPalette.blueSteel,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          Text(
                            '${item.intakeType}  .  ${item.doseAmount} $doseUnit',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColorPalette.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingRegular),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                        Dimensions.verticalSpacingRegular,
                      ),
                      decoration: BoxDecoration(
                        color: AppColorPalette.blueSteel.withValues(
                          alpha: 0.85,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.doctorMedFrequencyLabel,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Text(
                            item.frequency,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingRegular),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                        Dimensions.verticalSpacingRegular,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.93),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_rounded),
                          const SizedBox(width: 10),
                          Text(
                            item.primaryTime,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          if (item.secondaryTime.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              '& ${item.secondaryTime}',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                          if (item.thirdTime.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              '& ${item.thirdTime}',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingRegular),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                        Dimensions.verticalSpacingRegular,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F1E4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                l10n.doctorMedInstructionsTitle,
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.caregiverInstructions.isEmpty
                                ? l10n.doctorMedNoInstructions
                                : item.caregiverInstructions,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingRegular),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => DoctorEditMedicinePage(
                                medicineDocId: medicineDocId,
                                item: item,
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
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: Text(
                          l10n.doctorMedEditMedication,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingShort),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: () => _delete(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF1F1),
                          foregroundColor: AppColorPalette.redBright,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                        ),
                        label: Text(
                          l10n.doctorMedDeleteMedication,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: bottomNavigationBarPadding),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
