class WalletModel {
  final int id;
  final double balance;
  final double availableBalance;
  final double reservedBalance;
  final int? currencyId;

  WalletModel({
    required this.id,
    required this.balance,
    required this.availableBalance,
    required this.reservedBalance,
    this.currencyId,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as int,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0.0,
      reservedBalance: (json['reservedBalance'] as num?)?.toDouble() ?? 0.0,
      currencyId: json['currencyId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'balance': balance,
      'availableBalance': availableBalance,
      'reservedBalance': reservedBalance,
      'currencyId': currencyId,
    };
  }
}