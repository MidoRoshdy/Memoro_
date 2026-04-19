import 'package:flutter/material.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/string_assets.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

enum _NotificationTab { today, reminders, earlier }

class _NotificationEntry {
  const _NotificationEntry({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.tab,
    this.iconBg = const Color(0xFFE6F0FF),
  });

  final String title;
  final String subtitle;
  final String time;
  final Widget icon;
  final _NotificationTab tab;
  final Color iconBg;
}

class _NotificationPageState extends State<NotificationPage> {
  _NotificationTab _selectedTab = _NotificationTab.today;

  Widget _topTab({required String title, required _NotificationTab tab}) {
    final selected = _selectedTab == tab;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = tab),
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: selected ? Colors.white : AppColorPalette.gold,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: Dimensions.verticalSpacingShort),
            Container(
              height: 3,
              width: double.infinity,
              color: selected ? Colors.white : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationItem(_NotificationEntry item) {
    return Container(
      padding: appPadding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(Dimensions.verticalSpacingMedium),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(10),
            child: item.icon,
          ),
          const SizedBox(width: Dimensions.verticalSpacingRegular),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: Dimensions.verticalSpacingExtraShort),
                Text(
                  item.subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColorPalette.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            item.time,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColorPalette.blueSteel,
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  Widget _motivationCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(Dimensions.verticalSpacingMedium),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -1,
            child: Opacity(
              opacity: 0.22,
              child: SizedBox(
                width: 180,
                height: 130,
                child: Image.asset(
                  AppAssets.happyFaceIcon,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Padding(
            padding: appPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.motivationGreatTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: Dimensions.verticalSpacingRegular),
                Text(
                  AppLocalizations.of(context)!.motivationGreatBody,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColorPalette.grey,
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_NotificationEntry> _allEntries(AppLocalizations l10n) {
    return [
      _NotificationEntry(
        title: l10n.notifTitleMedicationTime,
        subtitle: l10n.notifDoseAt('2:00 PM'),
        time: '2:00 PM',
        icon: Image.asset(AppAssets.medcineicon, fit: BoxFit.contain),
        tab: _NotificationTab.today,
      ),
      _NotificationEntry(
        title: l10n.notifTitleMessageFromFamily,
        subtitle: l10n.notifSubtitleFamilyPhoto,
        time: '11:00 AM',
        icon: const Icon(
          Icons.favorite_border_rounded,
          color: AppColorPalette.redDark,
        ),
        iconBg: const Color(0xFFFFF1F3),
        tab: _NotificationTab.earlier,
      ),
      _NotificationEntry(
        title: l10n.notifTitleMedicationTime,
        subtitle: l10n.notifDoseAt('6:00 PM'),
        time: '6:00 PM',
        icon: Image.asset(AppAssets.medcineicon, fit: BoxFit.contain),
        tab: _NotificationTab.reminders,
      ),
      _NotificationEntry(
        title: l10n.notifTitleMedicationTime,
        subtitle: l10n.notifDoseAt('8:00 PM'),
        time: '8:00 PM',
        icon: Image.asset(AppAssets.medcineicon, fit: BoxFit.contain),
        tab: _NotificationTab.reminders,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final visibleEntries = _allEntries(
      l10n,
    ).where((e) => e.tab == _selectedTab).toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
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
                    child: Center(
                      child: Text(
                        l10n.notifScreenTitle,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      l10n.notifClearAll,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColorPalette.redDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              Row(
                children: [
                  _topTab(
                    title: l10n.notifTabToday,
                    tab: _NotificationTab.today,
                  ),
                  _topTab(
                    title: l10n.notifTabReminders,
                    tab: _NotificationTab.reminders,
                  ),
                  _topTab(
                    title: l10n.notifTabEarlier,
                    tab: _NotificationTab.earlier,
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (var i = 0; i < visibleEntries.length; i++) ...[
                      _notificationItem(visibleEntries[i]),
                      if (i != visibleEntries.length - 1)
                        const SizedBox(
                          height: Dimensions.verticalSpacingRegular,
                        ),
                    ],
                    const SizedBox(height: Dimensions.verticalSpacingRegular),
                    _motivationCard(),
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
