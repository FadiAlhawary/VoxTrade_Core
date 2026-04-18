class UserDTO {
  final int id;
  final String firstNameEn;
  final String lastNameEn;
  final String username;
  final DateTime? dob;
  final String primaryEmail;
  final String? altEmail;
  final String primaryPhoneNumber;
  final String? altPhoneNumber;
  final bool isPrimaryEmailActive;
  final bool isAltEmailActive;
  final bool isPrimaryPhoneNumberActive;
  final bool isAltPhoneNumberActive;

  UserDTO({
    required this.id,
    required this.firstNameEn,
    required this.lastNameEn,
    required this.username,
    this.dob,
    required this.primaryEmail,
    this.altEmail,
    required this.primaryPhoneNumber,
    this.altPhoneNumber,
    required this.isPrimaryEmailActive,
    required this.isAltEmailActive,
    required this.isPrimaryPhoneNumberActive,
    required this.isAltPhoneNumberActive,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id'] as int,
      firstNameEn: json['firstNameEn'] ?? '',
      lastNameEn: json['lastNameEn'] ?? '',
      username: json['username'] ?? '',
      dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
      primaryEmail: json['primaryEmail'] ?? '',
      altEmail: json['altEmail'],
      primaryPhoneNumber: json['primaryPhoneNumber'] ?? '',
      altPhoneNumber: json['altPhoneNumber'],
      isPrimaryEmailActive: json['isPrimaryEmailActive'] ?? false,
      isAltEmailActive: json['isAltEmailActive'] ?? false,
      isPrimaryPhoneNumberActive: json['isPrimaryPhoneNumberActive'] ?? false,
      isAltPhoneNumberActive: json['isAltPhoneNumberActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstNameEn': firstNameEn,
      'lastNameEn': lastNameEn,
      'username': username,
      'dob': dob?.toIso8601String(),
      'primaryEmail': primaryEmail,
      'altEmail': altEmail,
      'primaryPhoneNumber': primaryPhoneNumber,
      'altPhoneNumber': altPhoneNumber,
      'isPrimaryEmailActive': isPrimaryEmailActive,
      'isAltEmailActive': isAltEmailActive,
      'isPrimaryPhoneNumberActive': isPrimaryPhoneNumberActive,
      'isAltPhoneNumberActive': isAltPhoneNumberActive,
    };
  }
}
