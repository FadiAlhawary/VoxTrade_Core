import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/ModelDto/TradeHistoryDTO.dart';
import 'package:voxtrade_core/assembler/Controller/User_&_Auth/User_Controller.dart';
import 'package:voxtrade_core/assembler/Services/TradeServices.dart';

class TradeHistoryController extends GetxController {
  final RxList<TradeHistory> trades = <TradeHistory>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);

  int get _userId => Get.find<UserController>().user.value?.id ?? 0;

  /// Called from [TradesPage] `initState` (and pull-to-refresh / retry).
  Future<void> fetchTrades() async {
    debugPrint('API CALLED');
    try {
      isLoading.value = true;
      errorMessage.value = null;
      final data = await getTradeHistory(_userId);
      trades.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
