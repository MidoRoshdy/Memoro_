import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/string_assets.dart';
import '../../../../core/models/activity_item.dart';
import '../../../../core/models/medicine_item.dart';
import '../../../../core/services/activity_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/doctor_link_request_service.dart';
import '../../../../core/services/medicine_service.dart';
import '../../../../l10n/app_localizations.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = <_ChatMessage>[];
  _LanguageMode _languageMode = _LanguageMode.english;
  List<_FaqItem> _faqItems = <_FaqItem>[];
  bool _isBotTyping = false;
  bool _isLoading = false;
  bool _isFaqLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFaqs();
  }

  Future<void> _loadFaqs() async {
    try {
      final raw = await rootBundle.loadString(AppAssets.alzheimersQaJson);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final list = (decoded['faqs'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(_FaqItem.fromMap)
          .toList();
      if (!mounted) return;
      setState(() {
        _faqItems = list;
        _isFaqLoading = false;
      });
      _addQuestionBubble();
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isFaqLoading = false;
        _messages.add(
          const _ChatMessage(
            text: 'Could not load questions right now.',
            isUser: false,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onQuestionTap(_FaqItem item) async {
    if (_isLoading || _isBotTyping) return;
    final isArabic = _languageMode == _LanguageMode.arabic;
    final question = isArabic ? item.questionAr : item.questionEn;
    final answer = await _resolveAnswerText(item, isArabic: isArabic);

    setState(() {
      _messages.add(_ChatMessage(text: question, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isBotTyping = true;
      _messages.add(const _ChatMessage(text: '', isUser: false));
    });
    _scrollToBottom();

    await _typeBotAnswer(answer);

    if (!mounted) return;
    setState(() {
      _messages.add(_buildOptionsMessage());
    });
    _scrollToBottom();
  }

  Future<String> _resolveAnswerText(
    _FaqItem item, {
    required bool isArabic,
  }) async {
    final key = item.questionAr.trim();
    if (key == 'أنا اسمي إيه؟') {
      final name = await _readCurrentUserName();
      return isArabic ? 'اسمك $name.' : 'Your name is $name.';
    }
    if (key == 'النهارده كام؟') {
      final now = DateTime.now();
      final date = '${now.day}/${now.month}/${now.year}';
      return isArabic ? 'النهارده $date.' : 'Today is $date.';
    }
    if (key == 'أنا فين؟') {
      final place = await _readCurrentPlace();
      return isArabic ? 'إنت في $place.' : 'You are in $place.';
    }
    if (key == 'أنا عليا أدوية إيه؟') {
      final medicines = await _readPatientMedicines();
      if (medicines.isEmpty) {
        return isArabic
            ? 'حاليًا لا توجد أدوية مسجلة لك.'
            : 'You currently have no medicines assigned.';
      }
      final names = medicines
          .take(3)
          .map((m) => m.name.trim())
          .where((n) => n.isNotEmpty)
          .toList();
      final text = names.join('، ');
      return isArabic
          ? 'عليك الآن: $text.'
          : 'Your current medicines are: $text.';
    }
    if (key == 'إيه الأنشطة اللي عليا دلوقت؟') {
      final activities = await _readPatientActivities();
      if (activities.isEmpty) {
        return isArabic
            ? 'حاليًا لا توجد أنشطة مضافة لك.'
            : 'You currently have no assigned activities.';
      }
      final titles = activities
          .where((a) => !a.isCompleted)
          .take(3)
          .map((a) => a.title.trim())
          .where((t) => t.isNotEmpty)
          .toList();
      if (titles.isEmpty) {
        return isArabic
            ? 'ممتاز! أتممت كل الأنشطة الحالية.'
            : 'Great! You completed all current activities.';
      }
      return isArabic
          ? 'الأنشطة الحالية: ${titles.join('، ')}.'
          : 'Your current activities are: ${titles.join(', ')}.';
    }
    if (key == 'أخدت الدوا بتاعي ولا لأ؟') {
      final medicines = await _readPatientMedicines();
      if (medicines.isEmpty) {
        return isArabic
            ? 'لا توجد أدوية مسجلة حاليًا.'
            : 'No medicines are currently assigned.';
      }
      final next = medicines.firstWhere(
        (m) => !m.isTaken,
        orElse: () => medicines.first,
      );
      final time = next.primaryTime.trim().isEmpty
          ? '--:--'
          : next.primaryTime.trim();
      return isArabic
          ? 'حسب الجدول، دواء ${next.name} موعده $time. تحب أفكرك تاخده دلوقتي؟'
          : 'According to your schedule, ${next.name} is due at $time. Want a reminder now?';
    }
    if (key == 'عندي ميعاد النهارده؟') {
      final activities = await _readPatientActivities();
      final next = activities
          .where((a) => !a.isCompleted)
          .cast<ActivityItem?>()
          .firstWhere(
            (a) => (a?.scheduledTime.trim().isNotEmpty ?? false),
            orElse: () => null,
          );
      final time = next?.scheduledTime.trim() ?? '';
      if (time.isEmpty) {
        return isArabic
            ? 'لا يوجد ميعاد واضح اليوم في بياناتك الحالية.'
            : 'There is no clear appointment for today in your current data.';
      }
      return isArabic
          ? 'أيوه، عندك ميعاد اليوم الساعة $time.'
          : 'Yes, you have an appointment today at $time.';
    }
    return isArabic ? item.answerAr : item.answerEn;
  }

  Future<String> _readCurrentUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Guest';
    try {
      final snap = await AuthService.patientProfileRef(user.uid).get();
      final name = (snap.data()?['name'] as String?)?.trim() ?? '';
      if (name.isNotEmpty) return name;
    } on FirebaseException {
      // Fall back to auth profile.
    }
    return (user.displayName?.trim().isNotEmpty ?? false)
        ? user.displayName!.trim()
        : 'Guest';
  }

  Future<String> _readCurrentPlace() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'المنزل';
    try {
      final snap = await AuthService.patientProfileRef(user.uid).get();
      final data = snap.data() ?? const <String, dynamic>{};
      final place =
          (data['locationName'] as String?)?.trim() ??
          (data['address'] as String?)?.trim() ??
          '';
      if (place.isNotEmpty) return place;
    } on FirebaseException {
      // Keep default.
    }
    return _languageMode == _LanguageMode.arabic ? 'المنزل' : 'home';
  }

  Future<String?> _readLinkedDoctorUid(String patientUid) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection(DoctorLinkRequestService.collectionName)
          .where('patientUid', isEqualTo: patientUid)
          .get();
      final latest = DoctorLinkRequestService.pickLatestForPatient(
        snap.docs,
        patientUid,
        status: DoctorLinkRequestService.requestStatusAccepted,
      );
      final data = latest?.data();
      final doctorUid = (data?['doctorId'] as String?)?.trim() ?? '';
      if (doctorUid.isNotEmpty) return doctorUid;
    } on FirebaseException {
      return null;
    }
    return null;
  }

  Future<List<MedicineItem>> _readPatientMedicines() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return const <MedicineItem>[];
    final doctorUid = await _readLinkedDoctorUid(uid);
    if (doctorUid == null || doctorUid.isEmpty) return const <MedicineItem>[];
    final medicineDocId = MedicineService.buildMedicineDocId(doctorUid, uid);
    try {
      final snap = await FirebaseFirestore.instance
          .collection(MedicineService.collectionName)
          .doc(medicineDocId)
          .collection(MedicineService.itemsSubcollection)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();
      return snap.docs
          .map((d) => MedicineItem.fromFirestore(d.id, d.data()))
          .toList();
    } on FirebaseException {
      return const <MedicineItem>[];
    }
  }

  Future<List<ActivityItem>> _readPatientActivities() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return const <ActivityItem>[];
    final doctorUid = await _readLinkedDoctorUid(uid);
    if (doctorUid == null || doctorUid.isEmpty) return const <ActivityItem>[];
    final activityDocId = ActivityService.buildActivityDocId(doctorUid, uid);
    try {
      final snap = await FirebaseFirestore.instance
          .collection(ActivityService.collectionName)
          .doc(activityDocId)
          .collection(ActivityService.itemsSubcollection)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();
      return snap.docs
          .map((d) => ActivityItem.fromFirestore(d.id, d.data()))
          .toList();
    } on FirebaseException {
      return const <ActivityItem>[];
    }
  }

  Future<void> _typeBotAnswer(String answer) async {
    for (var i = 1; i <= answer.length; i++) {
      if (!mounted) return;
      await Future<void>.delayed(const Duration(milliseconds: 16));
      setState(() {
        final lastIndex = _messages.length - 1;
        _messages[lastIndex] = _ChatMessage(
          text: answer.substring(0, i),
          isUser: false,
        );
      });
      _scrollToBottom();
    }
    if (!mounted) return;
    setState(() {
      _isBotTyping = false;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chatBotTitle),
        actions: [
          PopupMenuButton<_LanguageMode>(
            tooltip: l10n.languageLabel,
            initialValue: _languageMode,
            onSelected: (value) {
              setState(() {
                _languageMode = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _LanguageMode.english,
                child: Text(l10n.englishLabel),
              ),
              PopupMenuItem(
                value: _LanguageMode.arabic,
                child: Text(l10n.arabicLabel),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final align = msg.isUser
                    ? AlignmentDirectional.centerEnd
                    : AlignmentDirectional.centerStart;
                final bgColor = msg.isUser
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest;

                return Align(
                  alignment: align,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    constraints: const BoxConstraints(maxWidth: 300),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: msg.optionItems == null
                        ? Text(msg.text)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(msg.text),
                              shortVerticalSpace,
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: msg.optionItems!.map((item) {
                                  final label =
                                      _languageMode == _LanguageMode.arabic
                                      ? item.questionAr
                                      : item.questionEn;
                                  return ActionChip(
                                    label: Text(label),
                                    onPressed: (_isLoading || _isBotTyping)
                                        ? null
                                        : () => _onQuestionTap(item),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Text(
                _languageMode == _LanguageMode.arabic
                    ? l10n.chatMedicalDisclaimer
                    : l10n.chatMedicalDisclaimer,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          if (_isFaqLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  void _addQuestionBubble() {
    _messages.add(_buildOptionsMessage());
  }

  _ChatMessage _buildOptionsMessage() {
    final l10n = AppLocalizations.of(context)!;
    final text = _languageMode == _LanguageMode.arabic
        ? l10n.chatChooseQuestion
        : l10n.chatChooseQuestion;
    return _ChatMessage(text: text, isUser: false, optionItems: _faqItems);
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final List<_FaqItem>? optionItems;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.optionItems,
  });
}

class _FaqItem {
  final String questionEn;
  final String questionAr;
  final String answerEn;
  final String answerAr;

  const _FaqItem({
    required this.questionEn,
    required this.questionAr,
    required this.answerEn,
    required this.answerAr,
  });

  factory _FaqItem.fromMap(Map<String, dynamic> map) {
    return _FaqItem(
      questionEn: map['questionEn'] as String? ?? '',
      questionAr: map['questionAr'] as String? ?? '',
      answerEn: map['answerEn'] as String? ?? '',
      answerAr: map['answerAr'] as String? ?? '',
    );
  }
}

enum _LanguageMode { english, arabic }
