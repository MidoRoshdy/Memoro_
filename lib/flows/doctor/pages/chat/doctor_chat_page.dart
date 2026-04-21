import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/services/chat_service.dart';
import '../../../../core/services/doctor_link_request_service.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shared/chat/chat_conversation_page.dart';
import '../../../pationt/widgets/app_notifications_action.dart';

class DoctorChatPage extends StatefulWidget {
  const DoctorChatPage({super.key});

  @override
  State<DoctorChatPage> createState() => _DoctorChatPageState();
}

class _DoctorChatPageState extends State<DoctorChatPage> {
  String _formatChatTime(BuildContext context, DateTime? value) {
    if (value == null) return '--:--';
    final now = DateTime.now();
    final isToday =
        value.year == now.year && value.month == now.month && value.day == now.day;
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
            StreamBuilder<DoctorLinkStreamState>(
              stream: currentUserId.isEmpty
                  ? const Stream<DoctorLinkStreamState>.empty()
                  : DoctorLinkRequestService.watchDoctorLinkUiState(currentUserId),
              builder: (context, snapshot) {
                final requestData = snapshot.data?.requestData;
                final patientUid =
                    (requestData?['patientUid'] as String?)?.trim() ?? '';
                final patientName =
                    (requestData?['patientName'] as String?)?.trim().isNotEmpty ==
                        true
                    ? (requestData!['patientName'] as String).trim()
                    : 'Patient';
                final patientImageUrl =
                    (requestData?['patientImageUrl'] as String?)?.trim() ?? '';
                final doctorName =
                    (requestData?['doctorName'] as String?)?.trim() ?? '';
                final doctorImageUrl =
                    (requestData?['doctorImageUrl'] as String?)?.trim() ?? '';
                if (patientUid.isEmpty) {
                  return _chatTile(
                    context: context,
                    title: patientName,
                    subtitle: l10n.chatCaregiverCardSubtitle,
                    time: '--:--',
                    leading: Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: patientImageUrl.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                patientImageUrl,
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
                  currentUserId,
                  patientUid,
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
                    return _chatTile(
                      context: context,
                      title: patientName,
                      subtitle: (lastMessage != null && lastMessage.isNotEmpty)
                          ? lastMessage
                          : l10n.chatCaregiverCardSubtitle,
                      time: _formatChatTime(context, lastMessageAt),
                      leading: Container(
                        width: 74,
                        height: 74,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                        ),
                        child: patientImageUrl.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  patientImageUrl,
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
                        if (currentUserId.isEmpty || patientUid.isEmpty) {
                          return;
                        }
                        final ensuredChatId =
                            await ChatService.ensureChannelForDoctorPatient(
                              doctorId: currentUserId,
                              patientUid: patientUid,
                              doctorName: doctorName,
                              doctorImageUrl: doctorImageUrl,
                              patientName: patientName,
                              patientImageUrl: patientImageUrl,
                              requestId: snapshot.data?.requestId,
                            );
                        if (!context.mounted) return;
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ChatConversationPage(
                              chatId: ensuredChatId,
                              currentUserId: currentUserId,
                              title: patientName,
                              avatarUrl: patientImageUrl,
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
