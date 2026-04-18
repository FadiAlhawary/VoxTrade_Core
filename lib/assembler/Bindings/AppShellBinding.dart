import 'package:get/get.dart';
import 'package:voxtrade_core/assembler/Controller/NewsController.dart';

class AppShellBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<NewsController>()) {
      Get.lazyPut(() => NewsController(), fenix: true);
    }
  }
}
