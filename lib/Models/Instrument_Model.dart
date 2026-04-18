class InstrumentModel {
  final int id;
  final String? symbol;
  final String? name;
  final double? tickSize;
  final double? minQuantity;
  final int? status;

  InstrumentModel({
    required this.id,
    this.symbol,
    this.name,
    this.tickSize,
    this.minQuantity,
    this.status,
  });

  factory InstrumentModel.fromJson(Map<String, dynamic> json) {
    return InstrumentModel(
      id: json['id'] as int,
      symbol: json['symbol'] as String?,
      name: json['name'] as String?,
      tickSize: (json['tickSize'] as num?)?.toDouble(),
      minQuantity: (json['minQuantity'] as num?)?.toDouble(),
      status: json['status'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'tickSize': tickSize,
      'minQuantity': minQuantity,
      'status': status,
    };
  }
}