import 'package:flutter/material.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../games/games_page.dart';
import 'patient_activity_page.dart';

class ActivityHubPage extends StatelessWidget {
  const ActivityHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: appPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.tabActivity,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: Dimensions.verticalSpacingRegular),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.checklist_rounded),
                    label: Text(l10n.patientActivitySectionTitle),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColorPalette.blueSteel,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.horizontalSpacingRegular),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => const GamesPage()),
                      );
                    },
                    icon: const Icon(Icons.sports_esports_outlined),
                    label: Text(l10n.tabGames),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.verticalSpacingRegular),
            const Expanded(child: PatientActivityPage()),
          ],
        ),
      ),
    );
  }
}
