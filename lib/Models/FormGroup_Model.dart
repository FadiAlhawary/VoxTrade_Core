class FormGroup {
  final int formId;
  final int groupId;
  final bool? isDeleted;
  final DateTime? creationDate;
  final int? roleId;

  FormGroup({
    required this.formId,
    required this.groupId,
    this.isDeleted,
    this.creationDate,
    this.roleId,
  });

  factory FormGroup.fromJson(Map<String, dynamic> json) {
    return FormGroup(
      formId: json['form_id'],
      groupId: json['group_id'],
      isDeleted: json['is_deleted'],
      creationDate: json['creation_date'] != null
          ? DateTime.parse(json['creation_date'])
          : null,
      roleId: json['role_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'form_id': formId,
      'group_id': groupId,
      'is_deleted': isDeleted,
      'creation_date': creationDate?.toIso8601String(),
      'role_id': roleId,
    };
  }
}