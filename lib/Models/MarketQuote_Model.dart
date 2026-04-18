class MarketQuoteModel {
  final int id;
  final int instrumentId;
  final double? bidPrice;
  final double? askPrice;
  final double? lastTradePrice;
  final DateTime quoteTimestamp;
  final String source;

  MarketQuoteModel({
    required this.id,
    required this.instrumentId,
    this.bidPrice,
    this.askPrice,
    this.lastTradePrice,
    required this.quoteTimestamp,
    required this.source,
  });

  factory MarketQuoteModel.fromJson(Map<String, dynamic> json) {
    return MarketQuoteModel(
      id: json['id'] as int,
      instrumentId: json['instrument_id'] ?? json['instrumentId'] as int,
      bidPrice: (json['bid_price'] ?? json['bidPrice'] as num?)?.toDouble(),
      askPrice: (json['ask_price'] ?? json['askPrice'] as num?)?.toDouble(),
      lastTradePrice: (json['last_trade_price'] ?? json['lastTradePrice'] as num?)?.toDouble(),
      quoteTimestamp: json['quote_timestamp'] != null
          ? DateTime.parse(json['quote_timestamp'])
          : (json['quoteTimestamp'] != null
          ? DateTime.parse(json['quoteTimestamp'])
          : DateTime.now()),
      source: json['source'] as String? ?? 'finnhub',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'instrument_id': instrumentId,
      'bid_price': bidPrice,
      'ask_price': askPrice,
      'last_trade_price': lastTradePrice,
      'quote_timestamp': quoteTimestamp.toIso8601String(),
      'source': source,
    };
  }
}