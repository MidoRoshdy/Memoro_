import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/string_assets.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../shared/auth/auth_flow_role.dart';
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
  Color get _roleColor => widget.role == AuthFlowRole.patient
      ? AppColorPalette.blueSteel
      : AppColorPalette.emerald;

  String _roleLabel(AppLocalizations l10n) {
    return widget.role == AuthFlowRole.patient
        ? l10n.chooseFlowPatient
        : l10n.chooseFlowCaregiver;
  }

  final _emailController = TextEditingController();
  bool _loading = false;

  void _onEmailChanged() {
    if (mounted) setState(() {});
  }

  bool get _emailFilled => _emailController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSend() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _loading = true);
    try {
      await AuthService.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
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
                              label: l10n.emailHint,
                              hintText: l10n.fieldHintEmail,
                              labelAbove: true,
                              labelAboveStyle: labelAboveStyle,
                              fillColor: AppColorPalette.white,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.email],
                              onSubmitted: (_) {
                                if (!_loading && _emailFilled) _onSend();
                              },
                            ),
                            longVerticalSpace,
                            PrimaryButton(
                              label: _loading
                                  ? l10n.loading
                                  : l10n.forgotPasswordSendButton,
                              onPressed: _loading || !_emailFilled
                                  ? null
                                  : _onSend,
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
