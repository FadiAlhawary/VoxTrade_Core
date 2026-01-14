class RolesModel{
  final int id;
  final String role_name_en;

  RolesModel({required this.id,required this.role_name_en});

  factory RolesModel.fromJson(Map<String,dynamic> json){
    return RolesModel(id: json['id'], role_name_en: json['role_name_en']);
  }

}
