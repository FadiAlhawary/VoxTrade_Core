import 'package:voxtrade_core/Components/ModelDto/DashboardDtos.dart';
import 'package:voxtrade_core/Components/ModelDto/PortfolioPositionDto.dart';
import 'package:voxtrade_core/assembler/common/globalAJAXService.dart';

const _base = '/api/dashboard';

T _mapJson<T>(dynamic json, T Function(Map<String, dynamic>) fromJson) {
  return fromJson(Map<String, dynamic>.from(json as Map));
}

Future<UserDashboardSummaryDto> getDashboardSummary(
  int userId, {
  int recentLimit = 10,
}) {
  return sendHttpRequest<UserDashboardSummaryDto>(
    '$_base/$userId',
    param: {'recentLimit': recentLimit},
    fromJson: (json) => _mapJson(json, UserDashboardSummaryDto.fromJson),
  );
}

Future<DashboardWalletDto> getDashboardWallet(int userId) {
  return sendHttpRequest<DashboardWalletDto>(
    '$_base/$userId/wallet',
    fromJson: (json) => _mapJson(json, DashboardWalletDto.fromJson),
  );
}

Future<DashboardOrdersSummaryDto> getDashboardOrdersSummary(int userId) {
  return sendHttpRequest<DashboardOrdersSummaryDto>(
    '$_base/$userId/orders/summary',
    fromJson: (json) => _mapJson(json, DashboardOrdersSummaryDto.fromJson),
  );
}

Future<List<PortfolioPositionDto>> getDashboardPositions(int userId) {
  return sendHttpRequest<List<PortfolioPositionDto>>(
    '$_base/$userId/positions',
    fromJson: (json) => parseDashboardPositions(json),
  );
}

Future<List<DashboardActivityItemDto>> getDashboardRecentActivity(
  int userId, {
  int limit = 20,
}) {
  return sendHttpRequest<List<DashboardActivityItemDto>>(
    '$_base/$userId/recent-activity',
    param: {'limit': limit},
    fromJson: (json) {
      if (json is List) {
        return json
            .whereType<Map>()
            .map(
              (e) => DashboardActivityItemDto.fromJson(
                Map<String, dynamic>.from(e),
              ),
            )
            .toList();
      }
      return [];
    },
  );
}

Future<List<DashboardMarketSnapshotItemDto>> getDashboardMarketSnapshot({
  int limit = 20,
}) {
  return sendHttpRequest<List<DashboardMarketSnapshotItemDto>>(
    '$_base/market-snapshot',
    param: {'limit': limit},
    fromJson: (json) => parseMarketSnapshot(json),
  );
}

Future<List<DashboardTransferRecipientDto>> searchDashboardTransferRecipients({
  required String query,
  required int excludeUserId,
  int limit = 20,
}) {
  return sendHttpRequest<List<DashboardTransferRecipientDto>>(
    '$_base/transfer-recipients/search',
    param: {
      'query': query,
      'excludeUserId': excludeUserId,
      'limit': limit,
    },
    fromJson: (json) => parseTransferRecipients(json),
  );
}
