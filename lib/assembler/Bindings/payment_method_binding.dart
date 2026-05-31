import 'package:get/get.dart';
import 'package:voxtrade_core/assembler/Controller/Payment_Method_Controller.dart';

class PaymentMethodBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PaymentMethodController>()) {
      Get.lazyPut(() => PaymentMethodController(), fenix: true);
    }
  }
}
