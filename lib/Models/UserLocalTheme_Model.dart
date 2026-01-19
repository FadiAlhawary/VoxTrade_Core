class UserLocalTheme {
  final int id;
  final int? userId;
  final String? primaryColor;
  final String? secondaryColor;
  final String? backgroundColor;
  final String? textColor;

  UserLocalTheme({
    required this.id,
    this.userId,
    this.primaryColor,
    this.secondaryColor,
    this.backgroundColor,
    this.textColor,
  });

  factory UserLocalTheme.fromJson(Map<String, dynamic> json) {
    return UserLocalTheme(
      id: json['id'],
      userId: json['user_id'],
      primaryColor: json['primary_color'],
      secondaryColor: json['secondary_color'],
      backgroundColor: json['background_color'],
      textColor: json['text_color'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'primary_color': primaryColor,
        'secondary_color': secondaryColor,
        'background_color': backgroundColor,
        'text_color': textColor,
      };
}