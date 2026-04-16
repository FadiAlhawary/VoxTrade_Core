import 'package:get/get.dart';
import 'package:voxtrade_core/Components/AppSell/AppShell.dart';
import 'package:voxtrade_core/assembler/Bindings/HomePageBinding.dart';
import 'package:voxtrade_core/pages/Home_page.dart';
import 'package:voxtrade_core/pages/Market_Buy_Sell.dart';
import 'package:voxtrade_core/pages/Sign_In_page.dart';
import 'package:voxtrade_core/pages/Sign_Up_page.dart';
import 'package:voxtrade_core/pages/Markets.dart';

part 'string.dart';

class Routes {
  static List<GetPage> routes = [
    GetPage(
      name: RouteStrings.root,
      page: () => AppShell(),
      binding: HomePageBinding(),
    ),
    // GetPage(name: RouteStrings.root, page: () => const SignInPage()),
    GetPage(name: RouteStrings.appShell, page: () => const AppShell()),
    GetPage(name: RouteStrings.signIn, page: () => const SignInPage()),
    GetPage(name: RouteStrings.signUp, page: () => const SignUpPage()),
    GetPage(name: RouteStrings.home, page: () => HomePage()),
    GetPage(name: RouteStrings.markets, page: () => Markets()),
    GetPage(
      name: RouteStrings.marketBuySell,
      page: () {
        final args = Get.arguments;
        final symbol =
            args is String && args.isNotEmpty ? args : 'BINANCE:BTCUSDT';
        return MarketBuySell(symbol: symbol);
      },
    ),
  ];
}
