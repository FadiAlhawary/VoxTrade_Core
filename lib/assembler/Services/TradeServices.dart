import 'package:voxtrade_core/Components/ModelDto/TradeHistoryDTO.dart';
import 'package:voxtrade_core/assembler/common/globalAJAXService.dart';

Future<List<TradeHistory>> getTradeHistory(int userId) {
  return sendHttpRequest<List<TradeHistory>>(
    "/api/History/GetTradeHistory",
    param: {'userId': userId},
    fromJson: (json) {
      final list = json as List<dynamic>;
      return list
          .map((e) => TradeHistory.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    },
  );
}
