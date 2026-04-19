int _tradeHistoryInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

int? _nullableInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

String _tradeHistoryString(dynamic v) {
  if (v == null) return '';
  return v.toString();
}

DateTime _tradeHistoryDateTime(dynamic v) {
  if (v == null) {
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
  if (v is DateTime) return v;
  final parsed = DateTime.tryParse(v.toString());
  return parsed ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
}

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
      id: _tradeHistoryInt(json['id'] ?? json['Id']),
      orderId: _nullableInt(json['order_id'] ?? json['orderId'] ?? json['OrderId']),
      userId: _nullableInt(json['user_id'] ?? json['userId'] ?? json['UserId']),
      instrumentId: _nullableInt(
        json['instrument_id'] ?? json['instrumentId'] ?? json['InstrumentId'],
      ),
      symbol: _tradeHistoryString(json['symbol'] ?? json['Symbol']),
      instrumentName: _tradeHistoryString(
        json['instrument_name'] ??
            json['instrumentName'] ??
            json['InstrumentName'],
      ),
      side: _tradeHistoryString(json['side'] ?? json['Side']),
      price: json['price'] ?? json['Price'],
      quantity: json['quantity'] ?? json['Quantity'],
      tradeValue: json['trade_value'] ?? json['tradeValue'] ?? json['TradeValue'],
      executedAt: _tradeHistoryDateTime(
        json['executed_at'] ?? json['executedAt'] ?? json['ExecutedAt'],
      ),
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
