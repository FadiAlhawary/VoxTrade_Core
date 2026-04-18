import 'package:get/get.dart';
import 'package:voxtrade_core/Components/AppSell/AppShell.dart';
import 'package:voxtrade_core/assembler/Bindings/AppShellBinding.dart';
import 'package:voxtrade_core/pages/Home_page.dart';
import 'package:voxtrade_core/pages/Market_Buy_Sell.dart';
import 'package:voxtrade_core/pages/Sign_In_page.dart';
import 'package:voxtrade_core/pages/Sign_Up_page.dart';
import 'package:voxtrade_core/pages/Markets.dart';
import 'package:voxtrade_core/pages/Splash_page.dart';
import 'package:voxtrade_core/routes/auth_middleware.dart';
import 'package:voxtrade_core/routes/route_names.dart';

class Routes {
  static List<GetPage> routes = [
    GetPage(name: RouteStrings.splash, page: () => const SplashPage()),
    GetPage(
      name: RouteStrings.root,
      page: () => AppShell(),
      binding: AppShellBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: RouteStrings.appShell,
      page: () => const AppShell(),
      binding: AppShellBinding(),
      middlewares: [AuthMiddleware()],
    ),
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
