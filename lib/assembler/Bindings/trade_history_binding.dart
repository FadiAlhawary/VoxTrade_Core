import 'package:get/get.dart';
import 'package:voxtrade_core/assembler/Controller/TradeHistoryController.dart';

class TradeHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TradeHistoryController(), fenix: true);
  }
}
