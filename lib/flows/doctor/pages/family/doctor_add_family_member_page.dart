import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/services/family_service.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../pationt/widgets/app_text_field.dart';

class DoctorAddFamilyMemberPage extends StatefulWidget {
  const DoctorAddFamilyMemberPage({
    super.key,
    required this.familyDocId,
    required this.doctorUid,
    required this.patientUid,
  });

  final String familyDocId;
  final String doctorUid;
  final String patientUid;

  @override
  State<DoctorAddFamilyMemberPage> createState() =>
      _DoctorAddFamilyMemberPageState();
}

class _DoctorAddFamilyMemberPageState extends State<DoctorAddFamilyMemberPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedRelation;

  static const List<String> _relationOptions = <String>[
    'Daughter',
    'Son',
    'Wife',
    'Husband',
    'Brother',
    'Sister',
    'Father',
    'Mother',
    'Doctor',
    'Caregiver',
    'Friend',
    'Other',
  ];

  XFile? _profilePhoto;
  Uint8List? _profilePreviewBytes;
  bool _isEmergencyContact = false;
  bool _saving = false;

  Widget _photoPicker(BuildContext context) {
    final hasPhoto = _profilePreviewBytes != null;
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _saving ? null : _pickFromGallery,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: 118,
                  height: 118,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.9),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF3B87A8), Color(0xFF2E6E89)],
                        ),
                      ),
                      child: hasPhoto
                          ? Image.memory(
                              _profilePreviewBytes!,
                              fit: BoxFit.cover,
                              width: 118,
                              height: 118,
                            )
                          : const Icon(
                              Icons.person_rounded,
                              size: 48,
                              color: Colors.white70,
                            ),
                    ),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: 6,
                  child: GestureDetector(
                    onTap: _saving ? null : _pickFromGallery,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColorPalette.blueSteel,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.verticalSpacingShort),
          Text(
            'Upload profile photo',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (hasPhoto)
            TextButton(
              onPressed: _saving ? null : _clearProfilePhoto,
              child: Text(
                AppLocalizations.of(context)!.removeProfilePhoto,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColorPalette.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _emergencyCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.horizontalSpacingMedium,
        vertical: Dimensions.verticalSpacingRegular,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE4E3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.priority_high_rounded,
              size: 12,
              color: Color(0xFFE95454),
            ),
          ),
          const SizedBox(width: Dimensions.horizontalSpacingRegular),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency Contact',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Set as primary contact',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColorPalette.grey),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: _saving
                ? null
                : () => setState(
                    () => _isEmergencyContact = !_isEmergencyContact,
                  ),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _isEmergencyContact
                    ? AppColorPalette.blueSteel
                    : Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey.shade400, width: 1.2),
              ),
              child: _isEmergencyContact
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.horizontalSpacingMedium,
        vertical: Dimensions.verticalSpacingRegular,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F0DD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Color(0xFF5E430B),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline,
              size: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: Dimensions.horizontalSpacingRegular),
          Expanded(
            child: Text(
              'This information helps us provide better care coordination and emergency support for your family.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF4F3C11),
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _profilePhoto = file;
        _profilePreviewBytes = bytes;
      });
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.imagePickerError)));
    } on MissingPluginException {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.imagePickerError)));
    }
  }

  void _clearProfilePhoto() {
    setState(() {
      _profilePhoto = null;
      _profilePreviewBytes = null;
    });
  }

  Future<String> _uploadFamilyPhotoIfAny() async {
    final photo = _profilePhoto;
    if (photo == null) return '';
    try {
      final bytes = await photo.readAsBytes();
      final ref = FirebaseStorage.instance.ref(
        'familyImages/${widget.familyDocId}/${DateTime.now().microsecondsSinceEpoch}.jpg',
      );
      final snapshot = await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return snapshot.ref.getDownloadURL();
    } on FirebaseException {
      // Do not block adding a member when photo upload is denied/unavailable.
      return '';
    } catch (_) {
      return '';
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final relation = (_selectedRelation ?? '').trim();
    if (name.isEmpty || phone.isEmpty || relation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final photoUrl = await _uploadFamilyPhotoIfAny();
      await FamilyService.addMember(
        familyDocId: widget.familyDocId,
        doctorUid: widget.doctorUid,
        patientUid: widget.patientUid,
        createdByUid: currentUser?.uid ?? widget.doctorUid,
        name: name,
        phone: phone,
        relation: relation,
        isEmergencyContact: _isEmergencyContact,
        imageUrl: photoUrl,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } on FirebaseException catch (e) {
      if (!mounted) return;
      final message = e.code == 'permission-denied'
          ? l10n.firestorePermissionDenied
          : (e.message?.trim().isNotEmpty == true
                ? e.message!.trim()
                : l10n.authErrorMessage);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authErrorMessage)),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labelAboveStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: AppColorPalette.white,
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleSpacing: 0,
        title: const Text('Add Family Member'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: appPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: _photoPicker(context)),
              const SizedBox(height: Dimensions.verticalSpacingLarge),
              AppTextField(
                controller: _nameController,
                label: l10n.nameHint,
                hintText: l10n.fieldHintName,
                labelAbove: true,
                labelAboveStyle: labelAboveStyle,
                fillColor: AppColorPalette.white,
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              AppTextField(
                controller: _phoneController,
                label: l10n.phoneHint,
                hintText: l10n.fieldHintPhone,
                labelAbove: true,
                labelAboveStyle: labelAboveStyle,
                fillColor: AppColorPalette.white,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              Text('Relation', style: labelAboveStyle),
              const SizedBox(height: Dimensions.verticalSpacingShort),
              Material(
                color: AppColorPalette.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade400, width: 1.2),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedRelation,
                      isExpanded: true,
                      hint: Text(
                        'Relation (eg. Daughter, Son, Doctor)',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      iconEnabledColor: AppColorPalette.blueSteel,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColorPalette.black,
                      ),
                      items: _relationOptions
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: _saving
                          ? null
                          : (value) =>
                                setState(() => _selectedRelation = value),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              _emergencyCard(context),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              _infoCard(context),
              const SizedBox(height: Dimensions.verticalSpacingLarge),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorPalette.blueSteel,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Contact',
                          style: TextStyle(fontWeight: FontWeight.w700),
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
