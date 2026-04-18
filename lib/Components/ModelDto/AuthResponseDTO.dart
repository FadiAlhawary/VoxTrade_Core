import 'package:voxtrade_core/Components/ModelDto/UserDTO.dart';

class AuthResponseDTO {
  final bool success;
  final String message;
  final String? token;
  final UserDTO? user;

  AuthResponseDTO({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory AuthResponseDTO.fromJson(Map<String, dynamic> json) {
    return AuthResponseDTO(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'],
      user: json['user'] != null ? UserDTO.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'user': user?.toJson(),
    };
  }
}
