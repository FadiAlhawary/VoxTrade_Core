class RegisterDTO {
  final String firstNameEn;
  final String lastNameEn;
  final String username;
  final String email;
  final String password;
  final DateTime? dob;
  final String phoneNumber;

  RegisterDTO({
    required this.firstNameEn,
    required this.lastNameEn,
    required this.username,
    required this.email,
    required this.password,
    this.dob,
    required this.phoneNumber,
  });

  factory RegisterDTO.fromJson(Map<String, dynamic> json) {
    return RegisterDTO(
      firstNameEn: json['firstNameEn'] ?? '',
      lastNameEn: json['lastNameEn'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstNameEn': firstNameEn,
      'lastNameEn': lastNameEn,
      'username': username,
      'email': email,
      'password': password,
      'dob': dob?.toIso8601String(),
      'phoneNumber': phoneNumber,
    };
  }
}
