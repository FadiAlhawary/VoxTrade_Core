import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Colored debug output for API/service calls (debug builds only).
abstract final class ServiceDebugLogger {
  static const _reset = '\x1B[0m';
  static const _red = '\x1B[31m';
  static const _green = '\x1B[32m';
  static const _yellow = '\x1B[33m';
  static const _cyan = '\x1B[36m';
  static const _bold = '\x1B[1m';

  static const int _maxBodyLength = 800;

  static bool get _useAnsi {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  static String _fmt(String plain, {String? color, bool bold = false}) {
    if (!_useAnsi || color == null) return plain;
    return '$color${bold ? _bold : ''}$plain$_reset';
  }

  static void request({
    required String tag,
    required String method,
    required String url,
    Object? query,
    Object? body,
  }) {
    if (!kDebugMode) return;
    final lines = <String>[
      _fmt('[REQ] [$tag] $method $url', color: _cyan),
    ];
    if (query != null && '$query'.isNotEmpty) {
      lines.add(_fmt('  query: ${_truncate(query)}', color: _cyan));
    }
    if (body != null && '$body'.isNotEmpty) {
      lines.add(_fmt('  body: ${_truncate(body)}', color: _cyan));
    }
    _printBlock(lines);
  }

  static void response({
    required String tag,
    required String method,
    required String url,
    required int? statusCode,
    Object? data,
  }) {
    if (!kDebugMode) return;
    final status = statusCode ?? 0;
    _printBlock([
      _fmt('[OK] [$tag] $method $url → $status', color: _green),
      if (data != null) _fmt('  data: ${_truncate(data)}', color: _green),
    ]);
  }

  static void error({
    required String tag,
    required String message,
    String? method,
    String? url,
    int? statusCode,
    Object? responseData,
    Object? detail,
  }) {
    if (!kDebugMode) return;
    final lines = <String>[
      _fmt('[ERROR] [$tag] SERVICE ERROR', color: _red, bold: true),
      _fmt('  message: $message', color: _red),
    ];
    if (method != null && url != null) {
      lines.add(_fmt('  request: $method $url', color: _red));
    } else if (url != null) {
      lines.add(_fmt('  request: $url', color: _red));
    }
    if (statusCode != null) {
      lines.add(_fmt('  status: $statusCode', color: _red));
    }
    if (responseData != null) {
      lines.add(_fmt('  response: ${_truncate(responseData)}', color: _red));
    }
    if (detail != null && '$detail'.isNotEmpty) {
      lines.add(_fmt('  detail: ${_truncate(detail)}', color: _red));
    }
    _printBlock(lines);
  }

  static void warn({
    required String tag,
    required String message,
    Object? detail,
  }) {
    if (!kDebugMode) return;
    final lines = <String>[
      _fmt('[WARN] [$tag] $message', color: _yellow),
    ];
    if (detail != null) {
      lines.add(_fmt('  detail: ${_truncate(detail)}', color: _yellow));
    }
    _printBlock(lines);
  }

  static void logDioException({
    required String tag,
    required DioException exception,
  }) {
    ServiceDebugLogger.error(
      tag: tag,
      message: exception.message ?? exception.type.name,
      method: exception.requestOptions.method,
      url: exception.requestOptions.uri.toString(),
      statusCode: exception.response?.statusCode,
      responseData: exception.response?.data,
      detail: exception.type.name,
    );
  }

  static String _truncate(Object value) {
    final text = value.toString();
    if (text.length <= _maxBodyLength) return text;
    return '${text.substring(0, _maxBodyLength)}…';
  }

  static void _printBlock(List<String> lines) {
    for (final line in lines) {
      debugPrint(line);
    }
  }
}

/// Attach to any [Dio] instance for request/response/error debug logs.
class ServiceDioDebugInterceptor extends Interceptor {
  ServiceDioDebugInterceptor({this.tag = 'Service'});

  final String tag;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    ServiceDebugLogger.request(
      tag: tag,
      method: options.method,
      url: options.uri.toString(),
      query:
          options.queryParameters.isEmpty ? null : options.queryParameters,
      body: options.data,
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    ServiceDebugLogger.response(
      tag: tag,
      method: response.requestOptions.method,
      url: response.requestOptions.uri.toString(),
      statusCode: response.statusCode,
      data: response.data,
    );
    super.onResponse(response, handler);
  }
}

void attachServiceDebugLogging(Dio dio, {String tag = 'Service'}) {
  if (!kDebugMode) return;
  dio.interceptors.add(ServiceDioDebugInterceptor(tag: tag));
}
