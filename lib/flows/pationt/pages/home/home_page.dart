import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../core/constants/string_assets.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../games/games_page.dart';
import '../chat/chat_page.dart';
import '../medicine/medicine_page.dart';
import '../profile/profile_page.dart';
import 'home_tab_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  Widget _navBarIcon(String assetPath) {
    return Image.asset(assetPath, width: 24, height: 24);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthService.ensurePatientDocument();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = [
      HomeTabPage(
        onSelectTab: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      const ChatPage(),
      const GamesPage(),
      const MedicinePage(),
      const ProfilePage(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: tabs),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        shape: const CircleBorder(),
        mini: false,
        onPressed: () {
          Navigator.of(context).pushNamed(AppRouter.sos);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppAssets.sosIcon, width: 23, height: 23),
            const SizedBox(height: 2),
            Text(
              l10n.sosFabLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColorPalette.blueSteel,
        unselectedItemColor: AppColorPalette.blueSteel,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: _navBarIcon(AppAssets.navHome),
            activeIcon: _navBarIcon(AppAssets.navHomeActive),
            label: l10n.tabHome,
          ),
          BottomNavigationBarItem(
            icon: _navBarIcon(AppAssets.navChat),
            activeIcon: _navBarIcon(AppAssets.navChatActive),
            label: l10n.tabChat,
          ),
          BottomNavigationBarItem(
            icon: _navBarIcon(AppAssets.navGame),
            activeIcon: _navBarIcon(AppAssets.navGameActive),
            label: l10n.tabGames,
          ),
          BottomNavigationBarItem(
            icon: _navBarIcon(AppAssets.navMedicine),
            activeIcon: _navBarIcon(AppAssets.navMedicineActive),
            label: l10n.tabMedicine,
          ),
          BottomNavigationBarItem(
            icon: _navBarIcon(AppAssets.navProfile),
            activeIcon: _navBarIcon(AppAssets.navProfileActive),
            label: l10n.tabProfile,
          ),
        ],
      ),
    );
  }
}
