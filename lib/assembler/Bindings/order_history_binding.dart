import 'package:get/get.dart';
import 'package:voxtrade_core/assembler/Controller/OrderHistory.dart';

class OrderHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OrderHistoryController(), fenix: true);
  }
}
