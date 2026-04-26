import 'package:voxtrade_core/Components/ModelDto/AuthResponseDTO.dart';
import 'package:voxtrade_core/Components/ModelDto/CancelOrderResponseDTO.dart';
import 'package:voxtrade_core/Components/ModelDto/Endpointresponse.dart';
import 'package:voxtrade_core/Components/ModelDto/LookupItemDto.dart';
import 'package:voxtrade_core/Components/ModelDto/OrderHistoryDTO.dart';
import 'package:voxtrade_core/assembler/common/globalAJAXService.dart';

Future<List<OrderHistory>> getTradeHistory(int userId, bool activeOnly) {
  return sendHttpRequest<List<OrderHistory>>(
    "/api/History/GetOrderHistory",
    param: {'userId': userId, 'activeOnly': activeOnly},
    fromJson: (json) {
      final list = json as List<dynamic>;
      return list
          .map(
            (e) => OrderHistory.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    },
  );
}

/// Backend should return `{ "success": bool, "message": string, ... }` (same shape as login).
Future<CancelOrderResponseDTO> cancelOrder(int orderId, int userId) {
  return sendHttpRequest<CancelOrderResponseDTO>(
    "/api/History/CancelOrder",
    param: {'orderId': orderId, 'userId': userId},
    fromJson:
        (json) => CancelOrderResponseDTO.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
    method: "PUT",
  );
}

Future<List<LookupItemDto>> getOrderStatuses() {
  return sendHttpRequest<List<LookupItemDto>>(
    "/api/History/GetOrderStatuses",
    fromJson: (json) {
      final list = json as List;
      return list.map((e) => LookupItemDto.fromJson(e)).toList();
    },
  );
}

Future<List<LookupItemDto>> getOrderTypes() {
  return sendHttpRequest<List<LookupItemDto>>(
    "/api/History/GetOrderTypes",
    fromJson: (json) {
      final list = json as List;
      return list.map((e) => LookupItemDto.fromJson(e)).toList();
    },
  );
}

Future<List<LookupItemDto>> getOrderActions() {
  return sendHttpRequest<List<LookupItemDto>>(
    "/api/History/GetOrderActions",
    fromJson: (json) {
      final list = json as List;
      return list.map((e) => LookupItemDto.fromJson(e)).toList();
    },
  );
}
