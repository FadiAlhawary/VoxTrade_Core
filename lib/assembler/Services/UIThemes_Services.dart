import 'dart:convert';

import 'package:voxtrade_core/Models/UITheme_Model.dart';
import 'package:voxtrade_core/assembler/common/globalAJAXService.dart';

Future<List<UIThemeModel>> GetUIThemeByPurposeId(int id) async {
  final String url = "/api/UIThemes/GetUIThemeByPurposeId";
  return await sendHttpRequest(url, param: {"Id": id},fromJson: (json){
      final list = json as List;
      return list.map((e)=>UIThemeModel.fromJsom(e)).toList();
  });
}
