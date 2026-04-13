import 'package:get/get.dart';
import 'package:voxtrade_core/assembler/Controller/NewsController.dart';

class HomePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NewsController());
  }
}
