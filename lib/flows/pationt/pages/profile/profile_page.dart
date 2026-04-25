import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/string_assets.dart';
import '../../../../core/models/activity_item.dart';
import '../../../../core/models/medicine_item.dart';
import '../../../../core/providers/user_profile_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/activity_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/chat_service.dart';
import '../../../../core/services/doctor_link_request_service.dart';
import '../../../../core/services/medicine_service.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shared/chat/chat_conversation_page.dart';
import '../../widgets/language_picker_sheet.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Widget _infoCard({
    required BuildContext context,
    required Widget icon,
    required Color iconBg,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: appPadding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(Dimensions.cardCornerRadius),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: iconBg,
            child: Padding(
              padding: const EdgeInsets.all(
                Dimensions.horizontalSpacingExtraShort,
              ),
              child: icon,
            ),
          ),
          const SizedBox(width: Dimensions.horizontalSpacingRegular),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColorPalette.grey),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.cardCornerRadius),
      child: Container(
        width: double.infinity,
        padding: appPadding,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(Dimensions.cardCornerRadius),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: Dimensions.horizontalSpacingRegular),
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColorPalette.grey,
            ),
          ],
        ),
      ),
    );
  }

  int? _parseHour(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return null;
    final normalized = raw.toUpperCase();
    final isAm = normalized.contains('AM');
    final isPm = normalized.contains('PM');
    final clean = normalized.replaceAll('AM', '').replaceAll('PM', '').trim();
    final parts = clean.split(':');
    final h = int.tryParse(parts.first.trim());
    if (h == null) return null;
    if (isAm || isPm) {
      var hour = h % 12;
      if (isPm) hour += 12;
      return hour;
    }
    if (h >= 0 && h <= 23) return h;
    return null;
  }

  int? _parseMinute(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return null;
    final normalized = raw.toUpperCase();
    final clean = normalized.replaceAll('AM', '').replaceAll('PM', '').trim();
    final parts = clean.split(':');
    if (parts.length < 2) return 0;
    final m = int.tryParse(parts[1].trim());
    if (m == null || m < 0 || m > 59) return null;
    return m;
  }

  String _nextMedicineSubtitle(List<MedicineItem> medicines, String fallback) {
    if (medicines.isEmpty) return fallback;
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    MedicineItem? bestMedicine;
    String bestTime = '';
    var bestDiff = 1 << 30;

    for (final medicine in medicines.where((m) => !m.isTaken)) {
      final times = medicine.scheduledTimes.isNotEmpty
          ? medicine.scheduledTimes
          : <String>[medicine.primaryTime, medicine.scheduledTime];
      for (final t in times) {
        final h = _parseHour(t);
        final m = _parseMinute(t);
        if (h == null || m == null) continue;
        final targetMinutes = h * 60 + m;
        final diff = targetMinutes >= nowMinutes
            ? targetMinutes - nowMinutes
            : (24 * 60 - nowMinutes) + targetMinutes;
        if (diff < bestDiff) {
          bestDiff = diff;
          bestMedicine = medicine;
          bestTime = t.trim();
        }
      }
    }
    if (bestMedicine == null) return fallback;
    if (bestTime.isEmpty) return bestMedicine.name;
    return '${bestMedicine.name} • $bestTime';
  }

  String _nextActivitySubtitle(List<ActivityItem> activities, String fallback) {
    final pending = activities
        .where((a) => !a.isCompleted && !a.isCancelled)
        .toList();
    if (pending.isEmpty) return fallback;
    pending.sort((a, b) {
      final ta = a.createdAt;
      final tb = b.createdAt;
      if (ta == null && tb == null) return 0;
      if (ta == null) return 1;
      if (tb == null) return -1;
      return ta.compareTo(tb);
    });
    final next = pending.first;
    final time = next.scheduledTime.trim();
    if (time.isEmpty) return next.title;
    return '${next.title} • $time';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileState = ref.watch(currentUserProfileProvider);
    final user = profileState.asData?.value;
    final name = user?.name.trim().isNotEmpty == true
        ? user!.name
        : l10n.profilePlaceholderUserName;
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return SafeArea(
      child: Padding(
        padding: appPadding,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.profileTitleMyProfile,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColorPalette.blueSteel.withValues(
                    alpha: 0.7,
                  ),
                  backgroundImage: (user?.imageUrl ?? '').isNotEmpty
                      ? NetworkImage(user!.imageUrl)
                      : null,
                  child: (user?.imageUrl ?? '').isEmpty
                      ? const Icon(Icons.person, color: Colors.white, size: 38)
                      : null,
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              Text(
                name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if ((user?.patientId.trim().isNotEmpty ?? false) ||
                  currentUid.isNotEmpty) ...[
                const SizedBox(height: Dimensions.verticalSpacingExtraShort),
                Text(
                  'Patient ID: ${(user?.patientId.trim().isNotEmpty ?? false) ? user!.patientId.trim() : currentUid}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: Dimensions.verticalSpacingShort),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.horizontalSpacingMedium,
                  vertical: Dimensions.verticalSpacingShort,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(containerRadius),
                ),
                child: Text(
                  l10n.profileYouAreSafe,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColorPalette.blueSteel,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              if (currentUid.isNotEmpty)
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection(DoctorLinkRequestService.collectionName)
                      .where('patientUid', isEqualTo: currentUid)
                      .snapshots(),
                  builder: (context, linkSnap) {
                    final docs = linkSnap.data?.docs ?? const [];
                    final pending =
                        DoctorLinkRequestService.pickLatestForPatient(
                          docs,
                          currentUid,
                          status: DoctorLinkRequestService.requestStatusPending,
                        );
                    final accepted =
                        DoctorLinkRequestService.pickLatestForPatient(
                          docs,
                          currentUid,
                          status:
                              DoctorLinkRequestService.requestStatusAccepted,
                        );

                    if (accepted == null && pending == null) {
                      return const SizedBox.shrink();
                    }

                    if (accepted == null && pending != null) {
                      final data = pending.data();
                      final doctorName =
                          (data['doctorName'] as String?)?.trim().isNotEmpty ==
                              true
                          ? (data['doctorName'] as String).trim()
                          : l10n.profilePlaceholderCaregiverName;
                      final doctorImageUrl =
                          (data['doctorImageUrl'] as String?)?.trim() ?? '';
                      return Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: appPadding,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(
                                Dimensions.cardCornerRadius,
                              ),
                            ),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: const Color(0xFFE8F3FF),
                                  backgroundImage: doctorImageUrl.isNotEmpty
                                      ? NetworkImage(doctorImageUrl)
                                      : null,
                                  child: doctorImageUrl.isEmpty
                                      ? const Icon(
                                          Icons.health_and_safety_outlined,
                                          color: AppColorPalette.blueSteel,
                                        )
                                      : null,
                                ),
                                const SizedBox(
                                  height: Dimensions.verticalSpacingRegular,
                                ),
                                Text(
                                  'Accept Care Giver',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(
                                  height: Dimensions.verticalSpacingExtraShort,
                                ),
                                Text(
                                  doctorName,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: AppColorPalette.grey,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(
                                  height: Dimensions.verticalSpacingRegular,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await pending.reference.set({
                                        'requestStatus':
                                            DoctorLinkRequestService
                                                .requestStatusAccepted,
                                        'acceptedAt':
                                            FieldValue.serverTimestamp(),
                                        'updatedAt':
                                            FieldValue.serverTimestamp(),
                                      }, SetOptions(merge: true));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppColorPalette.blueSteel,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Accept Caregiver'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: Dimensions.verticalSpacingRegular,
                          ),
                        ],
                      );
                    }

                    final acceptedData = accepted!.data();
                    final doctorUid =
                        (acceptedData['doctorId'] as String?)?.trim() ?? '';
                    final doctorName =
                        (acceptedData['doctorName'] as String?)
                                ?.trim()
                                .isNotEmpty ==
                            true
                        ? (acceptedData['doctorName'] as String).trim()
                        : l10n.profilePlaceholderCaregiverName;
                    final doctorImageUrl =
                        (acceptedData['doctorImageUrl'] as String?)?.trim() ??
                        '';

                    Future<String> resolveDoctorPhone() async {
                      final direct =
                          (acceptedData['doctorPhone'] as String?)?.trim() ??
                          '';
                      if (direct.isNotEmpty) return direct;
                      if (doctorUid.isEmpty) return '';
                      try {
                        final snap = await AuthService.caregiverProfileRef(
                          doctorUid,
                        ).get();
                        return (snap.data()?['phone'] as String?)?.trim() ?? '';
                      } catch (_) {
                        return '';
                      }
                    }

                    Future<void> openCaregiverCall() async {
                      final phone = await resolveDoctorPhone();
                      if (phone.isEmpty) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Caregiver phone not available'),
                          ),
                        );
                        return;
                      }
                      final launched = await launchUrl(
                        Uri.parse('tel:$phone'),
                        mode: LaunchMode.externalApplication,
                      );
                      if (!launched && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not open phone app'),
                          ),
                        );
                      }
                    }

                    Future<void> openCaregiverMessage() async {
                      if (doctorUid.isEmpty) return;
                      final ensuredChatId =
                          await ChatService.ensureChannelForDoctorPatient(
                            doctorId: doctorUid,
                            patientUid: currentUid,
                            doctorName: doctorName,
                            doctorImageUrl: doctorImageUrl,
                            patientName: name,
                            patientImageUrl: user?.imageUrl ?? '',
                          );
                      if (!context.mounted) return;
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ChatConversationPage(
                            chatId: ensuredChatId,
                            currentUserId: currentUid,
                            title: doctorName,
                            avatarUrl: doctorImageUrl,
                          ),
                        ),
                      );
                    }

                    if (doctorUid.isEmpty) return const SizedBox.shrink();

                    final medicineDocId = MedicineService.buildMedicineDocId(
                      doctorUid,
                      currentUid,
                    );
                    final activityDocId = ActivityService.buildActivityDocId(
                      doctorUid,
                      currentUid,
                    );

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 58,
                                child: ElevatedButton.icon(
                                  onPressed: openCaregiverCall,
                                  icon: const Icon(Icons.call),
                                  label: Text(l10n.profileCallCaregiver),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColorPalette.blueSteel,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: Dimensions.horizontalSpacingRegular,
                            ),
                            Expanded(
                              child: SizedBox(
                                height: 58,
                                child: ElevatedButton.icon(
                                  onPressed: openCaregiverMessage,
                                  icon: const Icon(
                                    Icons.chat_bubble_outline_rounded,
                                  ),
                                  label: Text(l10n.profileMessageButton),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColorPalette.blueSteel,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: Dimensions.verticalSpacingRegular,
                        ),
                        _infoCard(
                          context: context,
                          icon: Image.asset(
                            AppAssets.caregiverIcon,
                            fit: BoxFit.contain,
                          ),
                          iconBg: const Color(0xFFE8F3FF),
                          title: l10n.profileYourCaregiver,
                          subtitle: doctorName,
                        ),
                        const SizedBox(
                          height: Dimensions.verticalSpacingRegular,
                        ),
                        StreamBuilder<List<MedicineItem>>(
                          stream: MedicineService.watchMedicines(medicineDocId),
                          builder: (context, medSnap) {
                            final subtitle = _nextMedicineSubtitle(
                              medSnap.data ?? const <MedicineItem>[],
                              l10n.profilePlaceholderNextMedTime,
                            );
                            return _infoCard(
                              context: context,
                              icon: Image.asset(
                                AppAssets.greenMedicineIcon,
                                fit: BoxFit.contain,
                              ),
                              iconBg: const Color(0xFFE4F8EA),
                              title: l10n.profileNextMedication,
                              subtitle: subtitle,
                            );
                          },
                        ),
                        const SizedBox(
                          height: Dimensions.verticalSpacingRegular,
                        ),
                        StreamBuilder<List<ActivityItem>>(
                          stream: ActivityService.watchActivities(
                            activityDocId,
                          ),
                          builder: (context, actSnap) {
                            final subtitle = _nextActivitySubtitle(
                              actSnap.data ?? const <ActivityItem>[],
                              l10n.profilePlaceholderActivity,
                            );
                            return _infoCard(
                              context: context,
                              icon: const Icon(
                                Icons.favorite,
                                size: 16,
                                color: AppColorPalette.violet,
                              ),
                              iconBg: const Color(0xFFEDE7FF),
                              title: l10n.profileTodaysActivity,
                              subtitle: subtitle,
                            );
                          },
                        ),
                        const SizedBox(
                          height: Dimensions.verticalSpacingRegular,
                        ),
                      ],
                    );
                  },
                ),
              _menuTile(
                context: context,
                icon: Icons.settings,
                iconColor: AppColorPalette.grey,
                title: l10n.settingsScreenTitle,
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRouter.settings),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              _menuTile(
                context: context,
                icon: Icons.shield_outlined,
                iconColor: AppColorPalette.redBright,
                title: l10n.profileSosSettings,
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRouter.sosSettings),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              _menuTile(
                context: context,
                icon: Icons.language,
                iconColor: AppColorPalette.grey,
                title: l10n.languageLabel,
                onTap: () => showLanguagePickerSheet(context),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              InkWell(
                onTap: () async {
                  await AuthService.logout();
                  if (!context.mounted) return;
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(AppRouter.chooseFlow, (_) => false);
                },
                borderRadius: BorderRadius.circular(
                  Dimensions.cardCornerRadius,
                ),
                child: Container(
                  width: double.infinity,
                  padding: appPadding,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(
                      Dimensions.cardCornerRadius,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.logout,
                        color: AppColorPalette.redBright,
                      ),
                      const SizedBox(
                        width: Dimensions.horizontalSpacingRegular,
                      ),
                      Text(
                        l10n.logoutButton,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColorPalette.redBright,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: bottomNavigationBarPadding),
            ],
          ),
        ),
      ),
    );
  }
}
