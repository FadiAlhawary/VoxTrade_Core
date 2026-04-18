class OrderHistory {
  final int id;
  final int? userId;
  final int? instrumentId;
  final String symbol;
  final String instrumentName;

  final int orderTypeId;
  final String orderType;

  final int actionTypeId;
  final String actionType;

  final int statusId;
  final String status;

  final num? quantity;
  final num filledQuantity;
  final num? remainingQuantity;

  final num? price;
  final num? limitPrice;
  final num? stopPrice;
  final num? executionPrice;
  final num? averageFillPrice;

  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? cancelledAt;

  final bool canCancel;

  OrderHistory({
    required this.id,
    this.userId,
    this.instrumentId,
    required this.symbol,
    required this.instrumentName,
    required this.orderTypeId,
    required this.orderType,
    required this.actionTypeId,
    required this.actionType,
    required this.statusId,
    required this.status,
    this.quantity,
    required this.filledQuantity,
    this.remainingQuantity,
    this.price,
    this.limitPrice,
    this.stopPrice,
    this.executionPrice,
    this.averageFillPrice,
    required this.createdAt,
    this.updatedAt,
    this.cancelledAt,
    required this.canCancel,
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) {
    return OrderHistory(
      id: json['id'],
      userId: json['user_id'],
      instrumentId: json['instrument_id'],
      symbol: json['symbol'] ?? '',
      instrumentName: json['instrument_name'] ?? '',
      orderTypeId: json['order_type_id'],
      orderType: json['order_type'] ?? '',
      actionTypeId: json['action_type_id'],
      actionType: json['action_type'] ?? '',
      statusId: json['status_id'],
      status: json['status'] ?? '',
      quantity: json['quantity'],
      filledQuantity: json['filled_quantity'] ?? 0,
      remainingQuantity: json['remaining_quantity'],
      price: json['price'],
      limitPrice: json['limit_price'],
      stopPrice: json['stop_price'],
      executionPrice: json['execution_price'],
      averageFillPrice: json['average_fill_price'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      cancelledAt:
          json['cancelled_at'] != null
              ? DateTime.parse(json['cancelled_at'])
              : null,
      canCancel: json['can_cancel'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'instrument_id': instrumentId,
      'symbol': symbol,
      'instrument_name': instrumentName,
      'order_type_id': orderTypeId,
      'order_type': orderType,
      'action_type_id': actionTypeId,
      'action_type': actionType,
      'status_id': statusId,
      'status': status,
      'quantity': quantity,
      'filled_quantity': filledQuantity,
      'remaining_quantity': remainingQuantity,
      'price': price,
      'limit_price': limitPrice,
      'stop_price': stopPrice,
      'execution_price': executionPrice,
      'average_fill_price': averageFillPrice,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'can_cancel': canCancel,
    };
  }
}
