import 'package:voxtrade_core/Components/ModelDto/WalletHistoryDTO.dart';
import 'package:voxtrade_core/assembler/common/globalAJAXService.dart';

Future<List<WalletHistoryDto>> getWalletHistory(int userId) {
  return sendHttpRequest<List<WalletHistoryDto>>(
    "/api/History/GetWalletHistory",
    param: {'userId': userId},
    fromJson: (json) {
      final list = json as List;
      return list.map((e) => WalletHistoryDto.fromJson(e)).toList();
    },
  );
}
