import 'package:flutter/material.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_color_palette.dart';
import '../../../l10n/app_localizations.dart';

/// Shared notification entry: white circle, bell icon, red badge → [AppRouter.notifications].
///
/// Use [diameter] = [defaultDiameter] on the home header; use [compactDiameter] on compact app bars.
class AppNotificationsAction extends StatelessWidget {
  const AppNotificationsAction({super.key, this.diameter = defaultDiameter});

  /// Matches home header: `verticalSpacingXL + horizontalSpacingShort`.
  static const double defaultDiameter =
      Dimensions.verticalSpacingXL + Dimensions.horizontalSpacingShort;

  /// Smaller circle for secondary screens (chat, games, medicine, etc.).
  static const double compactDiameter = 40;

  final double diameter;

  @override
  Widget build(BuildContext context) {
    final tooltip =
        AppLocalizations.of(context)?.notifScreenTitle ?? 'Notifications';
    final iconSize = (diameter * 0.52).clamp(20.0, 28.0);
    final badgeSize = (diameter * 0.18).clamp(6.0, 8.0);
    // Anchor to the centered icon box so the dot sits on the bell (not the
    // square’s corner outside the circular white fill). Same math in RTL
    // because the glyph does not mirror.
    final center = diameter / 2;
    final halfIcon = iconSize / 2;
    final badgeLeft = center + halfIcon * 0.38 - badgeSize / 2;
    final badgeTop = center - halfIcon * 0.52 - badgeSize / 2;

    return Tooltip(
      message: tooltip,
      child: ClipOval(
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: () =>
                Navigator.of(context).pushNamed(AppRouter.notifications),
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: diameter,
              height: diameter,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    color: AppColorPalette.blueSteel,
                    size: iconSize,
                  ),
                  Positioned(
                    left: badgeLeft,
                    top: badgeTop,
                    child: Container(
                      width: badgeSize,
                      height: badgeSize,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
