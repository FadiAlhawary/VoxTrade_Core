import 'package:dio/dio.dart';

import '.env.dart';

final dio = Dio();

Future<T> sendHttpRequest<T>(String url, {Map<String, dynamic>? param , required T Function(dynamic json) fromJson}) async {
  Response response;
  response = await dio.get("${ENV.apiBaseUrl}${url}", queryParameters: param);

  return fromJson(response.data);

}
