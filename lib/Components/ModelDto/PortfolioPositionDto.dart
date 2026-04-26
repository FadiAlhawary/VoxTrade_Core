class PortfolioPositionDto {
  final int positionId;
  final int userId;
  final int instrumentId;
  final String symbol;
  final String instrumentName;
  final double quantity;
  final double reservedQuantity;
  final double availableQuantity;
  final double averageCost;
  final double realizedPnl;
  final double? bidPrice;
  final double? askPrice;
  final double? lastTradePrice;
  final double currentPrice;
  final double marketValue;
  final double unrealizedPnl;
  final DateTime updatedAt;
  final String short_name;

  PortfolioPositionDto({
    required this.positionId,
    required this.userId,
    required this.instrumentId,
    required this.symbol,
    required this.instrumentName,
    required this.quantity,
    required this.reservedQuantity,
    required this.availableQuantity,
    required this.averageCost,
    required this.realizedPnl,
    this.bidPrice,
    this.askPrice,
    this.lastTradePrice,
    required this.currentPrice,
    required this.marketValue,
    required this.unrealizedPnl,
    required this.updatedAt,
    required this.short_name,
  });

  factory PortfolioPositionDto.fromJson(Map<String, dynamic> json) {
    return PortfolioPositionDto(
      positionId: json['positionId'],
      userId: json['userId'],
      instrumentId: json['instrumentId'],
      symbol: json['symbol'],
      instrumentName: json['instrumentName'],
      quantity: (json['quantity'] as num).toDouble(),
      reservedQuantity: (json['reservedQuantity'] as num).toDouble(),
      availableQuantity: (json['availableQuantity'] as num).toDouble(),
      averageCost:
          ((json['averageCost'] ?? json['average_cost'] ?? json['avgCost'])
                  as num?)
              ?.toDouble() ??
          0.0,
      realizedPnl: (json['realizedPnl'] as num).toDouble(),
      bidPrice:
          json['bidPrice'] != null
              ? (json['bidPrice'] as num).toDouble()
              : null,
      askPrice:
          json['askPrice'] != null
              ? (json['askPrice'] as num).toDouble()
              : null,
      lastTradePrice:
          json['lastTradePrice'] != null
              ? (json['lastTradePrice'] as num).toDouble()
              : null,
      currentPrice: (json['currentPrice'] as num).toDouble(),
      marketValue: (json['marketValue'] as num).toDouble(),
      unrealizedPnl: (json['unrealizedPnl'] as num).toDouble(),
      updatedAt: DateTime.parse(json['updatedAt']),
      short_name: (json['short_name'] ?? json['shortName'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'positionId': positionId,
      'userId': userId,
      'instrumentId': instrumentId,
      'symbol': symbol,
      'instrumentName': instrumentName,
      'quantity': quantity,
      'reservedQuantity': reservedQuantity,
      'availableQuantity': availableQuantity,
      'averageCost': averageCost,
      'realizedPnl': realizedPnl,
      'bidPrice': bidPrice,
      'askPrice': askPrice,
      'lastTradePrice': lastTradePrice,
      'currentPrice': currentPrice,
      'marketValue': marketValue,
      'unrealizedPnl': unrealizedPnl,
      'updatedAt': updatedAt.toIso8601String(),
      'short_name': short_name,
    };
  }
}
