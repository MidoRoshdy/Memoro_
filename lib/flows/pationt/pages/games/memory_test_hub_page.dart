import 'package:flutter/material.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../widgets/app_notifications_action.dart';
import '../../../../l10n/app_localizations.dart';
import 'memory_card_game_page.dart';
import 'quick_math_game_page.dart';
import 'sequence_memory_game_page.dart';

/// In-app memory / brain games (Flutter screens), opened from the main Games tab.
class MemoryTestHubPage extends StatelessWidget {
  const MemoryTestHubPage({super.key});

  Widget _topBar(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
        Expanded(
          child: Text(
            l10n.quickActionMemoryTest,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const AppNotificationsAction(
          diameter: AppNotificationsAction.compactDiameter,
        ),
      ],
    );
  }

  Widget _nativeTestCard({
    required BuildContext context,
    required AppLocalizations l10n,
    required IconData icon,
    required Color accent,
    required String title,
    required String subtitle,
    required VoidCallback onStart,
  }) {
    return Container(
      width: double.infinity,
      padding: appPadding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(Dimensions.cardCornerRadius + 4),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -8,
            top: 8,
            child: Opacity(
              opacity: 0.12,
              child: Icon(
                Icons.psychology_outlined,
                size: 96,
                color: AppColorPalette.blueSteel,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: accent.withValues(alpha: 0.18),
                child: Icon(icon, color: accent, size: 28),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: Dimensions.verticalSpacingExtraShort),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColorPalette.grey,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow_rounded, size: 22),
                  label: Text(l10n.gamesHubStartNow),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorPalette.blueSteel,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(containerRadius),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _topBar(context, l10n),
                const SizedBox(height: Dimensions.verticalSpacingLarge),
                _nativeTestCard(
                  context: context,
                  l10n: l10n,
                  icon: Icons.image_outlined,
                  accent: AppColorPalette.blueSteel,
                  title: l10n.gamesImageMemoryTestTitle,
                  subtitle: l10n.gamesImageMemoryTestSubtitle,
                  onStart: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const MemoryCardGamePage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: Dimensions.verticalSpacingRegular),
                _nativeTestCard(
                  context: context,
                  l10n: l10n,
                  icon: Icons.calendar_today_outlined,
                  accent: AppColorPalette.emerald,
                  title: l10n.gamesDailyRecallTestTitle,
                  subtitle: l10n.gamesDailyRecallTestSubtitle,
                  onStart: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SequenceMemoryGamePage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: Dimensions.verticalSpacingRegular),
                _nativeTestCard(
                  context: context,
                  l10n: l10n,
                  icon: Icons.calculate_outlined,
                  accent: AppColorPalette.blueBright,
                  title: l10n.gameMathTitle,
                  subtitle: l10n.gameMathSubtitle,
                  onStart: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const QuickMathGamePage(),
                      ),
                    );
                  },
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
