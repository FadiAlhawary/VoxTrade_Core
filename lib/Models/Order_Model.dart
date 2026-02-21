class Order {
  final int id;
  final int? userId;
  final int? instrumentId;
  final int? paymentMethodId;
  final int orderTypeId;
  final int actionTypeId;
  final double? quantity;
  final double? price;
  final int statusId;
  final int sourceId;
  final int? voiceCommandId;
  final int? currencyId;
  final double? executionPrice;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Order({
    required this.id,
    this.userId,
    this.instrumentId,
    this.paymentMethodId,
    required this.orderTypeId,
    required this.actionTypeId,
    this.quantity,
    this.price,
    required this.statusId,
    required this.sourceId,
    this.voiceCommandId,
    this.currencyId,
    this.executionPrice,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user_id'],
      instrumentId: json['instrument_id'],
      paymentMethodId: json['payment_method_id'],
      orderTypeId: json['order_type_id'],
      actionTypeId: json['action_type_id'],
      quantity: (json['quantity'] as num?)?.toDouble(),
      price: (json['price'] as num?)?.toDouble(),
      statusId: json['status_id'],
      sourceId: json['source_id'],
      voiceCommandId: json['voice_command_id'],
      currencyId: json['currency_id'],
      executionPrice: (json['execution_price'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'instrument_id': instrumentId,
        'payment_method_id': paymentMethodId,
        'order_type_id': orderTypeId,
        'action_type_id': actionTypeId,
        'quantity': quantity,
        'price': price,
        'status_id': statusId,
        'source_id': sourceId,
        'voice_command_id': voiceCommandId,
        'currency_id': currencyId,
        'execution_price': executionPrice,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
