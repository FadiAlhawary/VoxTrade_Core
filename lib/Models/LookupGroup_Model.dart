class LookupGroup {
  final int id;
  final String name;
  final String? code;
  final bool? isActive;

  LookupGroup({required this.id, required this.name, this.code, this.isActive});

  factory LookupGroup.fromJson(Map<String, dynamic> json) {
    return LookupGroup(
      id: json['id'],
      name: json['name'] ?? '',
      code: json['code'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'is_active': isActive,
      };
}
