import 'package:flutter/material.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../widgets/app_notifications_action.dart';
import '../../../../l10n/app_localizations.dart';
import 'chat_bot_page.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  Widget _topBar(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.chatMessagesTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const AppNotificationsAction(
          diameter: AppNotificationsAction.compactDiameter,
        ),
      ],
    );
  }

  Widget _searchBox(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.horizontalSpacingMedium,
        vertical: Dimensions.verticalSpacingMedium,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColorPalette.blueSteel),
          const SizedBox(width: Dimensions.horizontalSpacingRegular),
          Text(
            l10n.chatSearchHint,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColorPalette.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String time,
    required Widget leading,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.horizontalSpacingMedium),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: Dimensions.horizontalSpacingRegular),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: Dimensions.verticalSpacingExtraShort),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColorPalette.grey,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Dimensions.horizontalSpacingRegular),
            Text(
              time,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColorPalette.grey,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: appPadding,
        child: Column(
          children: [
            _topBar(context, l10n),
            const SizedBox(height: Dimensions.verticalSpacingRegular),
            _searchBox(context, l10n),
            const SizedBox(height: Dimensions.verticalSpacingRegular),
            _chatTile(
              context: context,
              title: l10n.chatAssistantCardTitle,
              subtitle: l10n.chatAssistantCardSubtitle,
              time: l10n.chatAssistantTime,
              leading: Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColorPalette.blueSteel,
                    width: 4,
                  ),
                ),
                child: const Icon(
                  Icons.smart_toy_outlined,
                  color: AppColorPalette.blueSteel,
                  size: 36,
                ),
              ),
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const ChatBotPage()));
              },
            ),
            const SizedBox(height: Dimensions.verticalSpacingRegular),
            _chatTile(
              context: context,
              title: l10n.chatCaregiverCardTitle,
              subtitle: l10n.chatCaregiverCardSubtitle,
              time: l10n.chatCaregiverTime,
              leading: Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColorPalette.blueSteel,
                  size: 38,
                ),
              ),
            ),
            const Spacer(),
            const SizedBox(height: bottomNavigationBarPadding - 24),
          ],
        ),
      ),
    );
  }
}
