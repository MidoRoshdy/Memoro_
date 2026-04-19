import 'package:flutter/material.dart';

import '../../../core/localization/locale_controller.dart';
import '../../../l10n/app_localizations.dart';

Future<void> showLanguagePickerSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      final l10n = AppLocalizations.of(ctx)!;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.languageLabel,
                style: Theme.of(
                  ctx,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.englishLabel),
                onTap: () {
                  LocaleController.setEnglish();
                  Navigator.of(ctx).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.arabicLabel),
                onTap: () {
                  LocaleController.setArabic();
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
