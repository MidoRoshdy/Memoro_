import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/string_assets.dart';
import '../../../../core/services/password_reset_service.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../shared/auth/auth_flow_role.dart';
import '../../../shared/auth/otp_verification_page.dart';
import '../../../../l10n/app_localizations.dart';
import '../../widgets/language_switch_icon.dart';
import '../../widgets/primary_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, this.role = AuthFlowRole.patient});

  final AuthFlowRole role;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  static const double _fieldRadius = 12;

  final _phoneController = TextEditingController();
  String _phoneCompleteNumber = '';
  bool _phoneIsValid = false;
  bool _loading = false;

  Color get _roleColor => widget.role == AuthFlowRole.patient
      ? AppColorPalette.blueSteel
      : AppColorPalette.emerald;

  String _roleLabel(AppLocalizations l10n) {
    return widget.role == AuthFlowRole.patient
        ? l10n.chooseFlowPatient
        : l10n.chooseFlowCaregiver;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

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
      focusedBorder: border(_roleColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      counterText: '',
    );
  }

  Future<void> _onSend() async {
    final l10n = AppLocalizations.of(context)!;
    final phone = _phoneCompleteNumber.trim();
    debugPrint(
      '[ForgotPassword] Send tapped: phone="$phone", '
      'role=${widget.role}, valid=$_phoneIsValid',
    );

    if (phone.isEmpty || !_phoneIsValid) {
      debugPrint(
        '[ForgotPassword] Aborting: phone empty or invalid (raw="$phone").',
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.forgotPasswordPhoneRequired)));
      return;
    }

    setState(() => _loading = true);
    final stopwatch = Stopwatch()..start();
    try {
      debugPrint('[ForgotPassword] Clearing any previous temp auth session…');
      await PasswordResetService.clearTempSession();

      debugPrint('[ForgotPassword] Calling verifyPhoneNumber for $phone…');
      final verification = await PasswordResetService.sendOtp(
        phoneNumber: phone,
      );
      stopwatch.stop();
      debugPrint(
        '[ForgotPassword] OTP code dispatched in '
        '${stopwatch.elapsedMilliseconds}ms. '
        'verificationId=${verification.verificationId} '
        'resendToken=${verification.resendToken} '
        'phone=${verification.phoneNumber}',
      );

      if (!mounted) {
        debugPrint('[ForgotPassword] Widget unmounted before navigation.');
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.forgotPasswordSmsSent)));
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OtpVerificationPage(
            role: widget.role,
            verification: verification,
          ),
        ),
      );
    } on FirebaseAuthException catch (e, st) {
      stopwatch.stop();
      debugPrint(
        '[ForgotPassword] FirebaseAuthException after '
        '${stopwatch.elapsedMilliseconds}ms: '
        'code=${e.code}, message=${e.message}',
      );
      debugPrint('[ForgotPassword] Stack: $st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? l10n.forgotPasswordSmsFailed)),
      );
    } catch (e, st) {
      stopwatch.stop();
      debugPrint(
        '[ForgotPassword] Unexpected error after '
        '${stopwatch.elapsedMilliseconds}ms: $e',
      );
      debugPrint('[ForgotPassword] Stack: $st');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.forgotPasswordSmsFailed)));
    } finally {
      if (mounted) setState(() => _loading = false);
      debugPrint('[ForgotPassword] _onSend finished.');
    }
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
                      onPressed: () => Navigator.of(context).pop(false),
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
                              l10n.forgotPasswordTitle,
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
                              l10n.forgotPasswordSubtitle,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: AppColorPalette.white,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(
                              height: Dimensions.horizontalSpacingLarge,
                            ),
                            Text(
                              l10n.forgotPasswordPhoneLabel,
                              style: labelAboveStyle,
                            ),
                            shortVerticalSpace,
                            IntlPhoneField(
                              controller: _phoneController,
                              enabled: !_loading,
                              initialCountryCode: 'EG',
                              languageCode: Localizations.localeOf(
                                context,
                              ).languageCode,
                              textInputAction: TextInputAction.done,
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
                              validator: (phone) {
                                _phoneIsValid =
                                    phone != null && phone.number.isNotEmpty;
                                return null;
                              },
                            ),
                            longVerticalSpace,
                            PrimaryButton(
                              label: _loading
                                  ? l10n.loading
                                  : l10n.forgotPasswordSendButton,
                              onPressed: _loading ? null : _onSend,
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
