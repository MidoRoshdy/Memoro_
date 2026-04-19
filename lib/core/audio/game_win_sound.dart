import 'package:audioplayers/audioplayers.dart';

/// `assets/music/mixkit-small-win-2020.wav` (see `pubspec.yaml` → `assets/music/`).
const String kGameWinSoundAsset = 'music/mixkit-small-win-2020.wav';

final AudioPlayer _gameWinPlayer = AudioPlayer(playerId: 'app_game_win_sound');

bool _gameWinPlayerReady = false;

Future<void> _ensureGameWinPlayer() async {
  if (_gameWinPlayerReady) return;
  _gameWinPlayerReady = true;
  await _gameWinPlayer.setReleaseMode(ReleaseMode.stop);
}

/// Plays the shared win sting. Overlapping calls stop the previous playback.
Future<void> playGameWinSound() async {
  await _ensureGameWinPlayer();
  await _gameWinPlayer.stop();
  await _gameWinPlayer.play(AssetSource(kGameWinSoundAsset));
}

/// Stops the win sting (e.g. wrong answer while it is still playing).
Future<void> stopGameWinSound() async {
  await _ensureGameWinPlayer();
  await _gameWinPlayer.stop();
}
