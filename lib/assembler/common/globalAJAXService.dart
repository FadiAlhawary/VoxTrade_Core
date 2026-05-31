import 'package:dio/dio.dart';

import '.env.dart';
import 'package:voxtrade_core/utils/http_error_message.dart';
import 'package:voxtrade_core/utils/service_debug_logger.dart';

final Dio dio =
    Dio()
      ..interceptors.add(ServiceDioDebugInterceptor(tag: 'VoxTrade API'));

Future<T> sendHttpRequest<T>(
  String url, {
  Map<String, dynamic>? param,
  required T Function(dynamic json) fromJson,
  String? method = "GET",
}) async {
  return runHttpRequest(
    () async {
      final Response response;
      if (method == "GET") {
        response = await dio.get("${ENV.apiBaseUrl}$url", queryParameters: param);
      } else if (method == "POST") {
        response = await dio.post("${ENV.apiBaseUrl}$url", data: param);
      } else if (method == "PUT") {
        response = await dio.put("${ENV.apiBaseUrl}$url", queryParameters: param);
      } else if (method == "DELETE") {
        response = await dio.delete("${ENV.apiBaseUrl}$url", data: param);
      } else {
        throw Exception("Invalid method");
      }
      return fromJson(response.data);
    },
    debugLabel: url,
  );
}

Future<T> sendHttpPostRequest<T>(
  String url, {
  Map<String, dynamic>? body,
  Map<String, dynamic>? queryParameters,
  required T Function(dynamic json) fromJson,
}) async {
  return runHttpRequest(
    () async {
      final response = await dio.post(
        "${ENV.apiBaseUrl}$url",
        data: body,
        queryParameters: queryParameters,
      );
      return fromJson(response.data);
    },
    debugLabel: url,
  );
}

Future<T> sendHttpPutRequest<T>(
  String url, {
  Map<String, dynamic>? body,
  Map<String, dynamic>? queryParameters,
  required T Function(dynamic json) fromJson,
}) async {
  return runHttpRequest(
    () async {
      final response = await dio.put(
        "${ENV.apiBaseUrl}$url",
        queryParameters: queryParameters,
        data: body,
      );
      return fromJson(response.data);
    },
    debugLabel: url,
  );
}

Future<T> sendHttpDeleteRequest<T>(
  String url, {
  Map<String, dynamic>? queryParameters,
  required T Function(dynamic json) fromJson,
}) async {
  return runHttpRequest(
    () async {
      final response = await dio.delete(
        "${ENV.apiBaseUrl}$url",
        queryParameters: queryParameters,
      );
      return fromJson(response.data);
    },
    debugLabel: url,
  );
}
