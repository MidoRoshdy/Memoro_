import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/audio/game_win_sound.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../l10n/app_localizations.dart';

class QuickMathGamePage extends StatefulWidget {
  const QuickMathGamePage({super.key});

  @override
  State<QuickMathGamePage> createState() => _QuickMathGamePageState();
}

class _QuickMathGamePageState extends State<QuickMathGamePage> {
  final Random _random = Random();
  final TextEditingController _answerController = TextEditingController();

  Timer? _timer;
  int _secondsLeft = 45;
  int _score = 0;
  int _bestScore = 0;
  bool _isPlaying = true;

  late int _a;
  late int _b;
  late String _op;
  late int _correctAnswer;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft == 0) {
        timer.cancel();
        setState(() {
          _isPlaying = false;
          if (_score > _bestScore) {
            _bestScore = _score;
          }
        });
        if (_score > 0) {
          unawaited(playGameWinSound());
        } else {
          SystemSound.play(SystemSoundType.alert);
        }
        _showGameOverDialog();
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  void _generateQuestion() {
    final operations = ['+', '-', '*'];
    _op = operations[_random.nextInt(operations.length)];

    switch (_op) {
      case '+':
        _a = _random.nextInt(40) + 1;
        _b = _random.nextInt(40) + 1;
        _correctAnswer = _a + _b;
        break;
      case '-':
        _a = _random.nextInt(60) + 20;
        _b = _random.nextInt(20) + 1;
        _correctAnswer = _a - _b;
        break;
      default:
        _a = _random.nextInt(12) + 1;
        _b = _random.nextInt(12) + 1;
        _correctAnswer = _a * _b;
    }
  }

  void _submitAnswer() {
    if (!_isPlaying) return;
    final value = int.tryParse(_answerController.text.trim());
    if (value == null) return;

    if (value == _correctAnswer) {
      SystemSound.play(SystemSoundType.click);
      setState(() {
        _score++;
      });
    } else {
      SystemSound.play(SystemSoundType.alert);
    }

    _answerController.clear();
    setState(() {
      _generateQuestion();
    });
  }

  void _restartGame() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = 45;
      _score = 0;
      _isPlaying = true;
      _generateQuestion();
    });
    _answerController.clear();
    _startTimer();
  }

  Future<void> _showGameOverDialog() async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.mathTimeUpTitle),
        content: Text(l10n.mathScoreBest(_score, _bestScore)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.closeLabel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restartGame();
            },
            child: Text(l10n.playAgainLabel),
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
        title: Text(l10n.gameMathTitle),
        actions: [
          IconButton(
            tooltip: l10n.restartTooltip,
            onPressed: _restartGame,
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
              l10n.mathHeader(_secondsLeft, _score, _bestScore),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            veryLongVerticalSpace,
            Center(
              child: Text(
                '$_a $_op $_b = ?',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _answerController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submitAnswer(),
              decoration: InputDecoration(
                labelText: l10n.mathYourAnswer,
                border: const OutlineInputBorder(),
              ),
            ),
            mediumVerticalSpace,
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitAnswer,
                child: Text(l10n.submitLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
