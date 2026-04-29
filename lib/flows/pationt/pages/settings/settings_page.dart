import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../core/services/local_notification_service.dart';
import '../../../../core/services/notification_inbox_service.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../../widgets/language_picker_sheet.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const String _notificationsEnabledKey =
      'settings_notifications_enabled';
  static const String _soundEnabledKey = 'settings_sound_enabled';
  static const String _supportEmail = 'support@memoro.app';

  bool _notificationsEnabled = true;
  bool _soundEnabled = false;
  bool _loadingPrefs = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
      _soundEnabled = prefs.getBool(_soundEnabledKey) ?? false;
      _loadingPrefs = false;
    });
  }

  Future<void> _toggleNotifications(bool enabled) async {
    final l10n = AppLocalizations.of(context)!;
    final prefs = await SharedPreferences.getInstance();
    if (enabled) {
      final granted = await NotificationInboxService.requestPermissions();
      if (!granted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification permission denied')),
        );
        setState(() => _notificationsEnabled = false);
        await prefs.setBool(_notificationsEnabledKey, false);
        return;
      }
      await NotificationInboxService.registerCurrentDeviceWithRetry();
    } else {
      await LocalNotificationService.cancelAll();
    }
    await prefs.setBool(_notificationsEnabledKey, enabled);
    if (!mounted) return;
    setState(() => _notificationsEnabled = enabled);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          enabled
              ? l10n.settingsNotificationsTitle
              : '${l10n.settingsNotificationsTitle} OFF',
        ),
      ),
    );
  }

  Future<void> _toggleSound(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, enabled);
    if (!mounted) return;
    setState(() => _soundEnabled = enabled);
  }

  Future<void> _contactSupport() async {
    final mailUri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: <String, String>{'subject': 'Memoro Support'},
    );
    final launchedMail = await launchUrl(
      mailUri,
      mode: LaunchMode.externalApplication,
    );
    if (launchedMail) return;

    final webFallbackUri = Uri.parse(
      'https://mail.google.com/mail/?view=cm&fs=1&to=$_supportEmail&su=Memoro%20Support',
    );
    final launchedWeb = await launchUrl(
      webFallbackUri,
      mode: LaunchMode.externalApplication,
    );
    if (launchedWeb || !mounted) return;

    await Clipboard.setData(const ClipboardData(text: _supportEmail));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Support email copied: $_supportEmail')),
    );
  }

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
    if (_loadingPrefs) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
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
                  onChanged: _toggleNotifications,
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
                  onChanged: _toggleSound,
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
                        onPressed: _contactSupport,
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
