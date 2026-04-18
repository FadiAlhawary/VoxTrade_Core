class PositionModel {
  final int id;
  final int userId;
  final int instrumentId;
  final double quantity;
  final double averageCost;
  final double realizedPnl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PositionModel({
    required this.id,
    required this.userId,
    required this.instrumentId,
    required this.quantity,
    required this.averageCost,
    required this.realizedPnl,
    this.createdAt,
    this.updatedAt,
  });

  factory PositionModel.fromJson(Map<String, dynamic> json) {
    return PositionModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      instrumentId: json['instrument_id'] as int,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      averageCost: (json['average_cost'] as num?)?.toDouble() ?? 0.0,
      realizedPnl: (json['realized_pnl'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'instrument_id': instrumentId,
      'quantity': quantity,
      'average_cost': averageCost,
      'realized_pnl': realizedPnl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}