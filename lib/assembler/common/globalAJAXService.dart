import 'package:dio/dio.dart';

import '.env.dart';

final Dio dio =
    Dio()
      ..interceptors.add(
        LogInterceptor(
          request: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
        ),
      );

Future<T> sendHttpRequest<T>(
  String url, {
  Map<String, dynamic>? param,
  required T Function(dynamic json) fromJson,
  String? method = "GET",
}) async {
  Response response;
  if (method == "GET") {
    response = await dio.get("${ENV.apiBaseUrl}${url}", queryParameters: param);
  } else if (method == "POST") {
    response = await dio.post("${ENV.apiBaseUrl}${url}", data: param);
  }
  else if (method == "PUT") {
    response = await dio.put("${ENV.apiBaseUrl}${url}", data: param);
  }
  else if (method == "DELETE") {
    response = await dio.delete("${ENV.apiBaseUrl}${url}", data: param);
  }
   else {
    throw Exception("Invalid method");
  }

  return fromJson(response.data);
}

Future<T> sendHttpPostRequest<T>(
  String url, {
  Map<String, dynamic>? body,
  required T Function(dynamic json) fromJson,
}) async {
  Response response;
  response = await dio.post("${ENV.apiBaseUrl}${url}", data: body);

  return fromJson(response.data);
}
