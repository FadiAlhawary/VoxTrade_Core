import 'package:dio/dio.dart';
import 'package:voxtrade_core/assembler/Services/voice_recorder.dart';
import 'package:voxtrade_core/assembler/common/.env.dart';

class VoiceNlpService {
  VoiceNlpService()
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 40),
        ),
      );

  final Dio _dio;

  static const String _voiceCommandPath = '/voice-command';

  Future<Map<String, dynamic>> processVoiceCommand({
    required RecordedAudio audio,
    String sttModel = 'gpt-4o-transcribe',
  }) async {
    final filename = 'audio.${audio.extension}';

    final payload = FormData.fromMap({
      'file': MultipartFile.fromBytes(audio.bytes, filename: filename),
      'stt_model': sttModel,
    });

    try {
      final response = await _dio.post(
        '${ENV.voiceApiBaseUrl}$_voiceCommandPath',
        data: payload,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }

      throw StateError('Voice service returned an unexpected response format.');
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      final responseBody = error.response?.data;
      final bodyMessage =
          responseBody is Map ? responseBody['detail']?.toString() : null;

      throw Exception(
        bodyMessage ??
            'Voice service request failed${statusCode != null ? ' (status $statusCode)' : ''}.',
      );
    }
  }
}
