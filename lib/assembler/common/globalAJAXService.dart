import 'package:dio/dio.dart';

import '.env.dart';

final Dio dio = Dio()
  ..interceptors.add(
    LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
    ),
  );

Future<T> sendHttpRequest<T>(String url, {Map<String, dynamic>? param , required T Function(dynamic json) fromJson}) async {
  Response response;
  response = await dio.get("${ENV.apiBaseUrl}${url}", queryParameters: param);

  return fromJson(response.data);

}

Future<T> sendHttpPostRequest<T>(String url,
    {Map<String, dynamic>? body, required T Function(dynamic json) fromJson}) async {
  Response response;
  response = await dio.post("${ENV.apiBaseUrl}${url}", data: body);

  return fromJson(response.data);
}
