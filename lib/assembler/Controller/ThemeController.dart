import 'package:get/get.dart';
import 'package:localstorage/localstorage.dart';

class ThemeController extends GetxController {
  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    final isDarkModeString = localStorage.getItem('isDarkMode');
    if (isDarkModeString != null) {
      isDarkMode.value = isDarkModeString == 'true';
    } else {
      isDarkMode.value = false;
      localStorage.setItem('isDarkMode', 'false');
    }
  }

  void changeTheme(bool dark) {
    isDarkMode.value = dark;
    localStorage.setItem('isDarkMode', dark.toString());
  }
}
