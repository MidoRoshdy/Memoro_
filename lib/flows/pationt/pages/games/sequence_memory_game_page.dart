import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/audio/game_win_sound.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../l10n/app_localizations.dart';

/// Guitar clips in [assets/music] — one per Simon tile.
const List<String> kSequenceMemoryTileSoundAssets = [
  'music/mixkit-bass-guitar-single-note-2331.wav',
  'music/mixkit-cool-guitar-riff-2321.wav',
  'music/mixkit-guitar-stroke-up-slow-2338.wav',
  'music/mixkit-happy-guitar-chords-2319.wav',
];

const Duration kRecallTestTileSoundHold = Duration(seconds: 1);

class SequenceMemoryGamePage extends StatefulWidget {
  const SequenceMemoryGamePage({super.key});

  @override
  State<SequenceMemoryGamePage> createState() => _SequenceMemoryGamePageState();
}

class _SequenceMemoryGamePageState extends State<SequenceMemoryGamePage> {
  final Random _random = Random();
  final List<AudioPlayer> _tilePlayers = List.generate(
    4,
    (i) => AudioPlayer(playerId: 'sequence_recall_tile_$i'),
  );

  final List<Color> _tileColors = const [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.green,
    Colors.orange,
  ];

  final List<int> _sequence = <int>[];
  int _playerIndex = 0;
  int _activeTile = -1;
  int _bestLevel = 0;
  bool _isShowingSequence = false;
  bool _canTap = false;
  bool _tileFeedbackLock = false;

  int get _level => _sequence.length;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < _tilePlayers.length; i++) {
      unawaited(_tilePlayers[i].setReleaseMode(ReleaseMode.stop));
    }
    _startNewGame();
  }

  @override
  void dispose() {
    for (final p in _tilePlayers) {
      p.dispose();
    }
    super.dispose();
  }

  Future<void> _playTileSound(int index) async {
    if (index < 0 || index >= _tilePlayers.length) return;
    final player = _tilePlayers[index];
    await player.stop();
    await player.play(AssetSource(kSequenceMemoryTileSoundAssets[index]));
  }

  void _startNewGame() {
    setState(() {
      _sequence.clear();
      _playerIndex = 0;
      _activeTile = -1;
      _isShowingSequence = false;
      _canTap = false;
      _tileFeedbackLock = false;
    });
    _nextRound();
  }

  Future<void> _nextRound() async {
    await stopGameWinSound();

    setState(() {
      _sequence.add(_random.nextInt(4));
      _playerIndex = 0;
      _isShowingSequence = true;
      _canTap = false;
    });

    await Future<void>.delayed(const Duration(milliseconds: 350));
    for (final index in _sequence) {
      if (!mounted) return;
      setState(() {
        _activeTile = index;
      });
      unawaited(_playTileSound(index));
      await Future<void>.delayed(kRecallTestTileSoundHold);
      if (!mounted) return;
      await _tilePlayers[index].stop();
      setState(() {
        _activeTile = -1;
      });
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }

    if (!mounted) return;
    setState(() {
      _isShowingSequence = false;
      _canTap = true;
    });
  }

  Future<void> _onTileTap(int index) async {
    if (!_canTap || _isShowingSequence || _tileFeedbackLock) return;

    final wrong = _sequence[_playerIndex] != index;

    setState(() {
      _tileFeedbackLock = true;
      _activeTile = index;
    });

    unawaited(_playTileSound(index));
    await Future<void>.delayed(kRecallTestTileSoundHold);
    if (!mounted) return;
    await _tilePlayers[index].stop();

    setState(() {
      _activeTile = -1;
      _tileFeedbackLock = false;
    });

    if (wrong) {
      for (final p in _tilePlayers) {
        unawaited(p.stop());
      }
      unawaited(stopGameWinSound());
      SystemSound.play(SystemSoundType.alert);
      await _showGameOverDialog();
      return;
    }

    _playerIndex++;

    if (_playerIndex == _sequence.length) {
      final currentLevel = _sequence.length;
      if (currentLevel > _bestLevel) {
        _bestLevel = currentLevel;
      }

      setState(() {
        _canTap = false;
      });
      unawaited(playGameWinSound());
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      await _nextRound();
    }
  }

  Future<void> _showGameOverDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final reachedLevel = _level;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.sequenceGameOverTitle),
        content: Text(l10n.sequenceGameOverMessage(reachedLevel)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.closeLabel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startNewGame();
            },
            child: Text(l10n.playAgainLabel),
          ),
        ],
      ),
    );
    if (!mounted) return;
    _startNewGame();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.gameSequenceTitle),
        actions: [
          IconButton(
            tooltip: l10n.restartTooltip,
            onPressed: _startNewGame,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(appHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.sequenceLevelBest(_level, _bestLevel),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            shortVerticalSpace,
            Text(
              _isShowingSequence
                  ? l10n.sequenceWatch
                  : (_canTap ? l10n.sequenceRepeat : l10n.sequenceReady),
            ),
            const SizedBox(height: Dimensions.horizontalSpacingMedium),
            Expanded(
              child: GridView.builder(
                itemCount: 4,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  final isActive = _activeTile == index;
                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _onTileTap(index),
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 150),
                      scale: isActive ? 0.95 : 1,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        decoration: BoxDecoration(
                          color: _tileColors[index].withValues(
                            alpha: isActive ? 1 : 0.72,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.touch_app_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
