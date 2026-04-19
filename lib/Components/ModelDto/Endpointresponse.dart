class EndpointResponseDTO {
  final bool success;
  final String message;

  EndpointResponseDTO({required this.success, required this.message});

  factory EndpointResponseDTO.fromJson(Map<String, dynamic> json) {
    return EndpointResponseDTO(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message};
  }
}
