import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/doctor_link_request_service.dart';
import '../../../../core/services/local_notification_service.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';

class SosSettingsPage extends StatefulWidget {
  const SosSettingsPage({super.key});

  @override
  State<SosSettingsPage> createState() => _SosSettingsPageState();
}

class _SosSettingsPageState extends State<SosSettingsPage> {
  static const String _shareLocationKey = 'sos_share_location_enabled';
  static const String _autoCallKey = 'sos_auto_call_enabled';

  bool _shareLocation = true;
  bool _autoCall = true;
  bool _loadingPrefs = true;
  bool _loadingContact = true;
  String _caregiverName = '';
  String _caregiverPhone = '';
  bool _hasLinkedDoctor = false;

  QueryDocumentSnapshot<Map<String, dynamic>>? _pickLinkedRequest(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    if (docs.isEmpty) return null;
    final acceptedLike = docs.where((doc) {
      final status =
          ((doc.data()['requestStatus'] ?? doc.data()['status']) as String?)
              ?.trim()
              .toLowerCase() ??
          '';
      return status == 'accepted' || status == 'approved' || status == 'linked';
    }).toList();
    final source = acceptedLike.isNotEmpty ? acceptedLike : docs;
    source.sort((a, b) {
      DateTime? read(dynamic raw) {
        if (raw is Timestamp) return raw.toDate();
        if (raw is DateTime) return raw;
        return null;
      }

      final ad = read(a.data()['updatedAt']) ?? read(a.data()['createdAt']);
      final bd = read(b.data()['updatedAt']) ?? read(b.data()['createdAt']);
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return bd.compareTo(ad);
    });
    return source.first;
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadEmergencyContact();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _shareLocation = prefs.getBool(_shareLocationKey) ?? true;
      _autoCall = prefs.getBool(_autoCallKey) ?? true;
      _loadingPrefs = false;
    });
  }

  Future<void> _loadEmergencyContact() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      if (!mounted) return;
      setState(() => _loadingContact = false);
      return;
    }
    try {
      final isCaregiver = await AuthService.isCurrentUserCaregiver();
      if (isCaregiver) {
        final selfSnap = await AuthService.caregiverProfileRef(uid).get();
        final selfData = selfSnap.data() ?? <String, dynamic>{};
        final selfName = (selfData['name'] as String?)?.trim() ?? '';
        final selfPhone = (selfData['phone'] as String?)?.trim() ?? '';
        if (!mounted) return;
        setState(() {
          _caregiverName = selfName;
          _caregiverPhone = selfPhone;
          _hasLinkedDoctor = selfName.isNotEmpty || selfPhone.isNotEmpty;
          _loadingContact = false;
        });
        return;
      }

      final requestSnap = await FirebaseFirestore.instance
          .collection(DoctorLinkRequestService.collectionName)
          .where('patientUid', isEqualTo: uid)
          .get();
      final linked = _pickLinkedRequest(requestSnap.docs);
      final data = linked?.data();
      var doctorUid =
          (data?['doctorId'] as String?)?.trim() ??
          (data?['doctorUid'] as String?)?.trim() ??
          '';
      if (doctorUid.isEmpty) {
        final pairId = (data?['pairId'] as String?)?.trim() ?? '';
        if (pairId.contains('_')) {
          final parts = pairId.split('_');
          doctorUid = parts.firstWhere(
            (part) => part.trim().isNotEmpty && part.trim() != uid,
            orElse: () => '',
          );
        }
      }
      var doctorName = (data?['doctorName'] as String?)?.trim() ?? '';
      var doctorPhone =
          (data?['doctorPhone'] as String?)?.trim() ??
          (data?['phone'] as String?)?.trim() ??
          '';
      if (doctorUid.isNotEmpty && (doctorName.isEmpty || doctorPhone.isEmpty)) {
        final caregiverSnap = await AuthService.caregiverProfileRef(
          doctorUid,
        ).get();
        final caregiverData = caregiverSnap.data() ?? <String, dynamic>{};
        doctorName = doctorName.isNotEmpty
            ? doctorName
            : (caregiverData['name'] as String?)?.trim() ?? '';
        doctorPhone = doctorPhone.isNotEmpty
            ? doctorPhone
            : (caregiverData['phone'] as String?)?.trim() ?? '';
      }
      if (!mounted) return;
      setState(() {
        _caregiverName = doctorName;
        _caregiverPhone = doctorPhone;
        _hasLinkedDoctor = doctorUid.isNotEmpty;
        _loadingContact = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasLinkedDoctor = false;
        _loadingContact = false;
      });
    }
  }

  Future<void> _toggleShareLocation(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_shareLocationKey, value);
    if (!mounted) return;
    setState(() => _shareLocation = value);
  }

  Future<void> _toggleAutoCall(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoCallKey, value);
    if (!mounted) return;
    setState(() => _autoCall = value);
  }

  Future<void> _callEmergencyContact() async {
    final phone = _caregiverPhone.trim();
    if (phone.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Emergency contact phone not available')),
      );
      return;
    }
    final launched = await launchUrl(
      Uri.parse('tel:$phone'),
      mode: LaunchMode.externalApplication,
    );
    if (!launched && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open phone app')));
    }
  }

  Future<void> _testSosSystem() async {
    final l10n = AppLocalizations.of(context)!;
    await LocalNotificationService.scheduleOneShot(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Memoro SOS Test',
      body: 'SOS settings test notification',
      channelId: LocalNotificationService.emergencyChannelId,
      delay: const Duration(seconds: 3),
      payload: const <String, dynamic>{'type': 'help_request'},
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${l10n.sosTestButton} OK')));
  }

  Widget _rowCard({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    Widget? trailing,
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
            child: Icon(icon, size: 16, color: AppColorPalette.blueSteel),
          ),
          const SizedBox(width: Dimensions.horizontalSpacingRegular),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColorPalette.grey),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loadingPrefs) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final caregiverName = _caregiverName.trim();
    final caregiverPhone = _caregiverPhone.trim();
    final hasEmergencyContact =
        _hasLinkedDoctor &&
        caregiverName.isNotEmpty &&
        caregiverPhone.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: appPadding,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        l10n.sosSettingsScreenTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: Dimensions.verticalSpacingRegular),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: Color(0xFFFFEBEE),
                            child: Icon(
                              Icons.phone_in_talk,
                              color: AppColorPalette.redDark,
                              size: 16,
                            ),
                          ),
                          const SizedBox(
                            width: Dimensions.horizontalSpacingRegular,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.sosEmergencyContactTitle,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                l10n.sosPrimaryCaregiverSubtitle,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColorPalette.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.verticalSpacingRegular),
                      Text(l10n.sosCaregiverNameLabel),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(
                          Dimensions.horizontalSpacingRegular,
                        ),
                        margin: const EdgeInsets.only(
                          top: Dimensions.verticalSpacingExtraShort,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(containerRadius),
                        ),
                        child: Text(
                          _loadingContact
                              ? '...'
                              : (caregiverName.isNotEmpty
                                    ? caregiverName
                                    : l10n.doctorMedConnectFirst),
                        ),
                      ),
                      const SizedBox(height: Dimensions.verticalSpacingRegular),
                      Text(l10n.sosPhoneNumberLabel),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(
                          Dimensions.horizontalSpacingRegular,
                        ),
                        margin: const EdgeInsets.only(
                          top: Dimensions.verticalSpacingExtraShort,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(containerRadius),
                        ),
                        child: Text(
                          _loadingContact
                              ? '...'
                              : (caregiverPhone.isNotEmpty
                                    ? caregiverPhone
                                    : '—'),
                        ),
                      ),
                      const SizedBox(height: Dimensions.verticalSpacingRegular),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _loadingContact || !hasEmergencyContact
                              ? null
                              : _callEmergencyContact,
                          icon: const Icon(Icons.call),
                          label: Text(l10n.sosCallEmergencyContact),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColorPalette.redBright,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.verticalSpacingLarge),
                Text(
                  l10n.sosOptionsHeader,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: Dimensions.verticalSpacingRegular),
                _rowCard(
                  context: context,
                  icon: Icons.location_on_outlined,
                  iconBg: const Color(0xFFE6F5FD),
                  title: l10n.sosShareLocationTitle,
                  subtitle: l10n.sosShareLocationSubtitle,
                  trailing: Switch(
                    value: _shareLocation,
                    onChanged: _toggleShareLocation,
                    activeThumbColor: AppColorPalette.blueSteel,
                  ),
                ),
                const SizedBox(height: Dimensions.verticalSpacingRegular),
                _rowCard(
                  context: context,
                  icon: Icons.call,
                  iconBg: const Color(0xFFE8F3FF),
                  title: l10n.sosAutoCallTitle,
                  subtitle: l10n.sosAutoCallSubtitle,
                  trailing: Switch(
                    value: _autoCall,
                    onChanged: _toggleAutoCall,
                    activeThumbColor: AppColorPalette.blueSteel,
                  ),
                ),
                const SizedBox(height: Dimensions.verticalSpacingRegular),
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
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFE8F3FF),
                        child: Icon(
                          Icons.shield_outlined,
                          color: AppColorPalette.blueSteel,
                        ),
                      ),
                      const SizedBox(height: Dimensions.verticalSpacingRegular),
                      Text(
                        l10n.sosTestSystemTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        l10n.sosTestSystemSubtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColorPalette.grey,
                        ),
                      ),
                      const SizedBox(height: Dimensions.verticalSpacingRegular),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: _testSosSystem,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(l10n.sosTestButton),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColorPalette.blueSteel,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.verticalSpacingRegular),
                Container(
                  width: double.infinity,
                  padding: appPadding,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFCEB),
                    borderRadius: BorderRadius.circular(
                      Dimensions.cardCornerRadius,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColorPalette.gold,
                          ),
                          const SizedBox(
                            width: Dimensions.horizontalSpacingRegular,
                          ),
                          Text(
                            l10n.sosHowItWorksTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.verticalSpacingShort),
                      Text(l10n.sosHowItWorksBullet1),
                      Text(l10n.sosHowItWorksBullet2),
                      Text(l10n.sosHowItWorksBullet3),
                    ],
                  ),
                ),
                const SizedBox(height: bottomNavigationBarPadding),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
