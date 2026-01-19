class MarketPrice {
  final int id;
  final int? instrumentId;
  final double? price;
  final double? askPrice;
  final double? bidPrice;
  final double? volume;
  final DateTime? priceTime;

  MarketPrice({
    required this.id,
    this.instrumentId,
    this.price,
    this.askPrice,
    this.bidPrice,
    this.volume,
    this.priceTime,
  });

  factory MarketPrice.fromJson(Map<String, dynamic> json) {
    return MarketPrice(
      id: json['id'],
      instrumentId: json['instrument_id'],
      price: (json['price'] as num?)?.toDouble(),
      askPrice: (json['ask_price'] as num?)?.toDouble(),
      bidPrice: (json['bid_price'] as num?)?.toDouble(),
      volume: (json['volume'] as num?)?.toDouble(),
      priceTime: json['price_time'] != null ? DateTime.parse(json['price_time']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'instrument_id': instrumentId,
        'price': price,
        'ask_price': askPrice,
        'bid_price': bidPrice,
        'volume': volume,
        'price_time': priceTime?.toIso8601String(),
      };
}