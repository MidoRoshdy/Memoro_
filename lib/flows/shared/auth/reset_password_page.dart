import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/constants/string_assets.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/password_reset_service.dart';
import '../../../core/theme/app_color_palette.dart';
import '../../../l10n/app_localizations.dart';
import '../../pationt/widgets/app_text_field.dart';
import '../../pationt/widgets/language_switch_icon.dart';
import '../../pationt/widgets/primary_button.dart';
import 'auth_flow_role.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({
    super.key,
    required this.role,
    required this.email,
    required this.otp,
  });

  final AuthFlowRole role;
  final String email;
  final String otp;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _submitting = false;

  Color get _roleColor => widget.role == AuthFlowRole.patient
      ? AppColorPalette.blueSteel
      : AppColorPalette.emerald;

  String get _loginRoute => widget.role == AuthFlowRole.patient
      ? AppRouter.login
      : AppRouter.doctorLogin;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_onChanged);
    _confirmPasswordController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  bool get _formValid {
    final pwd = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();
    return pwd.length >= 6 && pwd == confirm;
  }

  Future<void> _onSubmit() async {
    final l10n = AppLocalizations.of(context)!;
    final pwd = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (pwd.length < 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.passwordTooShort)));
      return;
    }
    if (pwd != confirm) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.resetPasswordMismatch)));
      return;
    }

    setState(() => _submitting = true);
    try {
      await PasswordResetService.verifyOtpAndCommit(
        email: widget.email,
        otp: widget.otp,
        newPassword: pwd,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.resetPasswordSuccess)));
      Navigator.of(context).pushNamedAndRemoveUntil(
        _loginRoute,
        (route) => false,
      );
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'not-found':
          message = l10n.otpInvalidCode;
          break;
        case 'deadline-exceeded':
          message = l10n.otpExpired;
          break;
        case 'permission-denied':
          message = l10n.otpInvalidCode;
          break;
        case 'resource-exhausted':
          message = l10n.otpTooManyAttempts;
          break;
        case 'invalid-argument':
          message = l10n.passwordTooShort;
          break;
        default:
          message = e.message?.trim().isNotEmpty == true
              ? e.message!
              : l10n.resetPasswordGenericError;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.resetPasswordGenericError)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final logoSize = MediaQuery.sizeOf(context).width * 0.32;
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 4,
                  end: 8,
                  bottom: 4,
                ),
                child: Row(
                  children: [
                    BackButton(
                      color: AppColorPalette.white,
                      onPressed: _submitting
                          ? null
                          : () => Navigator.of(context).pushNamedAndRemoveUntil(
                                _loginRoute,
                                (route) => false,
                              ),
                    ),
                    const Spacer(),
                    const LanguageSwitchIcon(),
                  ],
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Image.asset(
                                AppAssets.memoroLogoOnly,
                                width: logoSize.clamp(120.0, 180.0),
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                            const SizedBox(
                              height: Dimensions.horizontalSpacingLarge,
                            ),
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.horizontalSpacingMedium,
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
                                widget.role == AuthFlowRole.patient
                                    ? l10n.chooseFlowPatient
                                    : l10n.chooseFlowCaregiver,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: Dimensions.horizontalSpacingMedium,
                            ),
                            Text(
                              l10n.resetPasswordTitle,
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
                              l10n.resetPasswordSubtitle,
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
                              controller: _newPasswordController,
                              label: l10n.resetPasswordNewLabel,
                              hintText: l10n.resetPasswordNewLabel,
                              labelAbove: true,
                              labelAboveStyle: labelAboveStyle,
                              fillColor: AppColorPalette.white,
                              obscureText: true,
                              showPasswordVisibilityToggle: true,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.newPassword],
                            ),
                            mediumVerticalSpace,
                            AppTextField(
                              controller: _confirmPasswordController,
                              label: l10n.resetPasswordConfirmLabel,
                              hintText: l10n.resetPasswordConfirmLabel,
                              labelAbove: true,
                              labelAboveStyle: labelAboveStyle,
                              fillColor: AppColorPalette.white,
                              obscureText: true,
                              showPasswordVisibilityToggle: true,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.newPassword],
                              onSubmitted: (_) {
                                if (!_submitting && _formValid) _onSubmit();
                              },
                            ),
                            longVerticalSpace,
                            PrimaryButton(
                              label: _submitting
                                  ? l10n.loading
                                  : l10n.resetPasswordSubmitButton,
                              onPressed: _submitting || !_formValid
                                  ? null
                                  : _onSubmit,
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
