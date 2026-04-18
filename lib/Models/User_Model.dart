class UserModel {
  final int id;
  final String username;
  final String firstNameEn;
  final String lastNameEn;
  final int? primaryCurrencyId;

  UserModel({
    required this.id,
    required this.username,
    required this.firstNameEn,
    required this.lastNameEn,
    this.primaryCurrencyId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] ?? '',
      firstNameEn: json['firstNameEn'] ?? '',
      lastNameEn: json['lastNameEn'] ?? '',
      primaryCurrencyId: json['primaryCurrencyId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstNameEn': firstNameEn,
      'lastNameEn': lastNameEn,
      'primaryCurrencyId': primaryCurrencyId,
    };
  }
}