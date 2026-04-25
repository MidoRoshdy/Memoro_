import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/services/chat_service.dart';
import '../../../../core/services/doctor_link_request_service.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../widgets/app_notifications_action.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shared/chat/chat_conversation_page.dart';
import 'chat_bot_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String _formatChatTime(BuildContext context, DateTime? value) {
    if (value == null) return '--:--';
    final now = DateTime.now();
    final isToday =
        value.year == now.year &&
        value.month == now.month &&
        value.day == now.day;
    if (isToday) {
      return MaterialLocalizations.of(
        context,
      ).formatTimeOfDay(TimeOfDay.fromDateTime(value));
    }
    return '${value.day}/${value.month}';
  }

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
    int unreadCount = 0,
    VoidCallback? onTap,
  }) {
    final hasUnread = unreadCount > 0;
    final leadingWithUnread = Stack(
      clipBehavior: Clip.none,
      children: [
        leading,
        if (hasUnread)
          PositionedDirectional(
            top: -4,
            end: -2,
            child: Container(
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
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
            leadingWithUnread,
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
                      fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Dimensions.horizontalSpacingRegular),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid ?? '';

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
            StreamBuilder<QueryDocumentSnapshot<Map<String, dynamic>>?>(
              stream: currentUserId.isEmpty
                  ? const Stream<
                      QueryDocumentSnapshot<Map<String, dynamic>>?
                    >.empty()
                  : DoctorLinkRequestService.watchLatestAcceptedForPatient(
                      currentUserId,
                    ),
              builder: (context, snapshot) {
                final request = snapshot.data;
                final requestData = request?.data();
                final doctorId =
                    (requestData?['doctorId'] as String?)?.trim() ?? '';
                final doctorName =
                    (requestData?['doctorName'] as String?)
                            ?.trim()
                            .isNotEmpty ==
                        true
                    ? (requestData!['doctorName'] as String).trim()
                    : l10n.chatCaregiverCardTitle;
                final doctorImageUrl =
                    (requestData?['doctorImageUrl'] as String?)?.trim() ?? '';
                final patientName =
                    (requestData?['patientName'] as String?)?.trim() ?? '';
                final patientImageUrl =
                    (requestData?['patientImageUrl'] as String?)?.trim() ?? '';
                if (doctorId.isEmpty) {
                  return _chatTile(
                    context: context,
                    title: doctorName,
                    subtitle: l10n.chatCaregiverCardSubtitle,
                    time: '--:--',
                    leading: Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: doctorImageUrl.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                doctorImageUrl,
                                fit: BoxFit.cover,
                                width: 74,
                                height: 74,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              color: AppColorPalette.blueSteel,
                              size: 38,
                            ),
                    ),
                  );
                }

                final chatId = ChatService.buildChatIdFromUids(
                  doctorId,
                  currentUserId,
                );

                return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: ChatService.chatRef(chatId).snapshots(),
                  builder: (context, chatSnapshot) {
                    final chatData = chatSnapshot.data?.data();
                    final lastMessage =
                        (chatData?['lastMessageText'] as String?)?.trim();
                    final lastMessageAtRaw = chatData?['lastMessageAt'];
                    final lastMessageAt = lastMessageAtRaw is Timestamp
                        ? lastMessageAtRaw.toDate()
                        : null;
                    final unreadCount = ChatService.unreadCountForUser(
                      chatData,
                      currentUserId,
                    );
                    return _chatTile(
                      context: context,
                      title: doctorName,
                      subtitle: (lastMessage != null && lastMessage.isNotEmpty)
                          ? lastMessage
                          : l10n.chatCaregiverCardSubtitle,
                      time: _formatChatTime(context, lastMessageAt),
                      unreadCount: unreadCount,
                      leading: Container(
                        width: 74,
                        height: 74,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                        ),
                        child: doctorImageUrl.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  doctorImageUrl,
                                  fit: BoxFit.cover,
                                  width: 74,
                                  height: 74,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                color: AppColorPalette.blueSteel,
                                size: 38,
                              ),
                      ),
                      onTap: () async {
                        if (currentUserId.isEmpty || doctorId.isEmpty) {
                          return;
                        }
                        final ensuredChatId =
                            await ChatService.ensureChannelForDoctorPatient(
                              doctorId: doctorId,
                              patientUid: currentUserId,
                              doctorName: doctorName,
                              doctorImageUrl: doctorImageUrl,
                              patientName: patientName,
                              patientImageUrl: patientImageUrl,
                              requestId: request?.id,
                            );
                        if (!context.mounted) return;
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ChatConversationPage(
                              chatId: ensuredChatId,
                              currentUserId: currentUserId,
                              title: doctorName,
                              avatarUrl: doctorImageUrl,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            const Spacer(),
            const SizedBox(height: bottomNavigationBarPadding - 24),
          ],
        ),
      ),
    );
  }
}
