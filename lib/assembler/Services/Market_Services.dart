import 'package:voxtrade_core/Components/ModelDto/PlaceOrderRequestDTO.dart';
import 'package:voxtrade_core/Components/ModelDto/PlaceOrderResponseDTO.dart';
import 'package:voxtrade_core/assembler/common/globalAJAXService.dart';

Future<List<PlaceOrderResponseDTO>> placeOrder(PlaceOrderRequestDTO request) {
  return sendHttpPostRequest<List<PlaceOrderResponseDTO>>(
    "/api/Market/PlaceOrder",
    body: request.toJson(),
    fromJson: (json) {
      if (json is List) {
        return json
            .map((e) => PlaceOrderResponseDTO.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (json is Map<String, dynamic>) {
        return [PlaceOrderResponseDTO.fromJson(json)];
      }
      throw Exception('Unexpected PlaceOrder response type: ${json.runtimeType}');
    },
  );
}
