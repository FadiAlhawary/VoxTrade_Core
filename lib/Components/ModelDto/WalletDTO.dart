import 'package:voxtrade_core/Components/ModelDto/WalletHistoryDTO.dart';

class WalletDto {
  final int id;
  final int userId;
  final int? currencyId;
  final double balance;
  final double availableBalance;
  final double reservedBalance;
  final bool status;
  final DateTime updatedAt;
  final List<WalletHistoryDto> walletHistory;

  WalletDto({
    required this.id,
    required this.userId,
    this.currencyId,
    required this.balance,
    required this.availableBalance,
    required this.reservedBalance,
    required this.status,
    required this.updatedAt,
    required this.walletHistory,
  });

  factory WalletDto.fromJson(Map<String, dynamic> json) {
    return WalletDto(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      currencyId: json['currencyId'] as int?,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0.0,
      reservedBalance: (json['reservedBalance'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as bool? ?? true,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'].toString())
              : DateTime.now(),
      walletHistory:
          (json['walletHistory'] as List<dynamic>? ?? [])
              .whereType<Map>()
              .map(
                (item) => WalletHistoryDto.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'currencyId': currencyId,
      'balance': balance,
      'availableBalance': availableBalance,
      'reservedBalance': reservedBalance,
      'status': status,
      'updatedAt': updatedAt.toIso8601String(),
      'walletHistory': walletHistory.map((item) => item.toJson()).toList(),
    };
  }
}
