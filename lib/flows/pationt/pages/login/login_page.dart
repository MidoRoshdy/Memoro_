import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/string_assets.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../shared/auth/auth_flow_role.dart';
import '../../../../l10n/app_localizations.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/language_switch_icon.dart';
import '../../widgets/primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.role = AuthFlowRole.patient});

  final AuthFlowRole role;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  Color get _roleColor => widget.role == AuthFlowRole.patient
      ? AppColorPalette.blueSteel
      : AppColorPalette.emerald;

  String _roleLabel(AppLocalizations l10n) {
    return widget.role == AuthFlowRole.patient
        ? l10n.chooseFlowPatient
        : l10n.chooseFlowCaregiver;
  }

  String get _registerRoute => widget.role == AuthFlowRole.patient
      ? AppRouter.register
      : AppRouter.doctorRegister;

  String get _forgotRoute => widget.role == AuthFlowRole.patient
      ? AppRouter.forgotPassword
      : AppRouter.doctorForgotPassword;
  String get _homeRoute => widget.role == AuthFlowRole.patient
      ? AppRouter.home
      : AppRouter.doctorHome;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _loading = false;

  void _onLoginFieldsChanged() {
    if (mounted) setState(() {});
  }

  bool get _loginFormComplete {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    return email.isNotEmpty &&
        _emailRegex.hasMatch(email) &&
        password.isNotEmpty &&
        password.length >= 6;
  }

  bool get _emailValid => _emailRegex.hasMatch(_emailController.text.trim());
  bool get _passwordValid => _passwordController.text.trim().length >= 6;

  Widget _validationHint({
    required BuildContext context,
    required bool isValid,
    required String validMessage,
    required String invalidMessage,
  }) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          size: 16,
          color: isValid ? AppColorPalette.authLink : AppColorPalette.redBright,
        ),
        const SizedBox(width: 6),
        Text(
          isValid ? validMessage : invalidMessage,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isValid
                ? AppColorPalette.authLink
                : AppColorPalette.redBright,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onLoginFieldsChanged);
    _passwordController.addListener(_onLoginFieldsChanged);
    _loadRememberState();
  }

  Future<void> _loadRememberState() async {
    final remember = await AuthService.getRememberMe();
    final email = await AuthService.getSavedEmail();
    if (!mounted) return;
    setState(() {
      _rememberMe = remember;
      _emailController.text = email;
    });
  }

  Future<void> _onLogin() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.authInvalidCredentials)));
      return;
    }
    if (!_emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.registerErrorInvalidEmail)));
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.passwordTooShort)));
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.login(
        email: email,
        password: password,
        expectCaregiver: widget.role == AuthFlowRole.doctor,
      );
      await AuthService.saveRememberMe(
        rememberMe: _rememberMe,
        email: _emailController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(_homeRoute);
    } on AuthRoleMismatchException catch (e) {
      if (!mounted) return;
      final message = e.expectedCaregiver
          ? l10n.authCaregiverLoginOnlyMessage
          : l10n.authPatientLoginOnlyMessage;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message =
          (e.code == 'invalid-credential' || e.code == 'user-not-found')
          ? l10n.authInvalidCredentials
          : l10n.authErrorMessage;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } on FirebaseException catch (e) {
      if (!mounted) return;
      final message = e.code == 'permission-denied'
          ? l10n.firestorePermissionDenied
          : l10n.authErrorMessage;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.authErrorMessage)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onTestAccountLogin() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _loading = true);
    try {
      await AuthService.loginWithTestAccount();
      await AuthService.saveRememberMe(
        rememberMe: true,
        email: AuthService.testEmail,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(_homeRoute);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.authErrorMessage)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_onLoginFieldsChanged);
    _passwordController.removeListener(_onLoginFieldsChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final logoSize = MediaQuery.sizeOf(context).width * 0.38;

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
                              l10n.loginWelcomeBack,
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
                              l10n.loginJourneySubtitle,
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
                              label: l10n.emailHint,
                              hintText: l10n.emailHint,
                              labelAbove: true,
                              labelAboveStyle: theme.textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColorPalette.white,
                                  ),
                              fillColor: AppColorPalette.white,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                            ),
                            if (_emailController.text.trim().isNotEmpty) ...[
                              const SizedBox(height: 6),
                              _validationHint(
                                context: context,
                                isValid: _emailValid,
                                validMessage: 'Email looks good',
                                invalidMessage: 'Invalid email format',
                              ),
                            ],
                            longVerticalSpace,
                            AppTextField(
                              controller: _passwordController,
                              label: l10n.passwordHint,
                              hintText: l10n.fieldHintPassword,
                              labelAbove: true,
                              labelAboveStyle: theme.textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColorPalette.white,
                                  ),
                              fillColor: AppColorPalette.white,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              onSubmitted: (_) {
                                if (!_loading && _loginFormComplete) _onLogin();
                              },
                            ),
                            if (_passwordController.text.trim().isNotEmpty) ...[
                              const SizedBox(height: 6),
                              _validationHint(
                                context: context,
                                isValid: _passwordValid,
                                validMessage: 'Password length is valid',
                                invalidMessage:
                                    'Password must be at least 6 characters',
                              ),
                            ],
                            extraShortVerticalSpace,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: _rememberMe,
                                        fillColor:
                                            WidgetStateProperty.resolveWith((
                                              states,
                                            ) {
                                              if (states.contains(
                                                WidgetState.selected,
                                              )) {
                                                return AppColorPalette
                                                    .blueSteel;
                                              }
                                              return AppColorPalette.white;
                                            }),
                                        checkColor: Colors.white,
                                        side: const BorderSide(
                                          color: AppColorPalette.white,
                                        ),
                                        onChanged: (value) {
                                          setState(
                                            () => _rememberMe = value ?? false,
                                          );
                                        },
                                      ),
                                      Expanded(
                                        child: Text(
                                          l10n.rememberMe,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: AppColorPalette.grey,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    foregroundColor: AppColorPalette.white,
                                  ),
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pushNamed(_forgotRoute).then((sent) {
                                      if (!context.mounted) return;
                                      if (sent == true) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              l10n.passwordResetEmailSent,
                                            ),
                                          ),
                                        );
                                      }
                                    });
                                  },
                                  child: Text(
                                    l10n.forgotPasswordLink,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColorPalette.blueSteel,
                                      decorationColor: AppColorPalette.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            shortVerticalSpace,
                            PrimaryButton(
                              label: _loading ? l10n.loading : l10n.loginButton,
                              onPressed: _loading || !_loginFormComplete
                                  ? null
                                  : _onLogin,
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed(_registerRoute);
                                },
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColorPalette.grey,
                                    ),
                                    children: [
                                      TextSpan(text: l10n.loginNoAccountPrefix),
                                      TextSpan(
                                        text: l10n.loginCreateAccountLink,
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
                            const SizedBox(
                              height: Dimensions.horizontalSpacingMedium,
                            ),
                            if (widget.role == AuthFlowRole.patient)
                              CustomButton(
                                label: l10n.testAccountButton,
                                onPressed: _loading
                                    ? () {}
                                    : _onTestAccountLogin,
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
