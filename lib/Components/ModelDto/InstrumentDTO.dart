class InstrumentDTO {
  final int id;
  final String symbol;
  final String name;
  final double? tickSize;
  final double? minQuantity;

  final int? instrumentTypeId;
  final String? instrumentType;

  final int? statusId;
  final String? status;
  final String shortName;

  InstrumentDTO({
    required this.id,
    required this.symbol,
    required this.name,
    this.tickSize,
    this.minQuantity,
    this.instrumentTypeId,
    this.instrumentType,
    this.statusId,
    this.status,
    required this.shortName,
  });

  factory InstrumentDTO.fromJson(Map<String, dynamic> json) {
    return InstrumentDTO(
      id: json['id'] ?? 0,
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      tickSize: json['tickSize'] != null
          ? double.tryParse(json['tickSize'].toString())
          : null,
      minQuantity: json['minQuantity'] != null
          ? double.tryParse(json['minQuantity'].toString())
          : null,
      instrumentTypeId: json['instrumentTypeId'],
      instrumentType: json['instrumentType'],
      statusId: json['statusId'],
      status: json['status'],
      shortName: json['short_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'tickSize': tickSize,
      'minQuantity': minQuantity,
      'instrumentTypeId': instrumentTypeId,
      'instrumentType': instrumentType,
      'statusId': statusId,
      'status': status,
      'short_name': shortName,
    };
  }
}