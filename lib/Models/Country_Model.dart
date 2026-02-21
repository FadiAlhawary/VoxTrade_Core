class Country {
  final int id;
  final String nameEn;
  final String nameAr;
  final String region;
  final int? primaryLanguageId;
  final int? secondaryLanguageId;

  Country({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.region,
    this.primaryLanguageId,
    this.secondaryLanguageId,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      nameEn: json['name_en'] ?? '',
      nameAr: json['name_ar'] ?? '',
      region: json['region'] ?? '',
      primaryLanguageId: json['primary_language_id'],
      secondaryLanguageId: json['secondary_language_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name_en': nameEn,
        'name_ar': nameAr,
        'region': region,
        'primary_language_id': primaryLanguageId,
        'secondary_language_id': secondaryLanguageId,
      };
}