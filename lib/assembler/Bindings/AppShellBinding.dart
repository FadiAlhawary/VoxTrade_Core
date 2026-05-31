import 'package:get/get.dart';
import 'package:voxtrade_core/assembler/Controller/Dashboard_Controller.dart';
import 'package:voxtrade_core/assembler/Controller/Instrument_Controller.dart';
import 'package:voxtrade_core/assembler/Controller/MarketController.dart';
import 'package:voxtrade_core/assembler/Controller/NewsController.dart';
import 'package:voxtrade_core/assembler/Controller/Payment_Method_Controller.dart';
import 'package:voxtrade_core/assembler/Controller/PortfolioController.dart';
import 'package:voxtrade_core/assembler/Controller/Wallet_Controller.dart';

class AppShellBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<NewsController>()) {
      Get.lazyPut(() => NewsController(), fenix: true);
    }
    if (!Get.isRegistered<WalletController>()) {
      Get.lazyPut(() => WalletController(), fenix: true);
    }
    if (!Get.isRegistered<PaymentMethodController>()) {
      Get.lazyPut(() => PaymentMethodController(), fenix: true);
    }
    if (!Get.isRegistered<InstrumentController>()) {
      Get.lazyPut(() => InstrumentController(), fenix: true);
    }
    if (!Get.isRegistered<MarketController>()) {
      Get.lazyPut(() => MarketController(), fenix: true);
    }
    if (!Get.isRegistered<PortfolioController>()) {
      Get.lazyPut(() => PortfolioController(), fenix: true);
    }
    if (!Get.isRegistered<DashboardController>()) {
      Get.lazyPut(() => DashboardController(), fenix: true);
    }
  }
}
