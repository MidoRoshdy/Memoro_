import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/audio/game_win_sound.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../l10n/app_localizations.dart';

class MemoryCardGamePage extends StatefulWidget {
  const MemoryCardGamePage({super.key});

  @override
  State<MemoryCardGamePage> createState() => _MemoryCardGamePageState();
}

class _MemoryCardGamePageState extends State<MemoryCardGamePage> {
  final Random _random = Random();

  final List<IconData> _baseIcons = const [
    Icons.favorite,
    Icons.star,
    Icons.pets,
    Icons.cake,
    Icons.flight,
    Icons.music_note,
    Icons.sports_esports,
    Icons.lightbulb,
    Icons.anchor,
    Icons.apple,
    Icons.beach_access,
    Icons.camera_alt,
    Icons.emoji_emotions,
    Icons.palette,
    Icons.sunny,
    Icons.rocket_launch,
  ];

  late List<IconData> _deck;
  late List<bool> _revealed;
  late List<bool> _matched;
  late List<int> _matchPulseSeed;

  int? _firstIndex;
  int? _secondIndex;
  bool _isChecking = false;
  int _moves = 0;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    final selectedIcons = [..._baseIcons]..shuffle(_random);
    final roundIcons = selectedIcons.take(8).toList();
    final cards = [...roundIcons, ...roundIcons];
    cards.shuffle(_random);
    setState(() {
      _deck = cards;
      _revealed = List<bool>.filled(cards.length, false);
      _matched = List<bool>.filled(cards.length, false);
      _matchPulseSeed = List<int>.filled(cards.length, 0);
      _firstIndex = null;
      _secondIndex = null;
      _isChecking = false;
      _moves = 0;
    });
  }

  Future<void> _onCardTap(int index) async {
    if (_isChecking || _revealed[index] || _matched[index]) {
      return;
    }

    setState(() {
      _revealed[index] = true;
      if (_firstIndex == null) {
        _firstIndex = index;
      } else {
        _secondIndex = index;
        _isChecking = true;
        _moves++;
      }
    });

    if (_firstIndex == null || _secondIndex == null) return;

    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    final first = _firstIndex!;
    final second = _secondIndex!;
    final isMatch = _deck[first] == _deck[second];

    setState(() {
      if (isMatch) {
        _matched[first] = true;
        _matched[second] = true;
        _matchPulseSeed[first]++;
        _matchPulseSeed[second]++;
      } else {
        _revealed[first] = false;
        _revealed[second] = false;
      }
      _firstIndex = null;
      _secondIndex = null;
      _isChecking = false;
    });

    if (isMatch) {
      SystemSound.play(SystemSoundType.click);
    }

    if (_matched.every((value) => value)) {
      unawaited(playGameWinSound());
      await _showWinDialog();
    }
  }

  Future<void> _showWinDialog() async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.youWinTitle),
          content: Text(l10n.memoryWinMessage(_moves)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.closeLabel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: Text(l10n.playAgainLabel),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.gameMemoryTitle),
        actions: [
          IconButton(
            tooltip: l10n.restartTooltip,
            onPressed: _resetGame,
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
              l10n.movesLabel(_moves),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            mediumVerticalSpace,
            Expanded(
              child: GridView.builder(
                itemCount: _deck.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final isFaceUp = _revealed[index] || _matched[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      _onCardTap(index);
                    },
                    child: TweenAnimationBuilder<double>(
                      key: ValueKey(
                        '${isFaceUp}_${_matchPulseSeed[index]}_$index',
                      ),
                      tween: Tween<double>(
                        begin: 1,
                        end: _matched[index] ? 1.08 : 1,
                      ),
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutBack,
                      builder: (context, scale, child) {
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        transitionBuilder: (child, animation) {
                          final rotate = Tween<double>(
                            begin: pi,
                            end: 0,
                          ).animate(animation);
                          return AnimatedBuilder(
                            animation: rotate,
                            child: child,
                            builder: (context, child) {
                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.rotationY(rotate.value),
                                child: child,
                              );
                            },
                          );
                        },
                        child: Container(
                          key: ValueKey<bool>(isFaceUp),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: isFaceUp
                                ? colorScheme.primaryContainer
                                : colorScheme.secondaryContainer,
                          ),
                          child: Center(
                            child: isFaceUp
                                ? Icon(
                                    _deck[index],
                                    size: 30,
                                    color: colorScheme.onPrimaryContainer,
                                  )
                                : Icon(
                                    Icons.question_mark_rounded,
                                    size: 30,
                                    color: colorScheme.onSecondaryContainer,
                                  ),
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
