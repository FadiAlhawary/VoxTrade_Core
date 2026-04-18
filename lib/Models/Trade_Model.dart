class TradeModel {
  final int id;
  final int? orderId;
  final double? price;
  final double? quantity;
  final DateTime? executedAt;
  final String? side;
  final double? tradeValue;

  TradeModel({
    required this.id,
    this.orderId,
    this.price,
    this.quantity,
    this.executedAt,
    this.side,
    this.tradeValue,
  });

  factory TradeModel.fromJson(Map<String, dynamic> json) {
    return TradeModel(
      id: json['id'] as int,
      orderId: json['orderId'] as int?,
      price: (json['price'] as num?)?.toDouble(),
      quantity: (json['quantity'] as num?)?.toDouble(),
      executedAt: json['executedAt'] != null ? DateTime.parse(json['executedAt']) : null,
      side: json['side'] as String?,
      tradeValue: (json['tradeValue'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'price': price,
      'quantity': quantity,
      'executedAt': executedAt?.toIso8601String(),
      'side': side,
      'tradeValue': tradeValue,
    };
  }
}