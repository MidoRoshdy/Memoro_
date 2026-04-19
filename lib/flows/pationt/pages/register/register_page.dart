import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/string_assets.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../shared/auth/auth_flow_role.dart';
import '../../../../l10n/app_localizations.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/language_switch_icon.dart';
import '../../widgets/primary_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.role = AuthFlowRole.patient});

  final AuthFlowRole role;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  Color get _roleColor => widget.role == AuthFlowRole.patient
      ? AppColorPalette.blueSteel
      : AppColorPalette.emerald;

  String _roleLabel(AppLocalizations l10n) {
    return widget.role == AuthFlowRole.patient
        ? l10n.chooseFlowPatient
        : l10n.chooseFlowCaregiver;
  }

  String get _loginRoute => widget.role == AuthFlowRole.patient
      ? AppRouter.login
      : AppRouter.doctorLogin;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();

  XFile? _profilePhoto;
  Uint8List? _profilePreviewBytes;
  String? _gender;
  bool _termsAccepted = false;
  bool _loading = false;

  /// E.164-style value from [IntlPhoneField] (`countryCode` + national `number`).
  String _phoneCompleteNumber = '';

  static const double _fieldRadius = 12;

  InputDecoration _phoneDecoration(ThemeData theme, AppLocalizations l10n) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(_fieldRadius),
      borderSide: BorderSide(color: color, width: 1.2),
    );
    return InputDecoration(
      hintText: l10n.fieldHintPhone,
      hintStyle: theme.textTheme.bodyLarge?.copyWith(
        color: Colors.grey.shade600,
      ),
      filled: true,
      fillColor: AppColorPalette.white,
      border: border(Colors.grey.shade400),
      enabledBorder: border(Colors.grey.shade400),
      focusedBorder: border(AppColorPalette.blueSteel),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      counterText: '',
    );
  }

  void _onRegisterFieldsChanged() {
    if (mounted) setState(() {});
  }

  bool get _registerFormComplete {
    if (_nameController.text.trim().isEmpty) return false;
    if (_emailController.text.trim().isEmpty) return false;
    if (_phoneController.text.trim().isEmpty) return false;
    if (_gender == null) return false;
    final age = int.tryParse(_ageController.text.trim());
    if (age == null || age < 1 || age > 120) return false;
    if (_passwordController.text.trim().length < 6) return false;
    if (!_termsAccepted) return false;
    return true;
  }

  String _registerAuthErrorMessage(AppLocalizations l10n, String code) {
    switch (code) {
      case 'weak-password':
        return l10n.registerErrorWeakPassword;
      case 'email-already-in-use':
        return l10n.registerErrorEmailInUse;
      case 'invalid-email':
        return l10n.registerErrorInvalidEmail;
      case 'operation-not-allowed':
        return l10n.registerErrorOperationNotAllowed;
      case 'network-request-failed':
        return l10n.registerErrorNetwork;
      default:
        return l10n.authErrorMessage;
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onRegisterFieldsChanged);
    _emailController.addListener(_onRegisterFieldsChanged);
    _phoneController.addListener(_onRegisterFieldsChanged);
    _ageController.addListener(_onRegisterFieldsChanged);
    _passwordController.addListener(_onRegisterFieldsChanged);
  }

  void _showTermsDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.termsTitle),
        content: SingleChildScrollView(child: Text(l10n.termsBody)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.dialogClose),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final x = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (x == null || !mounted) return;
      final bytes = await x.readAsBytes();
      setState(() {
        _profilePhoto = x;
        _profilePreviewBytes = bytes;
      });
    } on PlatformException catch (e, st) {
      debugPrint('image_picker PlatformException: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.imagePickerError)));
    } on MissingPluginException catch (e, st) {
      debugPrint('image_picker MissingPluginException: $e\n$st');
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

  Future<void> _onRegister() async {
    final l10n = AppLocalizations.of(context)!;
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.phoneRequired)));
      return;
    }
    if (_gender == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.genderRequired)));
      return;
    }
    final age = int.tryParse(_ageController.text.trim());
    if (age == null || age < 1 || age > 120) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.ageInvalid)));
      return;
    }
    if (!_termsAccepted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.termsRequired)));
      return;
    }
    if (_passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.passwordTooShort)));
      return;
    }
    if (Firebase.apps.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.firebaseNotConfigured)));
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneCompleteNumber.isNotEmpty
            ? _phoneCompleteNumber
            : _phoneController.text.trim(),
        password: _passwordController.text.trim(),
        gender: _gender!,
        age: age,
        termsAccepted: _termsAccepted,
        profilePhoto: _profilePhoto,
        isCaregiver: widget.role == AuthFlowRole.doctor,
      );
      if (!mounted) return;
      await AuthService.logout();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.registerSuccess)));
      Navigator.of(context).pushReplacementNamed(_loginRoute);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      debugPrint('Register FirebaseAuthException: ${e.code} ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_registerAuthErrorMessage(l10n, e.code))),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      debugPrint('Register FirebaseException: ${e.code} ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.code == 'permission-denied'
                ? l10n.firestorePermissionDenied
                : l10n.authErrorMessage,
          ),
        ),
      );
    } catch (e, st) {
      if (!mounted) return;
      debugPrint('Register failed: $e\n$st');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.authErrorMessage)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onRegisterFieldsChanged);
    _emailController.removeListener(_onRegisterFieldsChanged);
    _phoneController.removeListener(_onRegisterFieldsChanged);
    _ageController.removeListener(_onRegisterFieldsChanged);
    _passwordController.removeListener(_onRegisterFieldsChanged);
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final logoSize = MediaQuery.sizeOf(context).width * 0.38;
    final labelAboveStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: AppColorPalette.white,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8, bottom: 4),
                  child: const LanguageSwitchIcon(),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: appHorizontalPadding,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            shortVerticalSpace,
                            Center(
                              child: Image.asset(
                                AppAssets.memoroLogoOnly,
                                width: logoSize.clamp(140.0, 200.0),
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                            const SizedBox(
                              height: Dimensions.horizontalSpacingLarge,
                            ),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal:
                                      Dimensions.horizontalSpacingMedium,
                                  vertical: Dimensions.verticalSpacingShort,
                                ),
                                decoration: BoxDecoration(
                                  color: _roleColor.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(
                                    containerRadius,
                                  ),
                                  border: Border.all(
                                    color: _roleColor.withValues(alpha: 0.45),
                                  ),
                                ),
                                child: Text(
                                  _roleLabel(l10n),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: Dimensions.horizontalSpacingMedium,
                            ),
                            Text(
                              l10n.registerWelcomeTitle,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColorPalette.white,
                              ),
                            ),
                            const SizedBox(
                              height: Dimensions.horizontalSpacingRegular,
                            ),
                            Text(
                              l10n.registerWelcomeSubtitle,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: AppColorPalette.white,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(
                              height: Dimensions.horizontalSpacingLarge,
                            ),
                            AppTextField(
                              controller: _nameController,
                              label: l10n.nameHint,
                              hintText: l10n.fieldHintName,
                              labelAbove: true,
                              labelAboveStyle: labelAboveStyle,
                              fillColor: AppColorPalette.white,
                              textInputAction: TextInputAction.next,
                            ),
                            mediumVerticalSpace,
                            AppTextField(
                              controller: _emailController,
                              label: l10n.emailHint,
                              hintText: l10n.fieldHintEmail,
                              labelAbove: true,
                              labelAboveStyle: labelAboveStyle,
                              fillColor: AppColorPalette.white,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                            ),
                            mediumVerticalSpace,
                            Text(l10n.phoneHint, style: labelAboveStyle),
                            shortVerticalSpace,
                            IntlPhoneField(
                              controller: _phoneController,
                              enabled: !_loading,
                              initialCountryCode: 'EG',
                              languageCode: Localizations.localeOf(
                                context,
                              ).languageCode,
                              textInputAction: TextInputAction.next,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              invalidNumberMessage: l10n.invalidPhoneNumber,
                              disableLengthCheck: false,
                              decoration: _phoneDecoration(theme, l10n),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: AppColorPalette.black,
                              ),
                              dropdownTextStyle: theme.textTheme.bodyLarge
                                  ?.copyWith(color: AppColorPalette.black),
                              flagsButtonPadding:
                                  const EdgeInsetsDirectional.only(start: 8),
                              onChanged: (PhoneNumber phone) {
                                setState(() {
                                  _phoneCompleteNumber = phone.completeNumber;
                                });
                              },
                            ),
                            mediumVerticalSpace,
                            Text(l10n.genderLabel, style: labelAboveStyle),
                            shortVerticalSpace,
                            Material(
                              color: AppColorPalette.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  _fieldRadius,
                                ),
                                side: BorderSide(
                                  color: Colors.grey.shade400,
                                  width: 1.2,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _gender,
                                    isExpanded: true,
                                    hint: Text(
                                      l10n.genderSelectHint,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                    ),
                                    iconEnabledColor: AppColorPalette.blueSteel,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: AppColorPalette.black,
                                    ),
                                    items: [
                                      DropdownMenuItem(
                                        value: 'male',
                                        child: Text(l10n.genderMale),
                                      ),
                                      DropdownMenuItem(
                                        value: 'female',
                                        child: Text(l10n.genderFemale),
                                      ),
                                    ],
                                    onChanged: _loading
                                        ? null
                                        : (v) => setState(() => _gender = v),
                                  ),
                                ),
                              ),
                            ),
                            mediumVerticalSpace,
                            AppTextField(
                              controller: _ageController,
                              label: l10n.ageHint,
                              hintText: l10n.fieldHintAge,
                              labelAbove: true,
                              labelAboveStyle: labelAboveStyle,
                              fillColor: AppColorPalette.white,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.birthdayYear],
                            ),
                            mediumVerticalSpace,
                            AppTextField(
                              controller: _passwordController,
                              label: l10n.passwordHint,
                              hintText: l10n.fieldHintPassword,
                              labelAbove: true,
                              labelAboveStyle: labelAboveStyle,
                              fillColor: AppColorPalette.white,
                              obscureText: true,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.newPassword],
                            ),
                            mediumVerticalSpace,
                            Text(
                              l10n.profilePhotoLabel,
                              style: labelAboveStyle,
                            ),
                            shortVerticalSpace,
                            Center(
                              child: Column(
                                children: [
                                  Material(
                                    color: AppColorPalette.white,
                                    borderRadius: BorderRadius.circular(12),
                                    clipBehavior: Clip.antiAlias,
                                    child: InkWell(
                                      onTap: _loading ? null : _pickFromGallery,
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey.shade400,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: _profilePreviewBytes != null
                                            ? Image.memory(
                                                _profilePreviewBytes!,
                                                fit: BoxFit.cover,
                                                width: 120,
                                                height: 120,
                                              )
                                            : Icon(
                                                Icons
                                                    .add_photo_alternate_outlined,
                                                size: 48,
                                                color: Colors.grey.shade600,
                                              ),
                                      ),
                                    ),
                                  ),
                                  shortVerticalSpace,
                                  TextButton.icon(
                                    onPressed: _loading
                                        ? null
                                        : _pickFromGallery,
                                    icon: const Icon(
                                      Icons.photo_library_outlined,
                                      color: AppColorPalette.white,
                                      size: 20,
                                    ),
                                    label: Text(
                                      l10n.chooseFromGallery,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: AppColorPalette.white,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor:
                                                AppColorPalette.white,
                                          ),
                                    ),
                                  ),
                                  if (_profilePreviewBytes != null)
                                    TextButton(
                                      onPressed: _loading
                                          ? null
                                          : _clearProfilePhoto,
                                      child: Text(
                                        l10n.removeProfilePhoto,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: AppColorPalette.grey,
                                            ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            extraShortVerticalSpace,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _termsAccepted,
                                  fillColor: WidgetStateProperty.resolveWith((
                                    states,
                                  ) {
                                    if (states.contains(WidgetState.selected)) {
                                      return AppColorPalette.blueSteel;
                                    }
                                    return AppColorPalette.white;
                                  }),
                                  checkColor: Colors.white,
                                  side: const BorderSide(
                                    color: AppColorPalette.white,
                                  ),
                                  onChanged: _loading
                                      ? null
                                      : (v) => setState(
                                          () => _termsAccepted = v ?? false,
                                        ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 0,
                                      runSpacing: 4,
                                      children: [
                                        Text(
                                          l10n.termsAgreementPrefix,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: AppColorPalette.grey,
                                              ),
                                        ),
                                        GestureDetector(
                                          onTap: _showTermsDialog,
                                          child: Text(
                                            l10n.termsAgreementLink,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color:
                                                      AppColorPalette.blueSteel,
                                                  fontWeight: FontWeight.w600,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor:
                                                      AppColorPalette.blueSteel,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            PrimaryButton(
                              label: _loading
                                  ? l10n.loading
                                  : l10n.createAccountButton,
                              onPressed: _loading || !_registerFormComplete
                                  ? null
                                  : _onRegister,
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pushReplacementNamed(_loginRoute);
                                },
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColorPalette.grey,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: l10n.registerHaveAccountPrefix,
                                      ),
                                      TextSpan(
                                        text: l10n.registerSignInLink,
                                        style: const TextStyle(
                                          color: AppColorPalette.blueSteel,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            veryLongVerticalSpace,
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
