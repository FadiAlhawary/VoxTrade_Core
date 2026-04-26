class CandleDTO {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;

  CandleDTO({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  factory CandleDTO.fromJson(Map<String, dynamic> json) {
    final rawTime = json['time'] ?? json['t'];
    final parsedTime = _parseTime(rawTime);
    return CandleDTO(
      time: parsedTime,
      open: _toDouble(json['open'] ?? json['o']),
      high: _toDouble(json['high'] ?? json['h']),
      low: _toDouble(json['low'] ?? json['l']),
      close: _toDouble(json['close'] ?? json['c']),
    );
  }

  static DateTime _parseTime(dynamic value) {
    if (value is DateTime) return value.toUtc();
    if (value is num) {
      final asInt = value.toInt();
      // Detect seconds vs milliseconds.
      final millis = asInt < 1000000000000 ? asInt * 1000 : asInt;
      return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
    }
    if (value is String) {
      final asNum = int.tryParse(value);
      if (asNum != null) {
        final millis = asNum < 1000000000000 ? asNum * 1000 : asNum;
        return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
      }
      return DateTime.parse(value).toUtc();
    }
    throw Exception('Invalid candle time value: $value');
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw Exception('Invalid candle numeric value: $value');
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'open': open,
      'high': high,
      'low': low,
      'close': close,
    };
  }
}
