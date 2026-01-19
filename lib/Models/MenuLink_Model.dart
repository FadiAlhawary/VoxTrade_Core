class MenuLink {
  final int id;
  final String title;
  final int? parentMenuId;
  final int? orderIndex;
  final String? url;
  final int? roleId;

  MenuLink({
    required this.id,
    required this.title,
    this.parentMenuId,
    this.orderIndex,
    this.url,
    this.roleId,
  });

  factory MenuLink.fromJson(Map<String, dynamic> json) {
    return MenuLink(
      id: json['id'],
      title: json['title'] ?? '',
      parentMenuId: json['parent_menu_id'],
      orderIndex: json['order_index'],
      url: json['url'],
      roleId: json['role_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'parent_menu_id': parentMenuId,
        'order_index': orderIndex,
        'url': url,
        'role_id': roleId,
      };
}
