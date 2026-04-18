class OrderModel {
  final int id;
  final int? instrumentId;
  final double? quantity;
  final double? price;
  final String? side;
  final int statusId;
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    this.instrumentId,
    this.quantity,
    this.price,
    this.side,
    required this.statusId,
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int,
      instrumentId: json['instrumentId'] as int?,
      quantity: (json['quantity'] as num?)?.toDouble(),
      price: (json['price'] as num?)?.toDouble(),
      side: json['side'] as String?,
      statusId: json['statusId'] as int,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'instrumentId': instrumentId,
      'quantity': quantity,
      'price': price,
      'side': side,
      'statusId': statusId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}