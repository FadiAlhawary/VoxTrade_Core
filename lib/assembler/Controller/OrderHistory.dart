import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/ModelDto/OrderHistoryDTO.dart';
import 'package:voxtrade_core/assembler/Controller/User_&_Auth/User_Controller.dart';
import 'package:voxtrade_core/assembler/Services/OrderServices.dart' as order_api;

class OrderHistoryController extends GetxController {
  final RxList<OrderHistory> orders = <OrderHistory>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);

  int get _userId => Get.find<UserController>().user.value?.id ?? 0;

  /// Called from [OrdersPage] `initState` (and pull-to-refresh / retry).
  Future<void> fetchOrders({bool activeOnly = false}) async {
    debugPrint('API CALLED');
    try {
      isLoading.value = true;
      errorMessage.value = null;
      final data = await order_api.getTradeHistory(_userId, activeOnly);
      orders.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
