import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../core/usecases/notification_usecases.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../pationt/widgets/app_text_field.dart';

class DoctorAssignActivityPage extends StatefulWidget {
  const DoctorAssignActivityPage({
    super.key,
    required this.activityDocId,
    required this.doctorUid,
    required this.patientUid,
  });

  final String activityDocId;
  final String doctorUid;
  final String patientUid;

  @override
  State<DoctorAssignActivityPage> createState() =>
      _DoctorAssignActivityPageState();
}

class _DoctorAssignActivityPageState extends State<DoctorAssignActivityPage> {
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  final _notesController = TextEditingController();

  String _type = 'water';
  String _time = '08:00';
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: now);
    if (picked == null) return;
    setState(() {
      _time =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.doctorActivityTitleRequired)));
      return;
    }

    setState(() => _saving = true);
    try {
      final currentUid =
          FirebaseAuth.instance.currentUser?.uid.trim().isNotEmpty == true
          ? FirebaseAuth.instance.currentUser!.uid.trim()
          : widget.doctorUid;

      await AssignActivityUseCase().execute(
        activityDocId: widget.activityDocId,
        doctorUid: widget.doctorUid,
        patientUid: widget.patientUid,
        createdByUid: currentUid,
        title: title,
        type: _type,
        target: _targetController.text.trim(),
        notes: _notesController.text.trim(),
        scheduledTime: _time,
        assignedByName:
            FirebaseAuth.instance.currentUser?.displayName?.trim().isNotEmpty ==
                true
            ? FirebaseAuth.instance.currentUser!.displayName!.trim()
            : currentUid,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.doctorMedCouldNotSave)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labelAboveStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: AppColorPalette.black,
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.doctorAssignActivity),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: appPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(
                  Dimensions.verticalSpacingRegular,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    AppTextField(
                      controller: _titleController,
                      label: l10n.doctorActivityTitleLabel,
                      hintText: l10n.doctorActivityTitleHint,
                      labelAbove: true,
                      labelAboveStyle: labelAboveStyle,
                      fillColor: AppColorPalette.white,
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingRegular),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        l10n.doctorActivityTypeLabel,
                        style: labelAboveStyle,
                      ),
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingShort),
                    Material(
                      color: AppColorPalette.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1.2,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _type,
                            isExpanded: true,
                            items: [
                              DropdownMenuItem(
                                value: 'water',
                                child: Text(l10n.doctorActivityTypeWater),
                              ),
                              DropdownMenuItem(
                                value: 'exercise',
                                child: Text(l10n.doctorActivityTypeExercise),
                              ),
                              DropdownMenuItem(
                                value: 'breathing',
                                child: Text(l10n.doctorActivityTypeBreathing),
                              ),
                              DropdownMenuItem(
                                value: 'other',
                                child: Text(l10n.doctorActivityTypeOther),
                              ),
                            ],
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => _type = v);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingRegular),
                    AppTextField(
                      controller: _targetController,
                      label: l10n.doctorActivityTargetLabel,
                      hintText: l10n.doctorActivityTargetHint,
                      labelAbove: true,
                      labelAboveStyle: labelAboveStyle,
                      fillColor: AppColorPalette.white,
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingRegular),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.doctorActivityTimeLabel(_time),
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: AppColorPalette.blueSteel,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        OutlinedButton(
                          onPressed: _pickTime,
                          child: Text(l10n.doctorMedSetTime),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingRegular),
                    AppTextField(
                      controller: _notesController,
                      label: l10n.doctorActivityInstructionsLabel,
                      hintText: l10n.doctorActivityInstructionsHint,
                      labelAbove: true,
                      labelAboveStyle: labelAboveStyle,
                      fillColor: AppColorPalette.white,
                      minLines: 3,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(
                    _saving ? l10n.loading : l10n.doctorAssignActivity,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColorPalette.blueSteel,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(containerRadius),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
