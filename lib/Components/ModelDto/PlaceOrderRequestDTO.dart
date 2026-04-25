class PlaceOrderRequestDTO {
  final int userId;
  final int instrumentId;
  final String side; // buy / sell
  final String orderType; // market / limit
  final double quantity;
  final double? limitPrice;
  final int? currencyId;
  final String sourceCode;

  PlaceOrderRequestDTO({
    required this.userId,
    required this.instrumentId,
    required this.side,
    required this.orderType,
    required this.quantity,
    this.limitPrice,
    this.currencyId,
    this.sourceCode = 'manual',
  });

  factory PlaceOrderRequestDTO.fromJson(Map<String, dynamic> json) {
    return PlaceOrderRequestDTO(
      userId: json['userId'],
      instrumentId: json['instrumentId'],
      side: json['side'],
      orderType: json['orderType'],
      quantity: (json['quantity'] as num).toDouble(),
      limitPrice:
          json['limitPrice'] != null
              ? (json['limitPrice'] as num).toDouble()
              : null,
      currencyId: json['currencyId'],
      sourceCode: json['sourceCode'] ?? 'manual',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'instrumentId': instrumentId,
      'side': side,
      'orderType': orderType,
      'quantity': quantity,
      'limitPrice': limitPrice,
      'currencyId': currencyId,
      'sourceCode': sourceCode,
    };
  }
}
