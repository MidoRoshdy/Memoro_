import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/string_assets.dart';
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
    final answer = isArabic ? item.answerAr : item.answerEn;

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
