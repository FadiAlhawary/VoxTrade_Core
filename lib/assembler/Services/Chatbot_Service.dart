import 'package:dio/dio.dart';
import 'package:voxtrade_core/assembler/Models/chat_message.dart';
import 'package:voxtrade_core/assembler/common/.env.dart';

class ChatbotService {
  ChatbotService()
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 60),
          headers: {'Content-Type': 'application/json'},
        ),
      );

  final Dio _dio;

  static const String _chatPath = '/chat';

  Future<ChatbotReply> sendChat({
    required List<ChatMessage> messages,
    Map<String, double>? marketContext,
  }) async {
    final payload = {
      'messages': messages
          .map((m) => {'role': m.role, 'content': m.content})
          .toList(),
      if (marketContext != null && marketContext.isNotEmpty)
        'market_context': marketContext,
    };

    try {
      final response = await _dio.post(
        '${ENV.voiceApiBaseUrl}$_chatPath',
        data: payload,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return ChatbotReply.fromJson(data);
      }
      if (data is Map) {
        return ChatbotReply.fromJson(Map<String, dynamic>.from(data));
      }

      throw StateError('Chat service returned an unexpected response format.');
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      final responseBody = error.response?.data;
      final bodyMessage =
          responseBody is Map ? responseBody['detail']?.toString() : null;

      throw Exception(
        bodyMessage ??
            'Chat service request failed${statusCode != null ? ' (status $statusCode)' : ''}.',
      );
    }
  }
}
