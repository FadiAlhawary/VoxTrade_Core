class LookupItemDto {
  final int id;
  final String name;
  final String? code;

  LookupItemDto({required this.id, required this.name, this.code});

  factory LookupItemDto.fromJson(Map<String, dynamic> json) {
    return LookupItemDto(
      id: json['id'],
      name: json['name'] ?? '',
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'code': code};
  }
}
