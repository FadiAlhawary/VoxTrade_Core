import 'package:get/get.dart';
import 'package:voxtrade_core/Components/ModelDto/WalletDTO.dart';
import 'package:voxtrade_core/Components/ModelDto/WalletHistoryDTO.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/Models/wallet_activity_models.dart';
import 'package:voxtrade_core/assembler/Controller/User_&_Auth/User_Controller.dart';
import 'package:voxtrade_core/assembler/Services/Wallet_Services.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';
import 'package:voxtrade_core/pages/Wallet_History_Page.dart';
import 'package:voxtrade_core/routes/route_names.dart';

class WalletController extends GetxController {
  Rx<WalletDto> wallet =
      WalletDto(
        id: 0,
        userId: 0,
        currencyId: 0,
        balance: 0,
        availableBalance: 0,
        reservedBalance: 0,
        status: true,
        updatedAt: DateTime.now(),
        walletHistory: [],
      ).obs;
  final int userId = Get.find<UserController>().user.value?.id ?? 0;
  RxBool isLoading = false.obs;
  bool _didFetchHistory = false;
  RxList<WalletHistoryDto> walletHistory = <WalletHistoryDto>[].obs;
  RxList<int> walletHistoryForChart = <int>[].obs;

  List<WalletActivityTransaction> get recentWalletActivity {
    final list =
        wallet.value.walletHistory
            .map(WalletActivityTransaction.fromDto)
            .toList();
    list.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return list;
  }

  @override
  void onInit() {
    super.onInit();
    if (!_didFetchHistory) {
      _didFetchHistory = true;
      fetchWallet();
    }
  }

  Future<void> fetchWallet({bool withHistory = true}) async {
    try {
      isLoading.value = true;
      final data = await getWallet(userId, withHistory);
      wallet.value = data;
    } catch (e) {
      SnackBarComp.show(
        e.toString(),
        title: "Error while fetching wallet",
        status: SnackBarCompStatus.danger,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<int>> getWalletHistoryWithDateForChart(
    DateTime from,
    DateTime to,
  ) async {
    try {
      final data = await getWalletHistoryWithDate(userId, from, to);
      return _buildDailyCounts(data, from, to);
    } catch (e) {
      SnackBarComp.show(
        e.toString(),
        title: "Error while fetching wallet history with date for chart",
        status: SnackBarCompStatus.danger,
      );
      return [];
    }
  }

  Future<void> fetchWalletHistoryWithDate(DateTime from, DateTime to) async {
    try {
      isLoading.value = true;
      final data = await getWalletHistoryWithDate(userId, from, to);
      walletHistory.value = data;
      walletHistoryForChart.value = _buildDailyCounts(
        data,
        from,
        to,
      );
    } catch (e) {
      SnackBarComp.show(
        e.toString(),
        title: "Error while fetching wallet history with date",
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
    Get.toNamed(RouteStrings.orders);
  }

  void viewTradeHistory() {
    Get.toNamed(RouteStrings.portfolio);
  }

  List<int> _buildDailyCounts(
    List<WalletHistoryDto> history,
    DateTime from,
    DateTime to,
  ) {
    final startUtc = DateTime.utc(from.year, from.month, from.day);
    final endUtc = DateTime.utc(to.year, to.month, to.day);
    final normalizedStart = startUtc.isBefore(endUtc) ? startUtc : endUtc;
    final normalizedEnd = startUtc.isBefore(endUtc) ? endUtc : startUtc;

    final totalDays = normalizedEnd.difference(normalizedStart).inDays + 1;
    final perDayCount = <DateTime, int>{
      for (var i = 0; i < totalDays; i++)
        normalizedStart.add(Duration(days: i)): 0,
    };

    for (final item in history) {
      final transactionDayUtc = DateTime.utc(
        item.createdAt.year,
        item.createdAt.month,
        item.createdAt.day,
      );
      if (transactionDayUtc.isBefore(normalizedStart) ||
          transactionDayUtc.isAfter(normalizedEnd)) {
        continue;
      }
      perDayCount[transactionDayUtc] =
          (perDayCount[transactionDayUtc] ?? 0) + 1;
    }

    final chartData = <int>[];
    var cursor = normalizedStart;
    while (!cursor.isAfter(normalizedEnd)) {
      chartData.add(perDayCount[cursor] ?? 0);
      cursor = cursor.add(const Duration(days: 1));
    }

    return chartData;
  }
}
