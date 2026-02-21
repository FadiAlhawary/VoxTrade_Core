class Lookup {
  final int id;
  final int lookupGroupId;
  final String name;
  final String? code;
  final int? roleId;
  final bool? isActive;

  Lookup({
    required this.id,
    required this.lookupGroupId,
    required this.name,
    this.code,
    this.roleId,
    this.isActive,
  });

  factory Lookup.fromJson(Map<String, dynamic> json) {
    return Lookup(
      id: json['id'],
      lookupGroupId: json['lookup_group_id'],
      name: json['name'] ?? '',
      code: json['code'],
      roleId: json['role_id'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lookup_group_id': lookupGroupId,
        'name': name,
        'code': code,
        'role_id': roleId,
        'is_active': isActive,
      };
}