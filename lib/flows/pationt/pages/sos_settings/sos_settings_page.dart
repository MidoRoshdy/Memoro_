import 'package:flutter/material.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';

class SosSettingsPage extends StatefulWidget {
  const SosSettingsPage({super.key});

  @override
  State<SosSettingsPage> createState() => _SosSettingsPageState();
}

class _SosSettingsPageState extends State<SosSettingsPage> {
  bool _shareLocation = true;
  bool _autoCall = true;

  Widget _rowCard({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        l10n.sosSettingsScreenTitle,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: Color(0xFFFFEBEE),
                            child: Icon(
                              Icons.phone_in_talk,
                              color: AppColorPalette.redDark,
                              size: 16,
                            ),
                          ),
                          const SizedBox(
                            width: Dimensions.horizontalSpacingRegular,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.sosEmergencyContactTitle,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                l10n.sosPrimaryCaregiverSubtitle,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColorPalette.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.verticalSpacingRegular),
                      Text(l10n.sosCaregiverNameLabel),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(
                          Dimensions.horizontalSpacingRegular,
                        ),
                        margin: const EdgeInsets.only(
                          top: Dimensions.verticalSpacingExtraShort,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(containerRadius),
                        ),
                        child: Text(l10n.sosPlaceholderCaregiverName),
                      ),
                      const SizedBox(height: Dimensions.verticalSpacingRegular),
                      Text(l10n.sosPhoneNumberLabel),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(
                          Dimensions.horizontalSpacingRegular,
                        ),
                        margin: const EdgeInsets.only(
                          top: Dimensions.verticalSpacingExtraShort,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(containerRadius),
                        ),
                        child: Text(l10n.sosPlaceholderPhone),
                      ),
                      const SizedBox(height: Dimensions.verticalSpacingRegular),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.call),
                          label: Text(l10n.sosCallEmergencyContact),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColorPalette.redBright,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.verticalSpacingLarge),
                Text(
                  l10n.sosOptionsHeader,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: Dimensions.verticalSpacingRegular),
                _rowCard(
                  context: context,
                  icon: Icons.location_on_outlined,
                  iconBg: const Color(0xFFE6F5FD),
                  title: l10n.sosShareLocationTitle,
                  subtitle: l10n.sosShareLocationSubtitle,
                  trailing: Switch(
                    value: _shareLocation,
                    onChanged: (v) => setState(() => _shareLocation = v),
                    activeThumbColor: AppColorPalette.blueSteel,
                  ),
                ),
                const SizedBox(height: Dimensions.verticalSpacingRegular),
                _rowCard(
                  context: context,
                  icon: Icons.call,
                  iconBg: const Color(0xFFE8F3FF),
                  title: l10n.sosAutoCallTitle,
                  subtitle: l10n.sosAutoCallSubtitle,
                  trailing: Switch(
                    value: _autoCall,
                    onChanged: (v) => setState(() => _autoCall = v),
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
                          Icons.shield_outlined,
                          color: AppColorPalette.blueSteel,
                        ),
                      ),
                      const SizedBox(height: Dimensions.verticalSpacingRegular),
                      Text(
                        l10n.sosTestSystemTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        l10n.sosTestSystemSubtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColorPalette.grey,
                        ),
                      ),
                      const SizedBox(height: Dimensions.verticalSpacingRegular),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(l10n.sosTestButton),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColorPalette.blueSteel,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.verticalSpacingRegular),
                Container(
                  width: double.infinity,
                  padding: appPadding,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFCEB),
                    borderRadius: BorderRadius.circular(
                      Dimensions.cardCornerRadius,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColorPalette.gold,
                          ),
                          const SizedBox(
                            width: Dimensions.horizontalSpacingRegular,
                          ),
                          Text(
                            l10n.sosHowItWorksTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.verticalSpacingShort),
                      Text(l10n.sosHowItWorksBullet1),
                      Text(l10n.sosHowItWorksBullet2),
                      Text(l10n.sosHowItWorksBullet3),
                    ],
                  ),
                ),
                const SizedBox(height: bottomNavigationBarPadding),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
