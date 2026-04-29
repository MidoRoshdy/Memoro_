import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_color_palette.dart';
import '../../../l10n/app_localizations.dart';

/// Shared notification entry: white circle, bell icon, red badge → [AppRouter.notifications].
///
/// Use [diameter] = [defaultDiameter] on the home header; use [compactDiameter] on compact app bars.
class AppNotificationsAction extends ConsumerWidget {
  const AppNotificationsAction({super.key, this.diameter = defaultDiameter});

  /// Matches home header: `verticalSpacingXL + horizontalSpacingShort`.
  static const double defaultDiameter =
      Dimensions.verticalSpacingXL + Dimensions.horizontalSpacingShort;

  /// Smaller circle for secondary screens (chat, games, medicine, etc.).
  static const double compactDiameter = 40;

  final double diameter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationCountProvider).asData?.value ?? 0;
    final tooltip =
        AppLocalizations.of(context)?.notifScreenTitle ?? 'Notifications';
    final iconSize = (diameter * 0.52).clamp(20.0, 28.0);
    final badgeDiameter = (diameter * 0.42).clamp(16.0, 22.0);
    final badgeFontSize = (badgeDiameter * 0.55).clamp(9.0, 12.0);

    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: Colors.white,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRouter.notifications),
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: diameter,
                  height: diameter,
                  child: Center(
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: AppColorPalette.blueSteel,
                      size: iconSize,
                    ),
                  ),
                ),
              ),
            ),
            if (unread > 0)
              Positioned(
                right: -badgeDiameter * 0.35,
                top: -badgeDiameter * 0.35,
                child: IgnorePointer(
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: badgeDiameter,
                      minHeight: badgeDiameter,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: badgeDiameter * 0.25,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: unread > 9 ? BoxShape.rectangle : BoxShape.circle,
                      borderRadius: unread > 9
                          ? BorderRadius.circular(badgeDiameter)
                          : null,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      unread > 99 ? '99+' : '$unread',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: badgeFontSize,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
