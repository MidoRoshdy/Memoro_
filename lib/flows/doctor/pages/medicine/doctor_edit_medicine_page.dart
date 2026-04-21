import 'package:flutter/material.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/models/medicine_item.dart';
import '../../../../core/services/medicine_service.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';

class DoctorEditMedicinePage extends StatefulWidget {
  const DoctorEditMedicinePage({
    super.key,
    required this.medicineDocId,
    required this.item,
  });

  final String medicineDocId;
  final MedicineItem item;

  @override
  State<DoctorEditMedicinePage> createState() => _DoctorEditMedicinePageState();
}

class _DoctorEditMedicinePageState extends State<DoctorEditMedicinePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _instructionsController;
  late final TextEditingController _daysController;

  bool _saving = false;
  String _status = 'upcoming';
  String _intakeType = 'Tablet';
  int _doseAmount = 1;
  String _frequency = 'Once Daily';
  String _time = '08:00';
  String _secondTime = '20:00';
  String _thirdTime = '23:00';

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item.name);
    _instructionsController = TextEditingController(text: item.caregiverInstructions);
    _daysController = TextEditingController(text: item.daysTotal.toString());
    _status = item.status.isEmpty ? 'upcoming' : item.status;
    _intakeType = item.intakeType.isEmpty ? 'Tablet' : item.intakeType;
    _doseAmount = item.doseAmount <= 0 ? 1 : item.doseAmount;
    _frequency = item.frequency.isEmpty ? 'Once Daily' : item.frequency;
    _time = item.primaryTime.isEmpty ? '08:00' : item.primaryTime;
    _secondTime = item.secondaryTime.isEmpty ? '20:00' : item.secondaryTime;
    _thirdTime = item.thirdTime.isEmpty ? '23:00' : item.thirdTime;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  String get _doseUnit => _intakeType == 'Tablet' ? 'tablet' : 'ml';
  String get _computedDose =>
      '$_doseAmount ${_doseUnit}${_doseAmount == 1 ? '' : 's'}';

  Future<void> _pickMlDoseAmount() async {
    var selected = _doseAmount.clamp(1, 500);
    final controller = FixedExtentScrollController(initialItem: selected - 1);
    final result = await showModalBottomSheet<int>(
      context: context,
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext)!;
        return SizedBox(
          height: 320,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.horizontalSpacingRegular,
                  vertical: Dimensions.verticalSpacingShort,
                ),
                child: Row(
                  children: [
                    Text(
                      l10n.doctorMedSelectMlAmount,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(selected),
                      child: Text(l10n.doctorMedDone),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: StatefulBuilder(
                  builder: (_, setSheetState) {
                    return ListWheelScrollView.useDelegate(
                      controller: controller,
                      itemExtent: 44,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setSheetState(() => selected = index + 1);
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 500,
                        builder: (context, index) {
                          final isSelected = selected == index + 1;
                          return Center(
                            child: Container(
                              width: 120,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColorPalette.blueSteel.withValues(alpha: 0.14)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${index + 1} ml',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: isSelected
                                      ? AppColorPalette.blueSteel
                                      : AppColorPalette.grey,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
    if (result == null) return;
    setState(() => _doseAmount = result);
  }

  Future<void> _pickTime({required bool second, bool third = false}) async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: now);
    if (picked == null) return;
    setState(() {
      final value =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (third) {
        _thirdTime = value;
      } else if (second) {
        _secondTime = value;
      } else {
        _time = value;
      }
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    final days = int.tryParse(_daysController.text.trim()) ?? widget.item.daysTotal;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.doctorMedMedicationNameRequired)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await MedicineService.updateMedicine(
        medicineDocId: widget.medicineDocId,
        medicineItemId: widget.item.id,
        name: name,
        dosage: _computedDose,
        intakeType: _intakeType,
        doseAmount: _doseAmount,
        doseUnit: _doseUnit,
        scheduledTime: _time,
        scheduledTimes: _frequency == 'Twice Daily'
            ? <String>[_time, _secondTime]
            : (_frequency == 'Three Daily'
                  ? <String>[_time, _secondTime, _thirdTime]
                  : <String>[_time]),
        frequency: _frequency,
        daysTotal: days,
        caregiverInstructions: _instructionsController.text.trim(),
        status: _status,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.doctorMedCouldNotSaveChanges)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
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
    setState(() => _saving = true);
    try {
      await MedicineService.deleteMedicine(
        medicineDocId: widget.medicineDocId,
        medicineItemId: widget.item.id,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.doctorMedDeleteFailed)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w800,
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.doctorMedEditMedication),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: appPadding,
          child: Column(
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
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColorPalette.blueSteel.withValues(alpha: 0.15),
                      child: const Icon(Icons.person, color: AppColorPalette.blueSteel),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.doctorMedMedicationDetailsHeader,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              Text(l10n.doctorMedMedicationName, style: titleStyle),
              const SizedBox(height: Dimensions.verticalSpacingShort),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              Text(l10n.doctorMedWhatTime, style: titleStyle),
              const SizedBox(height: Dimensions.verticalSpacingShort),
              TextField(
                readOnly: true,
                onTap: () => _pickTime(second: false),
                decoration: InputDecoration(
                  hintText: _time,
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: const Icon(Icons.access_time_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              if (_frequency == 'Twice Daily') ...[
                const SizedBox(height: Dimensions.verticalSpacingShort),
                TextField(
                  readOnly: true,
                  onTap: () => _pickTime(second: true),
                  decoration: InputDecoration(
                    hintText: _secondTime,
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: const Icon(Icons.access_time_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
              if (_frequency == 'Three Daily') ...[
                const SizedBox(height: Dimensions.verticalSpacingShort),
                TextField(
                  readOnly: true,
                  onTap: () => _pickTime(second: true),
                  decoration: InputDecoration(
                    hintText: _secondTime,
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: const Icon(Icons.access_time_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.verticalSpacingShort),
                TextField(
                  readOnly: true,
                  onTap: () => _pickTime(second: true, third: true),
                  decoration: InputDecoration(
                    hintText: _thirdTime,
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: const Icon(Icons.access_time_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              Text(l10n.doctorMedFrequencyLabel, style: titleStyle),
              const SizedBox(height: Dimensions.verticalSpacingShort),
              DropdownButtonFormField<String>(
                value: _frequency,
                items: [
                  DropdownMenuItem(
                    value: 'Once Daily',
                    child: Text(l10n.doctorMedOnceDaily),
                  ),
                  DropdownMenuItem(
                    value: 'Twice Daily',
                    child: Text(l10n.doctorMedTwiceDaily),
                  ),
                  DropdownMenuItem(
                    value: 'Three Daily',
                    child: Text(l10n.doctorMedThreeDaily),
                  ),
                ],
                onChanged: (v) => setState(() => _frequency = v ?? _frequency),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              Text(l10n.doctorMedDuration, style: titleStyle),
              const SizedBox(height: Dimensions.verticalSpacingShort),
              TextField(
                controller: _daysController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  suffixIcon: const Icon(Icons.calendar_month_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              Text(l10n.doctorMedMedicineType, style: titleStyle),
              const SizedBox(height: Dimensions.verticalSpacingShort),
              DropdownButtonFormField<String>(
                value: _intakeType,
                items: [
                  DropdownMenuItem(
                    value: 'Tablet',
                    child: Text(l10n.doctorMedTypeTablet),
                  ),
                  DropdownMenuItem(
                    value: 'Syringe',
                    child: Text(l10n.doctorMedTypeSyringe),
                  ),
                  DropdownMenuItem(
                    value: 'Drink',
                    child: Text(l10n.doctorMedTypeDrink),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _intakeType = value;
                    if (_intakeType == 'Tablet') {
                      _doseAmount = _doseAmount.clamp(1, 3);
                    }
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              Text(l10n.doctorMedDose, style: titleStyle),
              const SizedBox(height: Dimensions.verticalSpacingShort),
              Row(
                children: [
                  Expanded(
                    child: _intakeType == 'Tablet'
                        ? DropdownButtonFormField<int>(
                            value: _doseAmount.clamp(1, 3),
                            items: const [
                              DropdownMenuItem(value: 1, child: Text('1')),
                              DropdownMenuItem(value: 2, child: Text('2')),
                              DropdownMenuItem(value: 3, child: Text('3')),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _doseAmount = value);
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          )
                        : TextField(
                            readOnly: true,
                            onTap: _pickMlDoseAmount,
                            decoration: InputDecoration(
                              hintText: '$_doseAmount',
                              suffixIcon: const Icon(Icons.swipe_vertical_rounded),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: Dimensions.horizontalSpacingRegular),
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText:
                            _doseUnit == 'tablet'
                                ? (_doseAmount == 1
                                      ? l10n.doctorMedUnitTabletSingular
                                      : l10n.doctorMedUnitTabletPlural)
                                : l10n.doctorMedUnitMl,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              Text(l10n.doctorMedCaregiverInstructions, style: titleStyle),
              const SizedBox(height: Dimensions.verticalSpacingShort),
              TextField(
                controller: _instructionsController,
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF2F1E4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _status,
                      items: [
                        DropdownMenuItem(
                          value: 'taken',
                          child: Text(l10n.doctorMedStatusTaken),
                        ),
                        DropdownMenuItem(
                          value: 'missed',
                          child: Text(l10n.doctorMedStatusMissed),
                        ),
                        DropdownMenuItem(
                          value: 'upcoming',
                          child: Text(l10n.doctorMedStatusUpcoming),
                        ),
                      ],
                      onChanged: (v) => setState(() => _status = v ?? _status),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline_rounded),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColorPalette.blueSteel,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  label: Text(
                    l10n.doctorMedSaveChanges,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingShort),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _delete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF1F1),
                    foregroundColor: AppColorPalette.redBright,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
        ),
      ),
    );
  }
}
