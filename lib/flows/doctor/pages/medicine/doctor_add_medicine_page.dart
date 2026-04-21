import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/services/medicine_service.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';

class DoctorAddMedicinePage extends StatefulWidget {
  const DoctorAddMedicinePage({
    super.key,
    required this.medicineDocId,
    required this.doctorUid,
    required this.patientUid,
  });

  final String medicineDocId;
  final String doctorUid;
  final String patientUid;

  @override
  State<DoctorAddMedicinePage> createState() => _DoctorAddMedicinePageState();
}

class _DoctorAddMedicinePageState extends State<DoctorAddMedicinePage> {
  final _nameController = TextEditingController();
  final _instructionController = TextEditingController();

  final List<String> _frequencyOptions = const <String>[
    'Once Daily',
    'Twice Daily',
    'Three Daily',
  ];

  String _time = '08:00';
  String _secondTime = '20:00';
  String _thirdTime = '23:00';
  String _intakeType = 'Tablet';
  int _doseAmount = 1;
  String _frequency = 'Once Daily';
  int _daysTotal = 30;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _instructionController.dispose();
    super.dispose();
  }

  String get _doseUnit => _intakeType == 'Tablet' ? 'tablet' : 'ml';
  String get _computedDose => '$_doseAmount $_doseUnit';

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

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.doctorMedMedicationNameRequired)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? widget.doctorUid;
      await MedicineService.addMedicine(
        medicineDocId: widget.medicineDocId,
        doctorUid: widget.doctorUid,
        patientUid: widget.patientUid,
        createdByUid: uid,
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
        daysTotal: _daysTotal,
        caregiverInstructions: _instructionController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.doctorMedCouldNotSave)),
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
        title: Text(l10n.doctorMedAddMedication),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.doctorMedStepOneOfTwo,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: AppColorPalette.grey),
                          ),
                          Text(
                            l10n.doctorMedNewPrescription,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColorPalette.blueSteel,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColorPalette.lightGrey.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_box_outlined),
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
                  hintText: l10n.medDrugAspirin,
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: const Icon(Icons.edit_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              Text(l10n.doctorMedWhatTime, style: titleStyle),
              const SizedBox(height: Dimensions.verticalSpacingShort),
              _timePickerRow(
                context,
                label: l10n.doctorMedPrimaryTime,
                value: _time,
                onPick: () => _pickTime(second: false),
              ),
              if (_frequency == 'Twice Daily') ...[
                const SizedBox(height: Dimensions.verticalSpacingShort),
                _timePickerRow(
                  context,
                  label: l10n.doctorMedSecondTime,
                  value: _secondTime,
                  onPick: () => _pickTime(second: true),
                ),
              ],
              if (_frequency == 'Three Daily') ...[
                const SizedBox(height: Dimensions.verticalSpacingShort),
                _timePickerRow(
                  context,
                  label: l10n.doctorMedSecondTime,
                  value: _secondTime,
                  onPick: () => _pickTime(second: true),
                ),
                const SizedBox(height: Dimensions.verticalSpacingShort),
                _timePickerRow(
                  context,
                  label: l10n.doctorMedThirdTime,
                  value: _thirdTime,
                  onPick: () => _pickTime(second: true, third: true),
                ),
              ],
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              Text(l10n.doctorMedHowOften, style: titleStyle),
              const SizedBox(height: Dimensions.verticalSpacingShort),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: _frequencyOptions.map((option) {
                    final selected = option == _frequency;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: ChoiceChip(
                          label: Text(_frequencyLabel(l10n, option)),
                          selected: selected,
                          onSelected: (_) => setState(() {
                            _frequency = option;
                          }),
                          selectedColor: AppColorPalette.blueSteel,
                          labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: selected ? Colors.white : AppColorPalette.grey,
                            fontWeight: FontWeight.w700,
                          ),
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide.none,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              Text(l10n.doctorMedNumberOfDays, style: titleStyle),
              const SizedBox(height: Dimensions.verticalSpacingShort),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.horizontalSpacingRegular,
                  vertical: Dimensions.verticalSpacingRegular,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _daysTotal > 1
                          ? () => setState(() => _daysTotal -= 1)
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '$_daysTotal',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColorPalette.blueSteel,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            l10n.doctorMedDaysTotal,
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(color: AppColorPalette.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _daysTotal += 1),
                      icon: const Icon(Icons.add),
                    ),
                  ],
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
                controller: _instructionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      l10n.doctorMedInstructionHint,
                  filled: true,
                  fillColor: const Color(0xFFF2F1E4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColorPalette.blueSteel,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
                  label: Text(
                    l10n.doctorMedSaveMedication,
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

  Widget _timePickerRow(
    BuildContext context, {
    required String label,
    required String value,
    required VoidCallback onPick,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColorPalette.blueSteel,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: AppColorPalette.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: Dimensions.horizontalSpacingRegular),
        Expanded(
          child: SizedBox(
            height: 74,
            child: ElevatedButton(
              onPressed: onPick,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.85),
                foregroundColor: AppColorPalette.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time_rounded),
                  const SizedBox(height: 4),
                  Text(l10n.doctorMedSetTime),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _frequencyLabel(AppLocalizations l10n, String value) {
    if (value == 'Twice Daily') return l10n.doctorMedTwiceDaily;
    if (value == 'Three Daily') return l10n.doctorMedThreeDaily;
    return l10n.doctorMedOnceDaily;
  }

  Future<void> _pickTime({required bool second, bool third = false}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked == null) return;
    final hh = picked.hour.toString().padLeft(2, '0');
    final mm = picked.minute.toString().padLeft(2, '0');
    setState(() {
      if (third) {
        _thirdTime = '$hh:$mm';
      } else if (second) {
        _secondTime = '$hh:$mm';
      } else {
        _time = '$hh:$mm';
      }
    });
  }
}
