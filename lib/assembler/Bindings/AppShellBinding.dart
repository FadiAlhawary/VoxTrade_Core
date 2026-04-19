import 'package:get/get.dart';
import 'package:voxtrade_core/assembler/Controller/NewsController.dart';
import 'package:voxtrade_core/assembler/Controller/OrderHistory.dart';
import 'package:voxtrade_core/assembler/Controller/TradeHistoryController.dart';
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
    if (!Get.isRegistered<TradeHistoryController>()) {
      Get.lazyPut(() => TradeHistoryController(), fenix: true);
    }
    if (!Get.isRegistered<OrderHistoryController>()) {
      Get.lazyPut(() => OrderHistoryController(), fenix: true);
    }
  }
}
