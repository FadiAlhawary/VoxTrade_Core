class WalletHistoryModel {
  final int id;
  final int walletId;
  final int userId;
  final int? orderId;
  final int? tradeId;
  final String transactionType;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String? description;
  final DateTime? createdAt;

  WalletHistoryModel({
    required this.id,
    required this.walletId,
    required this.userId,
    this.orderId,
    this.tradeId,
    required this.transactionType,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.description,
    this.createdAt,
  });

  factory WalletHistoryModel.fromJson(Map<String, dynamic> json) {
    return WalletHistoryModel(
      id: json['id'] as int,
      walletId: json['walletId'] as int,
      userId: json['userId'] as int,
      orderId: json['orderId'] as int?,
      tradeId: json['tradeId'] as int?,
      transactionType: json['transactionType'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      balanceBefore: (json['balanceBefore'] as num?)?.toDouble() ?? 0.0,
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'walletId': walletId,
      'userId': userId,
      'orderId': orderId,
      'tradeId': tradeId,
      'transactionType': transactionType,
      'amount': amount,
      'balanceBefore': balanceBefore,
      'balanceAfter': balanceAfter,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}