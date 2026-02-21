class User {
  final int id;
  final String firstNameEn;
  final String lastNameEn;
  final String firstNameAr;
  final String lastNameAr;
  final String username;
  final int? roleId;
  final String? token;
  final DateTime? lastLoginDate;
  final bool isLoggedIn;
  final String password;
  final DateTime? dob;
  final DateTime? createdAt;
  final bool? isDeleted;
  final DateTime? deleteAt;
  final int? deletedBy;
  final int? primaryCurrencyId;

  User({
    required this.id,
    required this.firstNameEn,
    required this.lastNameEn,
    required this.firstNameAr,
    required this.lastNameAr,
    required this.username,
    this.roleId,
    this.token,
    this.lastLoginDate,
    required this.isLoggedIn,
    required this.password,
    this.dob,
    this.createdAt,
    this.isDeleted,
    this.deleteAt,
    this.deletedBy,
    this.primaryCurrencyId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstNameEn: json['first_name_en'] ?? '',
      lastNameEn: json['last_name_en'] ?? '',
      firstNameAr: json['first_name_ar'] ?? '',
      lastNameAr: json['last_name_ar'] ?? '',
      username: json['username'] ?? '',
      roleId: json['role_id'],
      token: json['token'],
      lastLoginDate: json['last_login_date'] != null ? DateTime.parse(json['last_login_date']) : null,
      isLoggedIn: json['is_logged_in'] ?? false,
      password: json['password'] ?? '',
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      isDeleted: json['is_deleted'],
      deleteAt: json['delete_at'] != null ? DateTime.parse(json['delete_at']) : null,
      deletedBy: json['deleted_by'],
      primaryCurrencyId: json['primary_currency_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name_en': firstNameEn,
      'last_name_en': lastNameEn,
      'first_name_ar': firstNameAr,
      'last_name_ar': lastNameAr,
      'username': username,
      'role_id': roleId,
      'token': token,
      'last_login_date': lastLoginDate?.toIso8601String(),
      'is_logged_in': isLoggedIn,
      'password': password,
      'dob': dob?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'is_deleted': isDeleted,
      'delete_at': deleteAt?.toIso8601String(),
      'deleted_by': deletedBy,
      'primary_currency_id': primaryCurrencyId,
    };
  }
}
