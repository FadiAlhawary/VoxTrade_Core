class Language {
  final int id;
  final String nameEn;
  final String nameAr;

  Language({
    required this.id,
    required this.nameEn,
    required this.nameAr,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'],
      nameEn: json['name_en'] ?? '',
      nameAr: json['name_ar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_ar': nameAr,
    };
  }
}