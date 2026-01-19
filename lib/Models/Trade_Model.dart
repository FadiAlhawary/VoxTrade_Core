class Trade {
  final int id;
  final int? orderId;
  final double? price;
  final double? quantity;
  final DateTime? executedAt;
  final int? currencyId;

  Trade({
    required this.id,
    this.orderId,
    this.price,
    this.quantity,
    this.executedAt,
    this.currencyId,
  });

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      id: json['id'],
      orderId: json['order_id'],
      price: (json['price'] as num?)?.toDouble(),
      quantity: (json['quantity'] as num?)?.toDouble(),
      executedAt: json['executed_at'] != null ? DateTime.parse(json['executed_at']) : null,
      currencyId: json['currency_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'price': price,
        'quantity': quantity,
        'executed_at': executedAt?.toIso8601String(),
        'currency_id': currencyId,
      };
}