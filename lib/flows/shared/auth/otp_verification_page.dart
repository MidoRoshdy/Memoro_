import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/constants/string_assets.dart';
import '../../../core/services/password_reset_service.dart';
import '../../../core/theme/app_color_palette.dart';
import '../../../l10n/app_localizations.dart';
import '../../pationt/widgets/language_switch_icon.dart';
import '../../pationt/widgets/primary_button.dart';
import 'auth_flow_role.dart';
import 'reset_password_page.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({
    super.key,
    required this.role,
    required this.email,
    this.expiresInSeconds = 600,
  });

  final AuthFlowRole role;
  final String email;
  final int expiresInSeconds;

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  static const int _otpLength = 6;
  static const int _resendCooldownSeconds = 30;

  late final List<TextEditingController> _digitControllers;
  late final List<FocusNode> _digitFocusNodes;

  bool _resending = false;
  bool _verifying = false;
  Timer? _cooldownTimer;
  int _cooldownRemaining = _resendCooldownSeconds;

  Color get _roleColor => widget.role == AuthFlowRole.patient
      ? AppColorPalette.blueSteel
      : AppColorPalette.emerald;

  @override
  void initState() {
    super.initState();
    _digitControllers =
        List.generate(_otpLength, (_) => TextEditingController());
    _digitFocusNodes = List.generate(_otpLength, (_) => FocusNode());
    _startCooldownTimer();
  }

  @override
  void dispose() {
    for (final c in _digitControllers) {
      c.dispose();
    }
    for (final f in _digitFocusNodes) {
      f.dispose();
    }
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    setState(() => _cooldownRemaining = _resendCooldownSeconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldownRemaining <= 1) {
        timer.cancel();
        setState(() => _cooldownRemaining = 0);
      } else {
        setState(() => _cooldownRemaining -= 1);
      }
    });
  }

  String get _enteredCode =>
      _digitControllers.map((c) => c.text.trim()).join();

  bool get _codeComplete => _enteredCode.length == _otpLength;

  Future<void> _onContinue() async {
    if (!_codeComplete || _verifying) return;
    final l10n = AppLocalizations.of(context)!;
    final code = _enteredCode;
    setState(() => _verifying = true);
    try {
      await PasswordResetService.verifyOtp(email: widget.email, otp: code);
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ResetPasswordPage(
            role: widget.role,
            email: widget.email,
            otp: code,
          ),
        ),
      );
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'permission-denied':
        case 'not-found':
          message = l10n.otpInvalidCode;
          break;
        case 'deadline-exceeded':
          message = l10n.otpExpired;
          break;
        case 'resource-exhausted':
          message = l10n.otpTooManyAttempts;
          break;
        case 'invalid-argument':
          message = l10n.otpInvalidCode;
          break;
        default:
          message = e.message?.trim().isNotEmpty == true
              ? e.message!
              : l10n.otpInvalidCode;
      }
      _clearDigits();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      _clearDigits();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.otpInvalidCode)));
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  void _clearDigits() {
    for (final c in _digitControllers) {
      c.clear();
    }
    _digitFocusNodes.first.requestFocus();
    setState(() {});
  }

  Future<void> _onResend() async {
    if (_resending || _cooldownRemaining > 0) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _resending = true);
    try {
      await PasswordResetService.sendOtp(email: widget.email);
      if (!mounted) return;
      setState(() {
        for (final c in _digitControllers) {
          c.clear();
        }
        _digitFocusNodes.first.requestFocus();
      });
      _startCooldownTimer();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.forgotPasswordOtpSent)));
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'resource-exhausted':
          message = e.message?.trim().isNotEmpty == true
              ? e.message!
              : l10n.forgotPasswordCooldown;
          break;
        case 'not-found':
          message = l10n.forgotPasswordEmailNotFound;
          break;
        default:
          message = e.message?.trim().isNotEmpty == true
              ? e.message!
              : l10n.forgotPasswordOtpFailed;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.forgotPasswordOtpFailed)));
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  void _handleDigitChange(int index, String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 1) {
      for (var i = 0; i < _otpLength - index; i++) {
        if (i < digits.length) {
          _digitControllers[index + i].text = digits[i];
        }
      }
      final nextIndex = (index + digits.length).clamp(0, _otpLength - 1);
      _digitFocusNodes[nextIndex].requestFocus();
    } else if (digits.isNotEmpty) {
      _digitControllers[index].text = digits;
      if (index < _otpLength - 1) {
        _digitFocusNodes[index + 1].requestFocus();
      } else {
        _digitFocusNodes[index].unfocus();
      }
    }
    setState(() {});
  }

  KeyEventResult _handleBackspace(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_digitControllers[index].text.isEmpty && index > 0) {
        _digitControllers[index - 1].clear();
        _digitFocusNodes[index - 1].requestFocus();
        setState(() {});
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  Widget _digitBox(int index) {
    return SizedBox(
      width: 48,
      height: 56,
      child: Focus(
        onKeyEvent: (_, event) => _handleBackspace(index, event),
        child: TextField(
          controller: _digitControllers[index],
          focusNode: _digitFocusNodes[index],
          enabled: !_verifying,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          showCursor: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColorPalette.blueSteel,
                fontWeight: FontWeight.w800,
              ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _roleColor, width: 1.6),
            ),
          ),
          onChanged: (value) => _handleDigitChange(index, value),
        ),
      ),
    );
  }

  String _maskedEmail(String email) {
    final trimmed = email.trim();
    final atIndex = trimmed.indexOf('@');
    if (atIndex <= 1) return trimmed;
    final localPart = trimmed.substring(0, atIndex);
    final domain = trimmed.substring(atIndex);
    if (localPart.length <= 2) return trimmed;
    final visibleStart = localPart.substring(0, 2);
    final masked = '*' * (localPart.length - 2);
    return '$visibleStart$masked$domain';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final logoSize = MediaQuery.sizeOf(context).width * 0.34;

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
                      onPressed: () => Navigator.of(context).pop(),
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
                            Text(
                              l10n.otpScreenTitle,
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
                              l10n.otpInstructions(_maskedEmail(widget.email)),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: AppColorPalette.white,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(
                              height: Dimensions.horizontalSpacingLarge,
                            ),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  for (var i = 0; i < _otpLength; i++)
                                    _digitBox(i),
                                ],
                              ),
                            ),
                            longVerticalSpace,
                            PrimaryButton(
                              label: _verifying
                                  ? l10n.otpVerifying
                                  : l10n.otpVerifyButton,
                              onPressed: (_codeComplete && !_verifying)
                                  ? _onContinue
                                  : null,
                            ),
                            mediumVerticalSpace,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n.otpResendPrompt,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColorPalette.white.withValues(
                                      alpha: 0.85,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                if (_cooldownRemaining > 0)
                                  Text(
                                    l10n.otpResendCooldown(_cooldownRemaining),
                                    style:
                                        theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColorPalette.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                else
                                  TextButton(
                                    onPressed: _resending ? null : _onResend,
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColorPalette.white,
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      l10n.otpResendAction,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: AppColorPalette.white,
                                        fontWeight: FontWeight.w800,
                                        decoration:
                                            TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                              ],
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
