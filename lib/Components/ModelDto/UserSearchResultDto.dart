class UserSearchResultDto {
  final int id;
  final String username;
  final String firstNameEn;
  final String lastNameEn;
  final String displayName;
  final int? walletId;

  UserSearchResultDto({
    required this.id,
    required this.username,
    required this.firstNameEn,
    required this.lastNameEn,
    required this.displayName,
    this.walletId,
  });

  factory UserSearchResultDto.fromJson(Map<String, dynamic> json) {
    return UserSearchResultDto(
      id: json['userId'] as int? ?? json['id'] as int? ?? 0,
      username: json['username'] ?? '',
      firstNameEn: json['firstNameEn'] ?? '',
      lastNameEn: json['lastNameEn'] ?? '',
      displayName: json['displayName'] ?? '',
      walletId: json['walletId'] as int?,
    );
  }

  String get label {
    final name = displayName.trim();
    if (name.isNotEmpty) return '$name (@$username)';
    return '@$username';
  }
}
