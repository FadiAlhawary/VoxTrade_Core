class TradeHistory {
  final int id;
  final int? orderId;
  final int? userId;
  final int? instrumentId;
  final String symbol;
  final String instrumentName;

  final String side;
  final num? price;
  final num? quantity;
  final num? tradeValue;
  final DateTime executedAt;

  TradeHistory({
    required this.id,
    this.orderId,
    this.userId,
    this.instrumentId,
    required this.symbol,
    required this.instrumentName,
    required this.side,
    this.price,
    this.quantity,
    this.tradeValue,
    required this.executedAt,
  });

  factory TradeHistory.fromJson(Map<String, dynamic> json) {
    return TradeHistory(
      id: json['id'],
      orderId: json['order_id'],
      userId: json['user_id'],
      instrumentId: json['instrument_id'],
      symbol: json['symbol'] ?? '',
      instrumentName: json['instrument_name'] ?? '',
      side: json['side'] ?? '',
      price: json['price'],
      quantity: json['quantity'],
      tradeValue: json['trade_value'],
      executedAt: DateTime.parse(json['executed_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'user_id': userId,
      'instrument_id': instrumentId,
      'symbol': symbol,
      'instrument_name': instrumentName,
      'side': side,
      'price': price,
      'quantity': quantity,
      'trade_value': tradeValue,
      'executed_at': executedAt.toIso8601String(),
    };
  }
}
