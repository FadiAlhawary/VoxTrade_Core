import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  bool isDarkMode = false;
   Color textColor = Colors.black;
   final box = GetStorage();
   void changeTheme(bool isDarkMode){
      box.write("theme", isDarkMode);
      if(isDarkMode){
         textColor =Colors.white;
      }else{
        textColor = Colors.black;
      }
   }

}