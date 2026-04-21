import 'package:flutter/material.dart';

import '../../../../core/constants/string_assets.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../chat/doctor_chat_page.dart';
import '../../doctor_patient_link_stage.dart';
import '../tabs/doctor_placeholder_tabs.dart';
import '../tabs/doctor_profile_tab_page.dart';
import 'doctor_home_tab_page.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  static const int _profileTabIndex = 4;

  int _selectedIndex = 0;
  DoctorPatientLinkStage _linkStage = DoctorPatientLinkStage.connect;

  bool get _otherTabsEnabled => _linkStage == DoctorPatientLinkStage.linked;

  bool _canSelectNavIndex(int index) {
    if (_otherTabsEnabled) return true;
    return index == 0 || index == _profileTabIndex;
  }

  Widget _navBarIcon(String assetPath) {
    return Image.asset(assetPath, width: 24, height: 24);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = <Widget>[
      DoctorHomeTabPage(
        onSelectTab: (index) {
          if (!_canSelectNavIndex(index)) {
            return;
          }
          setState(() {
            _selectedIndex = index;
          });
        },
        onLinkStageChanged: (stage) {
          setState(() {
            _linkStage = stage;
            if (!_otherTabsEnabled && !_canSelectNavIndex(_selectedIndex)) {
              _selectedIndex = 0;
            }
          });
        },
      ),
      const DoctorChatPage(),
      const DoctorGamesTabPage(),
      const DoctorMedicineTabPage(),
      DoctorProfileTabPage(
        onBackToHome: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
      ),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: IndexedStack(index: _selectedIndex, children: tabs),
      bottomNavigationBar: Theme(
        data: _otherTabsEnabled
            ? Theme.of(context)
            : Theme.of(context).copyWith(
                splashFactory: NoSplash.splashFactory,
                highlightColor: Colors.transparent,
              ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColorPalette.blueSteel,
          unselectedItemColor: AppColorPalette.blueSteel,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (!_canSelectNavIndex(index)) {
              return;
            }
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
      ),
    );
  }
}
