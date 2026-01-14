class UIThemeModel {
  final int id;
  final int type;
  final int purpose;
  final Map<String, dynamic>? style;

  UIThemeModel({
    required this.id,
    required this.type,
    required this.purpose,
    this.style,
  });
  factory UIThemeModel.fromJsom(Map<String,dynamic> json){
    return UIThemeModel(
      id: json['id'],
      type: json['type'],
      purpose: json['purpose'],
      style: json['style']
    );
  }
  Map<String,dynamic> toJson(){
    return{
       'id':id,
      'type':type,
      'purpose':purpose,
      'style':style,
    };
  }
}