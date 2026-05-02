import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/string_assets.dart';
import '../../../../core/services/password_reset_service.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../shared/auth/auth_flow_role.dart';
import '../../../shared/auth/otp_verification_page.dart';
import '../../../../l10n/app_localizations.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/language_switch_icon.dart';
import '../../widgets/primary_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, this.role = AuthFlowRole.patient});

  final AuthFlowRole role;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final _emailController = TextEditingController();
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
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSend() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim().toLowerCase();
    debugPrint(
      '[ForgotPassword] Send tapped: email="$email", role=${widget.role}',
    );

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.forgotPasswordEmailRequired)));
      return;
    }
    if (!_emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.forgotPasswordEmailInvalid)));
      return;
    }

    setState(() => _loading = true);
    final stopwatch = Stopwatch()..start();
    try {
      final request = await PasswordResetService.sendOtp(email: email);
      stopwatch.stop();
      debugPrint(
        '[ForgotPassword] OTP requested in '
        '${stopwatch.elapsedMilliseconds}ms ttl=${request.expiresInSeconds}s',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.forgotPasswordOtpSent)));
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OtpVerificationPage(
            role: widget.role,
            email: email,
            expiresInSeconds: request.expiresInSeconds,
          ),
        ),
      );
    } on FirebaseFunctionsException catch (e, st) {
      stopwatch.stop();
      debugPrint(
        '[ForgotPassword] FirebaseFunctionsException after '
        '${stopwatch.elapsedMilliseconds}ms: code=${e.code} message=${e.message}',
      );
      debugPrint('[ForgotPassword] Stack: $st');
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'not-found':
          message = l10n.forgotPasswordEmailNotFound;
          break;
        case 'invalid-argument':
          message = l10n.forgotPasswordEmailInvalid;
          break;
        case 'resource-exhausted':
          message = e.message?.trim().isNotEmpty == true
              ? e.message!
              : l10n.forgotPasswordCooldown;
          break;
        default:
          message = e.message?.trim().isNotEmpty == true
              ? e.message!
              : l10n.forgotPasswordOtpFailed;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
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
      ).showSnackBar(SnackBar(content: Text(l10n.forgotPasswordOtpFailed)));
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
                            AppTextField(
                              controller: _emailController,
                              label: l10n.forgotPasswordEmailLabel,
                              hintText: l10n.fieldHintEmail,
                              labelAbove: true,
                              labelAboveStyle: labelAboveStyle,
                              fillColor: AppColorPalette.white,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.send,
                              autofillHints: const [AutofillHints.email],
                              onSubmitted: (_) {
                                if (!_loading) _onSend();
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
