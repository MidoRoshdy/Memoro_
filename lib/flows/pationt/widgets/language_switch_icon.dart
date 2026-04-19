import 'package:flutter/material.dart';

import '../../../core/localization/locale_controller.dart';
import '../../../l10n/app_localizations.dart';

class LanguageSwitchIcon extends StatelessWidget {
  const LanguageSwitchIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: LocaleController.locale,
      builder: (context, locale, _) {
        final l10n = AppLocalizations.of(context)!;
        final isArabic = locale?.languageCode == 'ar';
        return PopupMenuButton<String>(
          tooltip: l10n.changeLanguageTooltip,
          icon: const Icon(Icons.language),
          onSelected: (value) {
            if (value == 'ar') {
              LocaleController.setArabic();
            } else if (value == 'en') {
              LocaleController.setEnglish();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'en',
              child: Row(
                children: [
                  Icon(
                    isArabic ? Icons.circle_outlined : Icons.check_circle,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(l10n.englishLabel),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'ar',
              child: Row(
                children: [
                  Icon(
                    isArabic ? Icons.check_circle : Icons.circle_outlined,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(l10n.arabicLabel),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
