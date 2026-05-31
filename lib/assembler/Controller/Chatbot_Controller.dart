import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:localstorage/localstorage.dart';
import 'package:voxtrade_core/assembler/Models/chat_message.dart';
import 'package:voxtrade_core/assembler/Services/Chatbot_Service.dart';

class ChatbotController extends GetxController {
  ChatbotController({ChatbotService? service})
    : _service = service ?? ChatbotService();

  static const String storageKey = 'vt_vox_history';
  static const String botVoiceStorageKey = 'vt_bot_voice';
  static const int maxStoredMessages = 60;

  static const List<String> quickQuestions = [
    'How do I use Voice Trade?',
    'How do I deposit funds?',
    'Where can I see my orders?',
    'What markets are available?',
    'How do I check my portfolio?',
  ];

  /// Options shown when the API returns none — keeps chips visible always.
  List<String> get pickableOptions {
    if (suggestions.isNotEmpty) {
      return suggestions.toList();
    }
    return quickQuestions;
  }

  final ChatbotService _service;
  final TextEditingController inputController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxList<String> suggestions = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxString inputText = ''.obs;

  String get botName {
    final voice = localStorage.getItem(botVoiceStorageKey);
    return voice == 'male' ? 'Vox' : 'Voxy';
  }

  @override
  void onInit() {
    super.onInit();
    inputController.addListener(() => inputText.value = inputController.text);
    _loadHistory();
  }

  @override
  void onClose() {
    inputController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  ChatMessage _initialMessage() {
    return ChatMessage(
      role: 'model',
      content:
          "Hi! I'm $botName, your VoxTrade assistant. I can help you navigate the platform, look up stock prices, and find market news. What would you like to know?",
    );
  }

  void _loadHistory() {
    try {
      final saved = localStorage.getItem(storageKey);
      if (saved != null && saved.isNotEmpty) {
        final decoded = jsonDecode(saved);
        if (decoded is List && decoded.isNotEmpty) {
          messages.assignAll(
            decoded
                .whereType<Map>()
                .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
                .where((m) => m.content.isNotEmpty)
                .toList(),
          );
          if (messages.isNotEmpty) {
            return;
          }
        }
      }
    } catch (_) {}
    messages.assignAll([_initialMessage()]);
  }

  void _persistHistory() {
    try {
      final slim = messages
          .takeLast(maxStoredMessages)
          .map((m) => m.toJson())
          .toList();
      localStorage.setItem(storageKey, jsonEncode(slim));
    } catch (_) {}
  }

  void clearConversation() {
    suggestions.clear();
    messages.assignAll([_initialMessage()]);
    localStorage.removeItem(storageKey);
    inputController.clear();
  }

  Future<void> sendMessage([String? overrideText]) async {
    final text = (overrideText ?? inputController.text).trim();
    if (text.isEmpty || isLoading.value) {
      return;
    }

    final userMessage = ChatMessage(role: 'user', content: text);
    final historyForApi = [...messages, userMessage];

    messages.add(userMessage);
    inputController.clear();
    suggestions.clear();
    isLoading.value = true;
    _scrollToBottom();

    try {
      final reply = await _service.sendChat(messages: historyForApi);
      messages.add(ChatMessage(role: 'model', content: reply.reply));
      suggestions.assignAll(reply.suggestions);
    } catch (_) {
      messages.add(
        const ChatMessage(
          role: 'model',
          content:
              "Sorry, I'm having trouble connecting right now. Please try again in a moment.",
        ),
      );
      suggestions.assignAll(quickQuestions);
    } finally {
      isLoading.value = false;
      _persistHistory();
      _scrollToBottom();
    }
  }

  void applySuggestion(String text) {
    inputController.text = text;
    inputController.selection = TextSelection.collapsed(offset: text.length);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) {
        return;
      }
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }
}

extension _TakeLast<T> on List<T> {
  Iterable<T> takeLast(int count) {
    if (length <= count) {
      return this;
    }
    return sublist(length - count);
  }
}
