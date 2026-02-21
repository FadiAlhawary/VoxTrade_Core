class Instrument {
  final int id;
  final String symbol;
  final String name;
  final double? tickSize;
  final double? minQuantity;
  final int? instrumentType;
  final int? status;

  Instrument({
    required this.id,
    required this.symbol,
    required this.name,
    this.tickSize,
    this.minQuantity,
    this.instrumentType,
    this.status,
  });

  factory Instrument.fromJson(Map<String, dynamic> json) {
    return Instrument(
      id: json['id'],
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      tickSize: (json['tick_size'] as num?)?.toDouble(),
      minQuantity: (json['min_quantity'] as num?)?.toDouble(),
      instrumentType: json['instrument_type'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'symbol': symbol,
        'name': name,
        'tick_size': tickSize,
        'min_quantity': minQuantity,
        'instrument_type': instrumentType,
        'status': status,
      };
}