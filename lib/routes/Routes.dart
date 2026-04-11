import 'package:get/get.dart';
import 'package:voxtrade_core/Components/AppSell/AppShell.dart';
import 'package:voxtrade_core/pages/Home_page.dart';
import 'package:voxtrade_core/pages/Sign_In_page.dart';
import 'package:voxtrade_core/pages/Sign_Up_page.dart';
import 'package:voxtrade_core/pages/test.dart';

part 'string.dart';

class Routes {
  static List<GetPage> routes = [
    GetPage(name: RouteStrings.root, page: () => AppShell()),
    // GetPage(name: RouteStrings.root, page: () => const SignInPage()),
    GetPage(name: RouteStrings.appShell, page: () => const AppShell()),
    GetPage(name: RouteStrings.signIn, page: () => const SignInPage()),
    GetPage(name: RouteStrings.signUp, page: () => const SignUpPage()),
    GetPage(name: RouteStrings.home, page: () => HomePage()),
    GetPage(name: RouteStrings.test, page: () => Test()),
  ];
}
