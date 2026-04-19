import 'package:get/get.dart';
import 'package:voxtrade_core/Components/ModelDto/OrderHistoryDTO.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/assembler/Controller/User_&_Auth/User_Controller.dart';
import 'package:voxtrade_core/assembler/Services/OrderServices.dart'
    as order_api;
import 'package:voxtrade_core/assembler/common/enum.dart';

class OrderHistoryController extends GetxController {
  final RxList<OrderHistory> orders = <OrderHistory>[].obs;

  /// True while [fetchOrders] is in flight.
  final RxBool isLoading = false.obs;

  final Rx<String?> errorMessage = Rx<String?>(null);

  /// Order IDs currently being cancelled (shows spinner on row).
  final RxInt cancellingOrderId = 0.obs;

  int get _userId => Get.find<UserController>().user.value?.id ?? 0;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders({bool activeOnly = false}) async {
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

  /// Backend cancel; refreshes list on success.
  Future<void> cancelOrder(OrderHistory order) async {
    if (!order.isPendingStatus || !order.canCancel) return;
    if (cancellingOrderId.value == order.id) return;

    try {
      cancellingOrderId.value = order.id;
      final res = await order_api.cancelOrder(order.id, _userId);
      if (!res.success) {
        SnackBarComp.show(
          res.message.isNotEmpty ? res.message : 'Unable to cancel order',
          title: 'Cancel failed',
          status: SnackBarCompStatus.danger,
        );
        return;
      }

      SnackBarComp.show(
        res.message.isNotEmpty ? res.message : 'Done',
        title: 'Order cancelled',
        status: SnackBarCompStatus.success,
      );
      await fetchOrders();
    } catch (e) {
      SnackBarComp.show(
        e.toString(),
        title: 'Error while cancelling order',
        status: SnackBarCompStatus.danger,
      );
    } finally {
      cancellingOrderId.value = 0;
    }
  }
}
