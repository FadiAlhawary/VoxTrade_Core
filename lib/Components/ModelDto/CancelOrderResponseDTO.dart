class CancelOrderResponseDTO {
  final bool success;
  final String message;
  final int? orderId;

  CancelOrderResponseDTO({
    required this.success,
    required this.message,
    this.orderId,
  });

  factory CancelOrderResponseDTO.fromJson(Map<String, dynamic> json) {
    return CancelOrderResponseDTO(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      orderId: json['orderId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'orderId': orderId};
  }
}
