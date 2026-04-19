import 'package:flutter/material.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../../widgets/language_picker_sheet.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = false;

  Widget _item({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Container(
      padding: appPadding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(Dimensions.cardCornerRadius),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: iconBg,
            child: Icon(icon, size: 16, color: AppColorPalette.blueSteel),
          ),
          const SizedBox(width: Dimensions.horizontalSpacingRegular),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColorPalette.grey),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: appPadding,
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      l10n.settingsScreenTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              ValueListenableBuilder<Locale?>(
                valueListenable: LocaleController.locale,
                builder: (context, loc, _) {
                  final label = loc?.languageCode == 'ar'
                      ? l10n.arabicLabel
                      : l10n.englishLabel;
                  return InkWell(
                    onTap: () => showLanguagePickerSheet(context),
                    borderRadius: BorderRadius.circular(
                      Dimensions.cardCornerRadius,
                    ),
                    child: _item(
                      context: context,
                      icon: Icons.language,
                      iconBg: const Color(0xFFE8F3FF),
                      title: l10n.languageLabel,
                      subtitle: l10n.settingsLanguageSubtitle,
                      trailing: Text(
                        '$label  >',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColorPalette.grey,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              _item(
                context: context,
                icon: Icons.notifications_active_outlined,
                iconBg: const Color(0xFFE5F8EC),
                title: l10n.settingsNotificationsTitle,
                subtitle: l10n.settingsNotificationsSubtitle,
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (v) => setState(() => _notificationsEnabled = v),
                  activeThumbColor: AppColorPalette.blueSteel,
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              _item(
                context: context,
                icon: Icons.volume_up_outlined,
                iconBg: const Color(0xFFEDE7FF),
                title: l10n.settingsSoundTitle,
                subtitle: l10n.settingsSoundSubtitle,
                trailing: Switch(
                  value: _soundEnabled,
                  onChanged: (v) => setState(() => _soundEnabled = v),
                  activeThumbColor: AppColorPalette.blueSteel,
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              Container(
                width: double.infinity,
                padding: appPadding,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(
                    Dimensions.cardCornerRadius,
                  ),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFFE8F3FF),
                      child: Icon(
                        Icons.help_outline,
                        color: AppColorPalette.blueBright,
                      ),
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingRegular),
                    Text(
                      l10n.settingsNeedHelpTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l10n.settingsNeedHelpSubtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColorPalette.grey,
                      ),
                    ),
                    const SizedBox(height: Dimensions.verticalSpacingRegular),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColorPalette.blueSteel,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(l10n.settingsContactSupport),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
