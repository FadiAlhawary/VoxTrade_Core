import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:localstorage/localstorage.dart';
import 'package:voxtrade_core/assembler/Controller/ThemeController.dart';
import 'package:voxtrade_core/assembler/Controller/User_&_Auth/User_Controller.dart';
import 'package:voxtrade_core/assembler/Services/market_socket_service.dart';
import 'package:voxtrade_core/routes/Routes.dart';
import 'package:voxtrade_core/routes/route_names.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalStorage(); // required before using localStorage
  await GetStorage.init();
  await Get.putAsync(() => MarketSocketService().init());
  Get.put(ThemeController(), permanent: true);
  Get.put(UserController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static ThemeData _lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0A1AFF),
        secondary: Color(0xFF00E5A0),
        surface: Color(0xFFFFFFFF),
        onSecondary: Colors.white,
        onPrimary: Colors.black,
      ),
    );
  }

  static ThemeData _darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF5B6FFF),
        secondary: Color(0xFF00E5A0),
        surface: Color(0xFF0D1117),
        onSecondary: Colors.white,
        onPrimary: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _lightTheme(),
        darkTheme: _darkTheme(),
        themeMode:
            themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        initialRoute: RouteStrings.root,
        getPages: Routes.routes,
      ),
    );
  }
}
