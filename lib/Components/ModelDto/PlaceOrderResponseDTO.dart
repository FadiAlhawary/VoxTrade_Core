class PlaceOrderResponseDTO {
  final bool success;
  final String message;
  final int? orderId;
  final String? status;
  final double? price;

  PlaceOrderResponseDTO({
    required this.success,
    required this.message,
    this.orderId,
    this.status,
    this.price,
  });

  factory PlaceOrderResponseDTO.fromJson(Map<String, dynamic> json) {
    return PlaceOrderResponseDTO(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      orderId: json['orderId'],
      status: json['status'],
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'orderId': orderId,
      'status': status,
      'price': price,
    };
  }
}
