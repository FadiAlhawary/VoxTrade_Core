import 'package:get/get.dart';
import 'package:localstorage/localstorage.dart';

class ThemeController extends GetxController {
  final RxBool isDarkMode = true.obs;

  @override
  void onInit() {
    super.onInit();
    final isDarkModeString = localStorage.getItem('isDarkMode');
    if (isDarkModeString != null) {
      isDarkMode.value = isDarkModeString == 'true';
    } else {
      isDarkMode.value = true;
      localStorage.setItem('isDarkMode', 'true');
    }
  }

  void changeTheme(bool dark) {
    isDarkMode.value = dark;
    localStorage.setItem('isDarkMode', dark.toString());
  }
}
