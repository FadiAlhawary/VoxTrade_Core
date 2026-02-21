class Currency {
  final int id;
  final String nameEn;
  final String nameAr;
  final String symbol;
  final int? countryId;

  Currency({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.symbol,
    this.countryId,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: json['id'],
      nameEn: json['name_en'] ?? '',
      nameAr: json['name_ar'] ?? '',
      symbol: json['symbol'] ?? '',
      countryId: json['country_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name_en': nameEn,
        'name_ar': nameAr,
        'symbol': symbol,
        'country_id': countryId,
      };
}