import 'package:voxtrade_core/Components/ModelDto/PaymentMethodDtos.dart';
import 'package:voxtrade_core/assembler/common/globalAJAXService.dart';

Future<List<PaymentMethodTypeDto>> getPaymentMethodTypes() {
  return sendHttpRequest<List<PaymentMethodTypeDto>>(
    '/api/payment-methods/types',
    fromJson:
        (json) => parseDtoList(
          json,
          (item) => PaymentMethodTypeDto.fromJson(item),
        ),
  );
}

Future<List<UserPaymentMethodDto>> getUserPaymentMethods(int userId) {
  return sendHttpRequest<List<UserPaymentMethodDto>>(
    '/api/payment-methods/users/$userId',
    fromJson:
        (json) => parseDtoList(
          json,
          (item) => UserPaymentMethodDto.fromJson(item),
        ),
  );
}

Future<UserPaymentMethodDto> getUserPaymentMethod(
  int userId,
  int userPaymentMethodId,
) {
  return sendHttpRequest<UserPaymentMethodDto>(
    '/api/payment-methods/users/$userId/$userPaymentMethodId',
    fromJson: (json) {
      if (json is Map<String, dynamic>) {
        return UserPaymentMethodDto.fromJson(json);
      }
      throw Exception('Invalid payment method response');
    },
  );
}

Future<AddPaymentMethodResponseDto> addUserPaymentMethod(
  int userId,
  AddPaymentMethodRequestDto request,
) {
  return sendHttpPostRequest<AddPaymentMethodResponseDto>(
    '/api/payment-methods/users/$userId',
    body: request.toJson(),
    fromJson:
        (json) =>
            AddPaymentMethodResponseDto.fromJson(json as Map<String, dynamic>),
  );
}

Future<AddPaymentMethodResponseDto> updateUserPaymentMethod(
  int userId,
  int userPaymentMethodId,
  AddPaymentMethodRequestDto request,
) {
  return sendHttpPutRequest<AddPaymentMethodResponseDto>(
    '/api/payment-methods/users/$userId/$userPaymentMethodId',
    body: request.toJson(),
    fromJson:
        (json) =>
            AddPaymentMethodResponseDto.fromJson(json as Map<String, dynamic>),
  );
}

Future<Map<String, dynamic>> deleteUserPaymentMethod(
  int userId,
  int userPaymentMethodId,
) {
  return sendHttpDeleteRequest<Map<String, dynamic>>(
    '/api/payment-methods/users/$userId/$userPaymentMethodId',
    fromJson: (json) {
      if (json is Map<String, dynamic>) return json;
      return {'success': true};
    },
  );
}
