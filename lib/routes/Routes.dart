import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/AppSell/AppShell.dart';
import 'package:voxtrade_core/assembler/Bindings/AppShellBinding.dart';
import 'package:voxtrade_core/assembler/Bindings/order_history_binding.dart';
import 'package:voxtrade_core/assembler/Bindings/trade_history_binding.dart';
import 'package:voxtrade_core/pages/DashBoard_page.dart';
import 'package:voxtrade_core/pages/Home_page.dart';
import 'package:voxtrade_core/pages/Market_Buy_Sell_Entry.dart';
import 'package:voxtrade_core/pages/Orders_Page.dart';
import 'package:voxtrade_core/pages/Portfolio_Page.dart';
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
        if (args is int) {
          return MarketBuySellEntryPage(instrumentId: args);
        }
        return const Scaffold(
          body: Center(child: Text('Invalid instrument ID')),
        );
      },
    ),
    GetPage(
      name: RouteStrings.portfolio,
      page: () => const PortfolioPage(),
      binding: TradeHistoryBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: RouteStrings.orders,
      page: () => const OrdersPage(),
      binding: OrderHistoryBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(name: RouteStrings.dashBoard, page: () => const DashBoardPage()),
  ];
}
