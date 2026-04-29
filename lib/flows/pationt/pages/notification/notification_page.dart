import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/string_assets.dart';
import '../../../../core/models/app_notification.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/services/notification_route_resolver.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

enum _NotificationTab { today, reminders, earlier }

class _NotificationPageState extends ConsumerState<NotificationPage> {
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

  Widget _notificationItem(AppNotification item) {
    final time = item.createdAt != null
        ? MaterialLocalizations.of(
            context,
          ).formatTimeOfDay(TimeOfDay.fromDateTime(item.createdAt!.toLocal()))
        : '--';
    final icon = _iconForType(item.type);
    final iconBg = _iconBgForType(item.type);

    return InkWell(
      onTap: () async {
        final actions = ref.read(notificationActionsProvider);
        await actions.markAsOpened(item.id);
        await NotificationRouteResolver.openFromPayload(
          _payloadFromNotification(item),
        );
      },
      borderRadius: BorderRadius.circular(Dimensions.verticalSpacingMedium),
      child: Container(
        padding: appPadding,
        decoration: BoxDecoration(
          color: item.isRead
              ? Colors.white.withValues(alpha: 0.87)
              : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(Dimensions.verticalSpacingMedium),
          border: item.isRead
              ? null
              : Border.all(
                  color: AppColorPalette.blueSteel.withValues(alpha: 0.3),
                ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(10),
              child: icon,
            ),
            const SizedBox(width: Dimensions.verticalSpacingRegular),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: Dimensions.verticalSpacingExtraShort),
                  Text(
                    item.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColorPalette.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Dimensions.horizontalSpacingShort),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColorPalette.blueSteel,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (!item.isRead)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
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

  List<AppNotification> _entriesForTab(List<AppNotification> source) {
    final now = DateTime.now();
    return source.where((e) {
      if (_selectedTab == _NotificationTab.reminders) {
        return e.isReminder;
      }
      if (_selectedTab == _NotificationTab.today) {
        final created = e.createdAt?.toLocal();
        if (created == null) return false;
        return created.year == now.year &&
            created.month == now.month &&
            created.day == now.day &&
            !e.isReminder;
      }
      return !e.isReminder;
    }).toList();
  }

  Widget _iconForType(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.medicationReminder:
      case AppNotificationType.medicationAdded:
      case AppNotificationType.medicationTaken:
        return Image.asset(AppAssets.medcineicon, fit: BoxFit.contain);
      case AppNotificationType.chatMessage:
        return const Icon(
          Icons.chat_bubble_outline_rounded,
          color: AppColorPalette.blueSteel,
        );
      case AppNotificationType.helpRequest:
      case AppNotificationType.helpRequestResolved:
        return const Icon(
          Icons.warning_amber_rounded,
          color: AppColorPalette.redDark,
        );
      case AppNotificationType.activityAssigned:
      case AppNotificationType.activityDone:
      case AppNotificationType.activityReminder:
        return const Icon(
          Icons.checklist_rounded,
          color: AppColorPalette.blueSteel,
        );
      case AppNotificationType.general:
        return const Icon(
          Icons.notifications_active_outlined,
          color: AppColorPalette.blueSteel,
        );
    }
  }

  Color _iconBgForType(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.helpRequest:
        return const Color(0xFFFFF1F3);
      case AppNotificationType.helpRequestResolved:
        return const Color(0xFFE7F7EE);
      case AppNotificationType.medicationReminder:
      case AppNotificationType.medicationAdded:
      case AppNotificationType.medicationTaken:
        return const Color(0xFFE6F0FF);
      default:
        return const Color(0xFFEAF7FF);
    }
  }

  Map<String, dynamic> _payloadFromNotification(AppNotification item) {
    return <String, dynamic>{
      'type': _typeValue(item.type),
      'pairId': item.pairId,
      'entityId': item.entityId,
      'data': item.data,
    };
  }

  String _typeValue(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.activityAssigned:
        return 'activity_assigned';
      case AppNotificationType.activityDone:
        return 'activity_done';
      case AppNotificationType.chatMessage:
        return 'chat_message';
      case AppNotificationType.helpRequest:
        return 'help_request';
      case AppNotificationType.helpRequestResolved:
        return 'help_request_resolved';
      case AppNotificationType.medicationAdded:
        return 'medication_added';
      case AppNotificationType.medicationTaken:
        return 'medication_taken';
      case AppNotificationType.medicationReminder:
        return 'medication_reminder';
      case AppNotificationType.activityReminder:
        return 'activity_reminder';
      case AppNotificationType.general:
        return 'general';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notifications = ref.watch(notificationsInboxProvider);
    final actions = ref.read(notificationActionsProvider);

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
                    onPressed: () async => actions.clearAll(),
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
                child: notifications.when(
                  data: (items) {
                    final visibleEntries = _entriesForTab(items);
                    if (visibleEntries.isEmpty) {
                      return ListView(
                        padding: EdgeInsets.zero,
                        children: [_motivationCard()],
                      );
                    }
                    return ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        for (var i = 0; i < visibleEntries.length; i++) ...[
                          _notificationItem(visibleEntries[i]),
                          if (i != visibleEntries.length - 1)
                            const SizedBox(
                              height: Dimensions.verticalSpacingRegular,
                            ),
                        ],
                        const SizedBox(
                          height: Dimensions.verticalSpacingRegular,
                        ),
                        _motivationCard(),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => Center(
                    child: Text(
                      'Failed to load notifications',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
