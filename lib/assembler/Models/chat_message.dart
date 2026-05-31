class ChatMessage {
  const ChatMessage({required this.role, required this.content});

  final String role;
  final String content;

  bool get isUser => role == 'user';
  bool get isModel => role == 'model';

  Map<String, dynamic> toJson() => {'role': role, 'content': content};

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role']?.toString() ?? 'model',
      content: json['content']?.toString() ?? '',
    );
  }
}

class ChatbotReply {
  const ChatbotReply({required this.reply, this.suggestions = const []});

  final String reply;
  final List<String> suggestions;

  factory ChatbotReply.fromJson(Map<String, dynamic> json) {
    final rawSuggestions = json['suggestions'];
    return ChatbotReply(
      reply: json['reply']?.toString() ?? '',
      suggestions:
          rawSuggestions is List
              ? rawSuggestions.map((e) => e.toString()).toList()
              : const [],
    );
  }
}
