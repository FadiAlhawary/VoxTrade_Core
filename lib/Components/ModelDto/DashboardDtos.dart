import 'package:voxtrade_core/Components/ModelDto/PortfolioPositionDto.dart';

class UserDashboardSummaryDto {
  final int userId;
  final String username;
  final String firstNameEn;
  final String lastNameEn;
  final bool isLocked;
  final bool isDeleted;
  final DashboardWalletDto wallet;
  final DashboardOrdersSummaryDto orders;
  final DashboardPositionsSummaryDto positions;
  final double totalPortfolioValue;
  final int totalTrades;
  final int tradesLast7Days;
  final List<DashboardActivityItemDto> recentActivity;

  UserDashboardSummaryDto({
    required this.userId,
    required this.username,
    required this.firstNameEn,
    required this.lastNameEn,
    required this.isLocked,
    required this.isDeleted,
    required this.wallet,
    required this.orders,
    required this.positions,
    required this.totalPortfolioValue,
    required this.totalTrades,
    required this.tradesLast7Days,
    required this.recentActivity,
  });

  factory UserDashboardSummaryDto.fromJson(Map<String, dynamic> json) {
    return UserDashboardSummaryDto(
      userId: json['userId'] as int? ?? 0,
      username: json['username']?.toString() ?? '',
      firstNameEn: json['firstNameEn']?.toString() ?? '',
      lastNameEn: json['lastNameEn']?.toString() ?? '',
      isLocked: json['isLocked'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      wallet: DashboardWalletDto.fromJson(
        Map<String, dynamic>.from(json['wallet'] as Map? ?? {}),
      ),
      orders: DashboardOrdersSummaryDto.fromJson(
        Map<String, dynamic>.from(json['orders'] as Map? ?? {}),
      ),
      positions: DashboardPositionsSummaryDto.fromJson(
        Map<String, dynamic>.from(json['positions'] as Map? ?? {}),
      ),
      totalPortfolioValue:
          (json['totalPortfolioValue'] as num?)?.toDouble() ?? 0.0,
      totalTrades: json['totalTrades'] as int? ?? 0,
      tradesLast7Days: json['tradesLast7Days'] as int? ?? 0,
      recentActivity: _parseActivityList(json['recentActivity']),
    );
  }
}

class DashboardWalletDto {
  final int walletId;
  final double balance;
  final double availableBalance;
  final double reservedBalance;
  final bool status;
  final bool isFrozen;
  final String currencySymbol;

  DashboardWalletDto({
    required this.walletId,
    required this.balance,
    required this.availableBalance,
    required this.reservedBalance,
    required this.status,
    required this.isFrozen,
    required this.currencySymbol,
  });

  factory DashboardWalletDto.fromJson(Map<String, dynamic> json) {
    return DashboardWalletDto(
      walletId: json['walletId'] as int? ?? json['id'] as int? ?? 0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0.0,
      reservedBalance: (json['reservedBalance'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as bool? ?? true,
      isFrozen: json['isFrozen'] as bool? ?? !(json['status'] as bool? ?? true),
      currencySymbol: json['currencySymbol']?.toString() ?? 'USD',
    );
  }
}

class DashboardOrdersSummaryDto {
  final int total;
  final int pending;
  final int partiallyFilled;
  final int filled;
  final int cancelled;
  final int active;

  DashboardOrdersSummaryDto({
    required this.total,
    required this.pending,
    required this.partiallyFilled,
    required this.filled,
    required this.cancelled,
    required this.active,
  });

  factory DashboardOrdersSummaryDto.fromJson(Map<String, dynamic> json) {
    return DashboardOrdersSummaryDto(
      total: json['total'] as int? ?? 0,
      pending: json['pending'] as int? ?? 0,
      partiallyFilled: json['partiallyFilled'] as int? ?? 0,
      filled: json['filled'] as int? ?? 0,
      cancelled: json['cancelled'] as int? ?? 0,
      active: json['active'] as int? ?? 0,
    );
  }
}

class DashboardPositionsSummaryDto {
  final int positionCount;
  final double totalMarketValue;
  final double totalUnrealizedPnl;
  final double totalRealizedPnl;

  DashboardPositionsSummaryDto({
    required this.positionCount,
    required this.totalMarketValue,
    required this.totalUnrealizedPnl,
    required this.totalRealizedPnl,
  });

  factory DashboardPositionsSummaryDto.fromJson(Map<String, dynamic> json) {
    return DashboardPositionsSummaryDto(
      positionCount: json['positionCount'] as int? ?? 0,
      totalMarketValue: (json['totalMarketValue'] as num?)?.toDouble() ?? 0.0,
      totalUnrealizedPnl:
          (json['totalUnrealizedPnl'] as num?)?.toDouble() ?? 0.0,
      totalRealizedPnl: (json['totalRealizedPnl'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DashboardActivityItemDto {
  final String activityType;
  final int id;
  final String title;
  final String subtitle;
  final double? amount;
  final String? status;
  final DateTime createdAt;

  DashboardActivityItemDto({
    required this.activityType,
    required this.id,
    required this.title,
    required this.subtitle,
    this.amount,
    this.status,
    required this.createdAt,
  });

  factory DashboardActivityItemDto.fromJson(Map<String, dynamic> json) {
    return DashboardActivityItemDto(
      activityType: json['activityType']?.toString() ?? '',
      id: json['id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble(),
      status: json['status']?.toString(),
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'].toString())
              : DateTime.now(),
    );
  }
}

class DashboardMarketSnapshotItemDto {
  final int instrumentId;
  final String symbol;
  final String instrumentName;
  final String shortName;
  final double? bidPrice;
  final double? askPrice;
  final double? lastTradePrice;
  final DateTime? quoteUpdatedAt;

  DashboardMarketSnapshotItemDto({
    required this.instrumentId,
    required this.symbol,
    required this.instrumentName,
    required this.shortName,
    this.bidPrice,
    this.askPrice,
    this.lastTradePrice,
    this.quoteUpdatedAt,
  });

  factory DashboardMarketSnapshotItemDto.fromJson(Map<String, dynamic> json) {
    return DashboardMarketSnapshotItemDto(
      instrumentId: json['instrumentId'] as int? ?? json['id'] as int? ?? 0,
      symbol: json['symbol']?.toString() ?? '',
      instrumentName:
          json['instrumentName']?.toString() ?? json['name']?.toString() ?? '',
      shortName:
          (json['shortName'] ?? json['short_name'] ?? json['symbol'] ?? '')
              .toString(),
      bidPrice: (json['bidPrice'] as num?)?.toDouble(),
      askPrice: (json['askPrice'] as num?)?.toDouble(),
      lastTradePrice: (json['lastTradePrice'] as num?)?.toDouble(),
      quoteUpdatedAt:
          json['quoteUpdatedAt'] != null
              ? DateTime.tryParse(json['quoteUpdatedAt'].toString())
              : null,
    );
  }
}

class DashboardTransferRecipientDto {
  final int id;
  final int walletId;
  final String username;
  final String firstNameEn;
  final String lastNameEn;
  final String displayName;

  DashboardTransferRecipientDto({
    required this.id,
    required this.walletId,
    required this.username,
    required this.firstNameEn,
    required this.lastNameEn,
    required this.displayName,
  });

  factory DashboardTransferRecipientDto.fromJson(Map<String, dynamic> json) {
    final first = json['firstNameEn']?.toString() ?? '';
    final last = json['lastNameEn']?.toString() ?? '';
    final name = '${first.trim()} ${last.trim()}'.trim();
    return DashboardTransferRecipientDto(
      id: json['userId'] as int? ?? json['id'] as int? ?? 0,
      walletId: json['walletId'] as int? ?? 0,
      username: json['username']?.toString() ?? '',
      firstNameEn: first,
      lastNameEn: last,
      displayName:
          json['displayName']?.toString() ??
          (name.isNotEmpty ? name : json['username']?.toString() ?? ''),
    );
  }
}

List<DashboardActivityItemDto> _parseActivityList(dynamic json) {
  if (json is! List) return [];
  return json
      .whereType<Map>()
      .map(
        (e) => DashboardActivityItemDto.fromJson(Map<String, dynamic>.from(e)),
      )
      .toList();
}

List<PortfolioPositionDto> parseDashboardPositions(dynamic json) {
  if (json is List) {
    return json
        .whereType<Map>()
        .map((e) => PortfolioPositionDto.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
  if (json is Map<String, dynamic>) {
    final nested = json['positions'] ?? json['items'];
    if (nested is List) {
      return parseDashboardPositions(nested);
    }
  }
  return [];
}

List<DashboardMarketSnapshotItemDto> parseMarketSnapshot(dynamic json) {
  if (json is List) {
    return json
        .whereType<Map>()
        .map(
          (e) => DashboardMarketSnapshotItemDto.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }
  if (json is Map<String, dynamic>) {
    final nested =
        json['instruments'] ?? json['items'] ?? json['marketSnapshot'];
    if (nested is List) {
      return parseMarketSnapshot(nested);
    }
  }
  return [];
}

List<DashboardTransferRecipientDto> parseTransferRecipients(dynamic json) {
  if (json is List) {
    return json
        .whereType<Map>()
        .map(
          (e) => DashboardTransferRecipientDto.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }
  if (json is Map<String, dynamic>) {
    final nested = json['recipients'] ?? json['items'] ?? json['results'];
    if (nested is List) {
      return parseTransferRecipients(nested);
    }
  }
  return [];
}
