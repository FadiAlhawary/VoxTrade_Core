import 'package:voxtrade_core/Components/ModelDto/WalletDTO.dart';
import 'package:voxtrade_core/Components/ModelDto/WalletHistoryDTO.dart';
import 'package:voxtrade_core/assembler/common/globalAJAXService.dart';

Future<List<WalletHistoryDto>> getWalletHistory(int userId) {
  return sendHttpRequest<List<WalletHistoryDto>>(
    "/api/History/GetWalletHistory",
    param: {'userId': userId},
    fromJson: (json) {
      return _parseWalletHistoryResponse(json);
    },
  );
}

Future<WalletDto> getWallet(int userId, bool withHistory) {
  return sendHttpRequest<WalletDto>(
    "/api/Wallet/GetWallet",
    param: {'userId': userId, 'WithHisory': withHistory},
    fromJson: (json) {
      return WalletDto.fromJson(json);
    },
  );
}

Future<List<WalletHistoryDto>> getWalletHistoryWithDate(
  int userId,
  DateTime from,
  DateTime to,
) {
  return sendHttpRequest<List<WalletHistoryDto>>(
    "/api/History/GetWalletHistoryWithDate",
    param: {'userId': userId, 'from': from, 'to': to},
    fromJson: (json) {
      return _parseWalletHistoryResponse(json);
    },
  );
}

List<WalletHistoryDto> _parseWalletHistoryResponse(dynamic json) {
  if (json is List) {
    return json
        .whereType<Map>()
        .map((e) => WalletHistoryDto.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  if (json is Map<String, dynamic>) {
    final nestedHistory = json['walletHistory'];
    if (nestedHistory is List) {
      return nestedHistory
          .whereType<Map>()
          .map((e) => WalletHistoryDto.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
  }

  return [];
}
