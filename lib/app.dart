import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'core/localization/locale_controller.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_color_palette.dart';
import 'core/theme/app_theme.dart';

class MemoroApp extends StatefulWidget {
  const MemoroApp({super.key});

  @override
  State<MemoroApp> createState() => _MemoroAppState();
}

class _MemoroAppState extends State<MemoroApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: LocaleController.locale,
      builder: (context, locale, _) {
        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
          debugShowCheckedModeBanner: false,
          navigatorKey: AppRouter.navigatorKey,
          theme: AppTheme.lightTheme,
          builder: (context, child) {
            return Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColorPalette.blueSteel, Colors.white],
                    ),
                  ),
                  child: const SizedBox.expand(),
                ),
                if (child != null) child,
              ],
            );
          },
          locale: locale,
          initialRoute: AppRouter.splash,
          routes: AppRouter.routes,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
}
