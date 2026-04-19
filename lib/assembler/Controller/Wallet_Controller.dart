import 'package:get/get.dart';
import 'package:voxtrade_core/Components/ModelDto/WalletHistoryDTO.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/Models/wallet_activity_models.dart';
import 'package:voxtrade_core/assembler/Controller/User_&_Auth/User_Controller.dart';
import 'package:voxtrade_core/assembler/Services/Wallet_Services.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';
import 'package:voxtrade_core/pages/Orders_Page.dart';
import 'package:voxtrade_core/pages/Trades_Page.dart';
import 'package:voxtrade_core/pages/Wallet_History_Page.dart';

class WalletController extends GetxController {
  RxList<WalletHistoryDto> walletHistory = <WalletHistoryDto>[].obs;
  final int userId = Get.find<UserController>().user.value?.id ?? 0;
  RxBool isLoading = false.obs;
  bool _didFetchHistory = false;

  /// Latest balance from history (by [WalletHistoryDto.createdAt]); 0 if empty.
  final RxDouble totalBalance = 0.0.obs;
  /// Until the API exposes splits, mirrors latest [balanceAfter] minus reserved.
  final RxDouble availableToTrade = 0.0.obs;
  /// Placeholder until wallet/order API returns reserved funds.
  final RxDouble reservedInOrders = 0.0.obs;

  List<WalletActivityTransaction> get recentWalletActivity {
    final list =
        walletHistory.map(WalletActivityTransaction.fromDto).toList();
    list.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return list;
  }

  void _recomputeBalancesFromHistory() {
    if (walletHistory.isEmpty) {
      totalBalance.value = 0;
      reservedInOrders.value = 0;
      availableToTrade.value = 0;
      return;
    }
    final sorted = [...walletHistory]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final latest = sorted.first;
    totalBalance.value = latest.balanceAfter;
    reservedInOrders.value = 0;
    availableToTrade.value = latest.balanceAfter;
  }

  @override
  void onInit() {
    super.onInit();
    if (!_didFetchHistory) {
      _didFetchHistory = true;
      fetchWalletHistory();
    }
  }

  Future<void> fetchWalletHistory() async {
    try {
      isLoading.value = true;
      final data = await getWalletHistory(userId);
      walletHistory.value = data;
      _recomputeBalancesFromHistory();
    } catch (e) {
      SnackBarComp.show(
        e.toString(),
        title: "Error while fetching wallet history",
        status: SnackBarCompStatus.danger,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void addPaymentMethod() {
    SnackBarComp.show(
      'Payment method linking will be available soon.',
      title: 'Coming soon',
      status: SnackBarCompStatus.warning,
    );
  }

  void openFullWalletHistory() {
    Get.to(() => const WalletHistoryPage());
  }

  void viewOrderHistory() {
    Get.to(() => const OrdersPage());
  }

  void viewTradeHistory() {
    Get.to(() => const TradesPage());
  }
}
