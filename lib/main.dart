import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/routes/Routes.dart';


void main() {
  //Get.put(UIThemesController());
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
 // final themeController = Get.find<UIThemesController>();

  @override
  void initState() {
    super.initState();
  //  themeController.loadThemes(); // purposeId
  }
  @override
  Widget build(BuildContext context) {
   // return Obx((){
      //final themeList = themeController.themes.value;
      //    if(themeList==null || themeList.isEmpty || themeList.first.style ==null)
      //          return Loader();

     // final style = themeList.first.style!;
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF0A1AFF),
            secondary: Color(0xFF00E5A0),
            surface: Color(0xFF0D1117),
            //background: Color(0xFF0D1117),
            onPrimary: Colors.white,
            onSecondary: Colors.black,
          ),


          // filledButtonTheme: FilledButtonThemeData(
          //   style: FilledButton.styleFrom(
          //     backgroundColor: Color(0xFF4988C4),
          //     foregroundColor: Colors.white,
          //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //     textStyle: const TextStyle(
          //       fontWeight: FontWeight.bold,
          //       fontSize: 16,
          //     ),
          //   ),
          // ),
          // elevatedButtonTheme: ElevatedButtonThemeData(
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Color(0xFFFF0000),
          //     foregroundColor: Colors.white,
          //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //     textStyle: const TextStyle(
          //       fontWeight: FontWeight.bold,
          //       fontSize: 16,
          //     ),
          //   ),
          // ),
          // outlinedButtonTheme: OutlinedButtonThemeData(
          //   style: ElevatedButton.styleFrom(
          //
          //
          //     foregroundColor: Colors.white,
          //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //     textStyle: const TextStyle(
          //       fontWeight: FontWeight.bold,
          //       fontSize: 16,
          //     ),
          //   ),
          // ),

        //   textTheme: const TextTheme(
        //     bodyMedium: TextStyle(color: Colors.white),
        //     titleLarge: TextStyle(fontWeight: FontWeight.bold),
        //   ),
         ),
        initialRoute: RouteStrings.root,
        getPages: Routes.routes,
      );
   // });
  }
}
