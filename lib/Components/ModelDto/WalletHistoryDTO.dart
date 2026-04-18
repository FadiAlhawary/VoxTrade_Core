class WalletHistoryDto {
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
  final DateTime createdAt;

  WalletHistoryDto({
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
    required this.createdAt,
  });

  // Factory method to create the DTO from your .NET backend JSON response
  factory WalletHistoryDto.fromJson(Map<String, dynamic> json) {
    return WalletHistoryDto(
      id: json['id'] as int? ?? 0,
      walletId: json['walletId'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      orderId: json['orderId'] as int?,
      tradeId: json['tradeId'] as int?,
      transactionType: json['transactionType'] as String? ?? '',
      // Safely casting to double in case the backend sends a whole number
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      balanceBefore: (json['balanceBefore'] as num?)?.toDouble() ?? 0.0,
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
      // Parse the ISO 8601 string from C# DateTime
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  // Method to convert the DTO back to JSON if you ever need to send it to the backend
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
      'createdAt': createdAt.toIso8601String(),
    };
  }
}