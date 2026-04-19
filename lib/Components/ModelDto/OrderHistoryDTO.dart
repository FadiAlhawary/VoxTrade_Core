int _orderInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

int? _orderNullableInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

String _orderString(dynamic v) {
  if (v == null) return '';
  return v.toString();
}

DateTime _orderDateTime(dynamic v) {
  if (v == null) {
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
  if (v is DateTime) return v;
  final parsed = DateTime.tryParse(v.toString());
  return parsed ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
}

DateTime? _orderDateTimeNullable(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  return DateTime.tryParse(v.toString());
}

num _orderNum(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v;
  return num.tryParse(v.toString()) ?? 0;
}

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

  /// True when [status] indicates a pending order (case-insensitive).
  bool get isPendingStatus {
    final s = status.toLowerCase().trim();
    return s.contains('pending');
  }

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
      id: _orderInt(json['id'] ?? json['Id']),
      userId: _orderNullableInt(json['user_id'] ?? json['userId'] ?? json['UserId']),
      instrumentId: _orderNullableInt(
        json['instrument_id'] ?? json['instrumentId'] ?? json['InstrumentId'],
      ),
      symbol: _orderString(json['symbol'] ?? json['Symbol']),
      instrumentName: _orderString(
        json['instrument_name'] ??
            json['instrumentName'] ??
            json['InstrumentName'],
      ),
      orderTypeId: _orderInt(json['order_type_id'] ?? json['orderTypeId'] ?? json['OrderTypeId']),
      orderType: _orderString(json['order_type'] ?? json['orderType'] ?? json['OrderType']),
      actionTypeId: _orderInt(json['action_type_id'] ?? json['actionTypeId'] ?? json['ActionTypeId']),
      actionType: _orderString(json['action_type'] ?? json['actionType'] ?? json['ActionType']),
      statusId: _orderInt(json['status_id'] ?? json['statusId'] ?? json['StatusId']),
      status: _orderString(json['status'] ?? json['Status']),
      quantity: json['quantity'] ?? json['Quantity'],
      filledQuantity: _orderNum(
        json['filled_quantity'] ?? json['filledQuantity'] ?? json['FilledQuantity'],
      ),
      remainingQuantity: json['remaining_quantity'] ?? json['remainingQuantity'],
      price: json['price'] ?? json['Price'],
      limitPrice: json['limit_price'] ?? json['limitPrice'],
      stopPrice: json['stop_price'] ?? json['stopPrice'],
      executionPrice: json['execution_price'] ?? json['executionPrice'],
      averageFillPrice: json['average_fill_price'] ?? json['averageFillPrice'],
      createdAt: _orderDateTime(
        json['created_at'] ?? json['createdAt'] ?? json['CreatedAt'],
      ),
      updatedAt: _orderDateTimeNullable(
        json['updated_at'] ?? json['updatedAt'] ?? json['UpdatedAt'],
      ),
      cancelledAt: _orderDateTimeNullable(
        json['cancelled_at'] ?? json['cancelledAt'] ?? json['CancelledAt'],
      ),
      canCancel: json['can_cancel'] ?? json['canCancel'] ?? json['CanCancel'] ?? false,
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
