import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/theme/app_color_palette.dart';

/// One external (browser) game opened inside an in-app WebView.
class OnlineGameLink {
  const OnlineGameLink({
    required this.icon,
    required this.color,
    required this.title,
    required this.url,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String url;
}

/// Human Benchmark memory test (online grid).
const OnlineGameLink kOnlineGameHumanBenchmark = OnlineGameLink(
  icon: Icons.psychology_outlined,
  color: AppColorPalette.blueSteel,
  title: 'Human Benchmark Memory',
  url: 'https://humanbenchmark.com/tests/memory?hl=en-AU',
);

/// Helpful Games memory (online grid).
const OnlineGameLink kOnlineGameHelpfulMemory = OnlineGameLink(
  icon: Icons.grid_view_rounded,
  color: AppColorPalette.emerald,
  title: 'Helpful Games Memory',
  url:
      'https://www.helpfulgames.com/subjects/brain-training/memory.html?hl=en-AU',
);

/// CrazyGames jigsaw search (online grid).
const OnlineGameLink kOnlineGameJigsaw = OnlineGameLink(
  icon: Icons.extension_rounded,
  color: AppColorPalette.purpleDeep,
  title: 'CrazyGames Jigsaw',
  url: 'https://www.crazygames.com/search?q=Jigsaw%20Puzzle',
);

/// Sudoku in browser — listed under Advanced games, not the online grid.
const OnlineGameLink kOnlineGameSudoku = OnlineGameLink(
  icon: Icons.calculate_outlined,
  color: AppColorPalette.blueBright,
  title: 'Sudoku',
  url: 'https://sudoku.com/?hl=en-AU',
);

/// Simon Says in browser — listed under Advanced games, not the online grid.
const OnlineGameLink kOnlineGameSimonSays = OnlineGameLink(
  icon: Icons.touch_app_outlined,
  color: AppColorPalette.gold,
  title: 'Simon Says',
  url: 'https://www.mathsisfun.com/games/simon-says.html',
);

/// Chess.com (online grid).
const OnlineGameLink kOnlineGameChess = OnlineGameLink(
  icon: Icons.emoji_events_outlined,
  color: AppColorPalette.redBright,
  title: 'Chess',
  url: 'https://www.chess.com/',
);

/// Online games shown as tiles on the main Games tab (see advanced for Sudoku / Simon).
const List<OnlineGameLink> kDefaultOnlineGameLinks = [
  kOnlineGameHumanBenchmark,
  kOnlineGameHelpfulMemory,
  kOnlineGameJigsaw,
  kOnlineGameChess,
];

/// Full-screen WebView for [OnlineGameLink].
class OnlineGameWebViewPage extends StatefulWidget {
  const OnlineGameWebViewPage({super.key, required this.game});

  final OnlineGameLink game;

  @override
  State<OnlineGameWebViewPage> createState() => _OnlineGameWebViewPageState();
}

class _OnlineGameWebViewPageState extends State<OnlineGameWebViewPage> {
  WebViewController? _controller;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (progress) {
              if (!mounted) return;
              setState(() {
                _progress = progress;
              });
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.game.url));
      setState(() => _controller = controller);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      appBar: AppBar(title: Text(widget.game.title)),
      body: controller == null
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : Column(
              children: [
                if (_progress < 100)
                  LinearProgressIndicator(value: _progress / 100, minHeight: 2),
                Expanded(child: WebViewWidget(controller: controller)),
              ],
            ),
    );
  }
}
