import 'package:flutter/material.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/models/game_link_item.dart';
import '../../../../core/services/games_service.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';

class DoctorAssignedGamesPage extends StatelessWidget {
  const DoctorAssignedGamesPage({
    super.key,
    required this.gamesDocId,
    required this.doctorUid,
    required this.patientUid,
  });

  final String gamesDocId;
  final String doctorUid;
  final String patientUid;

  Future<void> _toggleGame(
    BuildContext context, {
    required String key,
    required bool visible,
  }) {
    switch (key) {
      case 'showMemoryHub':
        return GamesService.updateConfig(
          gamesDocId: gamesDocId,
          doctorUid: doctorUid,
          patientUid: patientUid,
          showMemoryHub: visible,
        );
      case 'showImageMemoryTest':
        return GamesService.updateConfig(
          gamesDocId: gamesDocId,
          doctorUid: doctorUid,
          patientUid: patientUid,
          showImageMemoryTest: visible,
        );
      case 'showDailyRecallTest':
        return GamesService.updateConfig(
          gamesDocId: gamesDocId,
          doctorUid: doctorUid,
          patientUid: patientUid,
          showDailyRecallTest: visible,
        );
      case 'showQuickMath':
        return GamesService.updateConfig(
          gamesDocId: gamesDocId,
          doctorUid: doctorUid,
          patientUid: patientUid,
          showQuickMath: visible,
        );
      case 'showHumanBenchmark':
        return GamesService.updateConfig(
          gamesDocId: gamesDocId,
          doctorUid: doctorUid,
          patientUid: patientUid,
          showHumanBenchmark: visible,
        );
      case 'showHelpfulMemory':
        return GamesService.updateConfig(
          gamesDocId: gamesDocId,
          doctorUid: doctorUid,
          patientUid: patientUid,
          showHelpfulMemory: visible,
        );
      case 'showJigsaw':
        return GamesService.updateConfig(
          gamesDocId: gamesDocId,
          doctorUid: doctorUid,
          patientUid: patientUid,
          showJigsaw: visible,
        );
      case 'showChess':
        return GamesService.updateConfig(
          gamesDocId: gamesDocId,
          doctorUid: doctorUid,
          patientUid: patientUid,
          showChess: visible,
        );
      case 'showSudoku':
        return GamesService.updateConfig(
          gamesDocId: gamesDocId,
          doctorUid: doctorUid,
          patientUid: patientUid,
          showSudoku: visible,
        );
      case 'showSimonSays':
        return GamesService.updateConfig(
          gamesDocId: gamesDocId,
          doctorUid: doctorUid,
          patientUid: patientUid,
          showSimonSays: visible,
        );
      default:
        return Future<void>.value();
    }
  }

  Widget _gameTile(
    BuildContext context, {
    required String title,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.verticalSpacingShort),
      padding: const EdgeInsets.all(Dimensions.verticalSpacingRegular),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          FilledButton(
            onPressed: onToggle,
            style: FilledButton.styleFrom(
              backgroundColor: isVisible
                  ? AppColorPalette.redBright
                  : AppColorPalette.blueSteel,
              foregroundColor: Colors.white,
              minimumSize: const Size(98, 36),
            ),
            child: Text(
              isVisible ? l10n.doctorGamesHide : l10n.doctorGamesShow,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.doctorActivityAssignedGames),
      ),
      body: SafeArea(
        child: Padding(
          padding: appPadding,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StreamBuilder<GamesConfig>(
                  stream: GamesService.watchConfig(gamesDocId),
                  builder: (context, snap) {
                    final config = snap.data ??
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
                    return Column(
                      children: [
                        _gameTile(
                          context,
                          title: l10n.gamesFeaturedHeroTitle,
                          isVisible: config.showMemoryHub,
                          onToggle: () => _toggleGame(
                            context,
                            key: 'showMemoryHub',
                            visible: !config.showMemoryHub,
                          ),
                        ),
                        _gameTile(
                          context,
                          title: l10n.gamesImageMemoryTestTitle,
                          isVisible: config.showImageMemoryTest,
                          onToggle: () => _toggleGame(
                            context,
                            key: 'showImageMemoryTest',
                            visible: !config.showImageMemoryTest,
                          ),
                        ),
                        _gameTile(
                          context,
                          title: l10n.gamesDailyRecallTestTitle,
                          isVisible: config.showDailyRecallTest,
                          onToggle: () => _toggleGame(
                            context,
                            key: 'showDailyRecallTest',
                            visible: !config.showDailyRecallTest,
                          ),
                        ),
                        _gameTile(
                          context,
                          title: l10n.gameMathTitle,
                          isVisible: config.showQuickMath,
                          onToggle: () => _toggleGame(
                            context,
                            key: 'showQuickMath',
                            visible: !config.showQuickMath,
                          ),
                        ),
                        _gameTile(
                          context,
                          title: 'Human Benchmark Memory',
                          isVisible: config.showHumanBenchmark,
                          onToggle: () => _toggleGame(
                            context,
                            key: 'showHumanBenchmark',
                            visible: !config.showHumanBenchmark,
                          ),
                        ),
                        _gameTile(
                          context,
                          title: 'Helpful Games Memory',
                          isVisible: config.showHelpfulMemory,
                          onToggle: () => _toggleGame(
                            context,
                            key: 'showHelpfulMemory',
                            visible: !config.showHelpfulMemory,
                          ),
                        ),
                        _gameTile(
                          context,
                          title: 'CrazyGames Jigsaw',
                          isVisible: config.showJigsaw,
                          onToggle: () => _toggleGame(
                            context,
                            key: 'showJigsaw',
                            visible: !config.showJigsaw,
                          ),
                        ),
                        _gameTile(
                          context,
                          title: l10n.gamesChessTitle,
                          isVisible: config.showChess,
                          onToggle: () => _toggleGame(
                            context,
                            key: 'showChess',
                            visible: !config.showChess,
                          ),
                        ),
                        _gameTile(
                          context,
                          title: l10n.gamesSudokuTitle,
                          isVisible: config.showSudoku,
                          onToggle: () => _toggleGame(
                            context,
                            key: 'showSudoku',
                            visible: !config.showSudoku,
                          ),
                        ),
                        _gameTile(
                          context,
                          title: l10n.gamesSimonSaysTitle,
                          isVisible: config.showSimonSays,
                          onToggle: () => _toggleGame(
                            context,
                            key: 'showSimonSays',
                            visible: !config.showSimonSays,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: Dimensions.verticalSpacingRegular),
                StreamBuilder<List<GameLinkItem>>(
                  stream: GamesService.watchLinks(gamesDocId),
                  builder: (context, snap) {
                    final links = snap.data ?? const <GameLinkItem>[];
                    if (links.isEmpty) return const SizedBox.shrink();
                    return Column(
                      children: [
                        for (final link in links)
                          _gameTile(
                            context,
                            title: link.title,
                            isVisible: link.isVisible,
                            onToggle: () => GamesService.setLinkVisibility(
                              gamesDocId: gamesDocId,
                              linkId: link.id,
                              isVisible: !link.isVisible,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
