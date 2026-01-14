
   import 'dart:ffi';

import 'package:get/get.dart';
import 'package:voxtrade_core/Models/UITheme_Model.dart';
import 'package:voxtrade_core/assembler/Services/UIThemes_Services.dart';

class UIThemesController extends GetxController {
  final themes = Rxn<List<UIThemeModel>>();

   Future<void> loadThemes() async{
       final result =await GetUIThemeByPurposeId(1);
       themes.value = result;
   }
}