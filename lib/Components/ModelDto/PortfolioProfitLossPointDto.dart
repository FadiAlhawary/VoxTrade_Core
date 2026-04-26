class PortfolioProfitLossPointDto {
  final DateTime time;
  final double totalValue;
  final double cashBalance;
  final double positionsValue;
  final double realizedPnl;
  final double unrealizedPnl;
  final double profitLoss;

  PortfolioProfitLossPointDto({
    required this.time,
    required this.totalValue,
    required this.cashBalance,
    required this.positionsValue,
    required this.realizedPnl,
    required this.unrealizedPnl,
    required this.profitLoss,
  });

  factory PortfolioProfitLossPointDto.fromJson(Map<String, dynamic> json) {
    return PortfolioProfitLossPointDto(
      time: DateTime.parse(json['time']),
      totalValue: (json['totalValue'] as num).toDouble(),
      cashBalance: (json['cashBalance'] as num).toDouble(),
      positionsValue: (json['positionsValue'] as num).toDouble(),
      realizedPnl: (json['realizedPnl'] as num).toDouble(),
      unrealizedPnl: (json['unrealizedPnl'] as num).toDouble(),
      profitLoss: (json['profitLoss'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'totalValue': totalValue,
      'cashBalance': cashBalance,
      'positionsValue': positionsValue,
      'realizedPnl': realizedPnl,
      'unrealizedPnl': unrealizedPnl,
      'profitLoss': profitLoss,
    };
  }
}
