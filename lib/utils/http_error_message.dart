import 'package:dio/dio.dart';
import 'package:voxtrade_core/utils/api_request_gate.dart';
import 'package:voxtrade_core/utils/service_debug_logger.dart';

/// User-facing text for failed API calls (avoids dumping [DioException] details).
String friendlyErrorMessage(Object error) {
  if (error is HttpRequestException) {
    return _sanitizeServerMessage(error.message);
  }
  if (error is DioException) {
    return _sanitizeServerMessage(_fromDio(error));
  }
  final text = error.toString();
  if (text.startsWith('Exception: ')) {
    return _sanitizeServerMessage(text.substring('Exception: '.length));
  }
  return _sanitizeServerMessage(text);
}

String _sanitizeServerMessage(String message) {
  final trimmed = message.trim();
  if (trimmed.isEmpty) return 'Something went wrong. Please try again.';

  final lower = trimmed.toLowerCase();
  if (lower.contains('emaxconnsession') ||
      lower.contains('max clients reached') ||
      lower.contains('pool_size')) {
    return 'Server is busy. Please wait a moment and try again.';
  }
  if (trimmed.contains('Npgsql.') ||
      trimmed.contains('PostgresException') ||
      trimmed.contains('StackTrace') ||
      trimmed.contains(' at ')) {
    return 'Server error. Please try again in a moment.';
  }
  return trimmed;
}

String _fromDio(DioException error) {
  final body = error.response?.data;
  if (body is Map) {
    for (final key in ['message', 'Message', 'error', 'title']) {
      final value = body[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
  }
  if (body is String && body.trim().isNotEmpty) {
    return body.trim();
  }

  final status = error.response?.statusCode;
  switch (status) {
    case 400:
      return 'Invalid request. Please check your input and try again.';
    case 401:
      return 'Session expired. Please sign in again.';
    case 403:
      return 'You do not have permission to perform this action.';
    case 404:
      return 'The requested data was not found.';
    case 500:
    case 502:
    case 503:
      return 'Server error. Please try again in a moment.';
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Request timed out. Check your connection and try again.';
    case DioExceptionType.connectionError:
      return 'Cannot reach the server. Check your network connection.';
    case DioExceptionType.cancel:
      return 'Request was cancelled.';
    default:
      break;
  }

  return 'Something went wrong. Please try again.';
}

/// Thrown by [sendHttpRequest] helpers instead of raw [DioException].
class HttpRequestException implements Exception {
  HttpRequestException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

Never _throwFromDio(DioException error, {String? debugLabel}) {
  final message = _fromDio(error);
  final path =
      debugLabel ??
      error.requestOptions.uri.path +
          (error.requestOptions.uri.hasQuery
              ? '?${error.requestOptions.uri.query}'
              : '');
  ServiceDebugLogger.error(
    tag: 'VoxTrade API',
    message: message,
    method: error.requestOptions.method,
    url: path,
    statusCode: error.response?.statusCode,
    responseData: error.response?.data,
    detail: error.type.name,
  );
  throw HttpRequestException(
    message,
    statusCode: error.response?.statusCode,
  );
}

/// Wraps a Dio call and maps failures to [HttpRequestException].
Future<T> runHttpRequest<T>(
  Future<T> Function() request, {
  String? debugLabel,
}) async {
  return ApiRequestGate.run(() async {
    try {
      return await request();
    } on DioException catch (e) {
      _throwFromDio(e, debugLabel: debugLabel);
    } catch (e, st) {
      ServiceDebugLogger.error(
        tag: 'VoxTrade API',
        message: e.toString(),
        detail: debugLabel ?? st.toString(),
      );
      rethrow;
    }
  });
}
