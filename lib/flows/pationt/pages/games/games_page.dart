import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/models/game_link_item.dart';
import '../../../../core/services/doctor_link_request_service.dart';
import '../../../../core/services/games_service.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../widgets/app_notifications_action.dart';
import '../../../../l10n/app_localizations.dart';
import 'memory_test_hub_page.dart';
import 'online_game_webview_page.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  List<OnlineGameLink> _buildOnlineLinks(
    List<GameLinkItem> customLinks,
    GamesConfig config,
  ) {
    final builtIn = <OnlineGameLink>[
      if (config.showHumanBenchmark) kOnlineGameHumanBenchmark,
      if (config.showHelpfulMemory) kOnlineGameHelpfulMemory,
      if (config.showJigsaw) kOnlineGameJigsaw,
      if (config.showChess) kOnlineGameChess,
    ];
    final visibleCustom = customLinks
        .where((e) => e.isVisible && e.title.isNotEmpty && e.url.isNotEmpty)
        .map(
          (e) => OnlineGameLink(
            icon: Icons.public_rounded,
            color: AppColorPalette.blueSteel,
            title: e.title,
            url: e.url,
          ),
        )
        .toList();
    return <OnlineGameLink>[...builtIn, ...visibleCustom];
  }

  void _openMemoryHub(BuildContext context, GamesConfig config) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MemoryTestHubPage(
          showImageMemoryTest: config.showImageMemoryTest,
          showDailyRecallTest: config.showDailyRecallTest,
          showQuickMath: config.showQuickMath,
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.tabGames,
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

  Widget _featuredCard(
    BuildContext context,
    AppLocalizations l10n,
    GamesConfig config,
  ) {
    return Container(
      width: double.infinity,
      padding: appPadding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(Dimensions.cardCornerRadius + 6),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -6,
            bottom: -6,
            child: Opacity(
              opacity: 0.08,
              child: Row(
                children: [
                  Icon(
                    Icons.settings_outlined,
                    size: 72,
                    color: AppColorPalette.grey,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.psychology_outlined,
                    size: 72,
                    color: AppColorPalette.grey,
                  ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.gamesNewChallengeLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColorPalette.blueSteel,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingExtraShort),
              Text(
                l10n.gamesFeaturedHeroTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingShort),
              Text(
                l10n.gamesFeaturedHeroSubtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColorPalette.grey,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _openMemoryHub(context, config),
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

  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(
        top: Dimensions.verticalSpacingMedium,
        bottom: Dimensions.verticalSpacingShort,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _miniGameTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.cardCornerRadius + 2),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.horizontalSpacingMedium),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(Dimensions.cardCornerRadius + 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 52,
              alignment: Alignment.center,
              child: Icon(icon, size: 34, color: iconColor),
            ),
            const SizedBox(height: Dimensions.verticalSpacingShort),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            Container(
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(containerRadius),
              ),
              child: Text(
                actionLabel,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColorPalette.blueSteel,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _advancedRow({
    required BuildContext context,
    required AppLocalizations l10n,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color playColor,
    required VoidCallback onPlay,
    Color? iconAccentColor,
  }) {
    final accent = iconAccentColor ?? AppColorPalette.blueSteel;
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.verticalSpacingRegular),
      padding: appPadding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(Dimensions.cardCornerRadius + 2),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: accent.withValues(alpha: 0.12),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: Dimensions.horizontalSpacingRegular),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: Dimensions.verticalSpacingExtraShort),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColorPalette.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: Dimensions.horizontalSpacingShort),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: onPlay,
              style: ElevatedButton.styleFrom(
                backgroundColor: playColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(containerRadius),
                ),
              ),
              child: Text(l10n.gamesPlay),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final patientUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (patientUid.isEmpty) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Padding(
        padding: appPadding,
        child: StreamBuilder<QueryDocumentSnapshot<Map<String, dynamic>>?>(
          stream: DoctorLinkRequestService.watchLatestAcceptedForPatient(
            patientUid,
          ),
          builder: (context, linkSnap) {
            final request = linkSnap.data;
            final data = request?.data();
            final doctorUid = (data?['doctorId'] as String?)?.trim() ?? '';
            if (doctorUid.isEmpty) {
              return Center(
                child: Text(
                  l10n.doctorMedConnectFirst,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }
            final gamesDocId = doctorUid.isNotEmpty
                ? GamesService.buildGamesDocId(doctorUid, patientUid)
                : '';

            final configStream = gamesDocId.isEmpty
                ? const Stream<GamesConfig>.empty()
                : GamesService.watchConfig(gamesDocId);
            final linksStream = gamesDocId.isEmpty
                ? const Stream<List<GameLinkItem>>.empty()
                : GamesService.watchLinks(gamesDocId);

            return StreamBuilder<GamesConfig>(
              stream: configStream,
              builder: (context, configSnap) {
                final config =
                    configSnap.data ??
                    const GamesConfig(
                      showMemoryHub: true,
                      showImageMemoryTest: true,
                      showDailyRecallTest: true,
                      showQuickMath: true,
                      showOnlineSection: true,
                      showHumanBenchmark: true,
                      showHelpfulMemory: true,
                      showJigsaw: true,
                      showChess: true,
                      showSudoku: true,
                      showSimonSays: true,
                    );
                return StreamBuilder<List<GameLinkItem>>(
                  stream: linksStream,
                  builder: (context, linksSnap) {
                    final onlineLinks = _buildOnlineLinks(
                      linksSnap.data ?? const <GameLinkItem>[],
                      config,
                    );
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _topBar(context, l10n),
                          const SizedBox(
                            height: Dimensions.verticalSpacingRegular,
                          ),
                          if (config.showMemoryHub)
                            _featuredCard(context, l10n, config),
                          if (config.showOnlineSection &&
                              onlineLinks.isNotEmpty) ...[
                            _sectionTitle(
                              context,
                              l10n.gamesOnlineSectionTitle,
                            ),
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing:
                                  Dimensions.verticalSpacingRegular,
                              crossAxisSpacing:
                                  Dimensions.verticalSpacingRegular,
                              // Make cards taller to avoid small RenderFlex overflow.
                              childAspectRatio: 0.86,
                              children: [
                                for (final link in onlineLinks)
                                  _miniGameTile(
                                    context: context,
                                    icon: link.icon,
                                    iconColor: link.color,
                                    title: link.title,
                                    actionLabel: l10n.gamesHubStartNow,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) =>
                                              OnlineGameWebViewPage(game: link),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ],
                          if (config.showSudoku || config.showSimonSays) ...[
                            _sectionTitle(
                              context,
                              l10n.gamesAdvancedGamesSectionTitle,
                            ),
                            if (config.showSudoku)
                              _advancedRow(
                                context: context,
                                l10n: l10n,
                                icon: kOnlineGameSudoku.icon,
                                title: l10n.gamesSudokuTitle,
                                subtitle: l10n.gamesSudokuSubtitle,
                                playColor: kOnlineGameSudoku.color,
                                iconAccentColor: kOnlineGameSudoku.color,
                                onPlay: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          const OnlineGameWebViewPage(
                                            game: kOnlineGameSudoku,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            if (config.showSimonSays)
                              _advancedRow(
                                context: context,
                                l10n: l10n,
                                icon: kOnlineGameSimonSays.icon,
                                title: l10n.gamesSimonSaysTitle,
                                subtitle: l10n.gamesSimonSaysSubtitle,
                                playColor: kOnlineGameSimonSays.color,
                                iconAccentColor: kOnlineGameSimonSays.color,
                                onPlay: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          const OnlineGameWebViewPage(
                                            game: kOnlineGameSimonSays,
                                          ),
                                    ),
                                  );
                                },
                              ),
                          ],
                          const SizedBox(height: bottomNavigationBarPadding),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
