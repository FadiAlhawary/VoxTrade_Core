class UserAuditLog {
  final int id;
  final int? userId;
  final String? entity;
  final int? entityId;
  final String? description;
  final int? action;
  final DateTime? createdAt;

  UserAuditLog({
    required this.id,
    this.userId,
    this.entity,
    this.entityId,
    this.description,
    this.action,
    this.createdAt,
  });

  factory UserAuditLog.fromJson(Map<String, dynamic> json) {
    return UserAuditLog(
      id: json['id'],
      userId: json['user_id'],
      entity: json['entity'],
      entityId: json['entity_id'],
      description: json['description'],
      action: json['action'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'entity': entity,
        'entity_id': entityId,
        'description': description,
        'action': action,
        'created_at': createdAt?.toIso8601String(),
      };
}