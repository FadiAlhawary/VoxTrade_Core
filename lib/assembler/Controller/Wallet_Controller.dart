import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/ModelDto/WalletDTO.dart';
import 'package:voxtrade_core/Components/ModelDto/WalletHistoryDTO.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/Models/wallet_activity_models.dart';
import 'package:voxtrade_core/assembler/Controller/User_&_Auth/User_Controller.dart';
import 'package:voxtrade_core/assembler/Services/Wallet_Services.dart';
import 'package:voxtrade_core/assembler/common/wallet_guards.dart';
import 'package:voxtrade_core/assembler/Controller/Payment_Method_Controller.dart';
import 'package:voxtrade_core/pages/Wallet_History_Page.dart';
import 'package:voxtrade_core/pages/Transfer_Money_Page.dart';

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
  int get _userId => Get.find<UserController>().user.value?.id ?? 0;
  RxBool isLoading = false.obs;
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
    // Loaded when the Wallet tab becomes visible.
  }

  Future<void> fetchWallet({bool withHistory = true}) async {
    try {
      isLoading.value = true;
      final id = _userId;
      if (id == 0) return;
      final data = await getWallet(id, withHistory);
      wallet.value = data;
    } catch (e) {
      SnackBarComp.showError(e, title: 'Wallet unavailable');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<int>> getWalletHistoryWithDateForChart(
    DateTime from,
    DateTime to,
  ) async {
    try {
      final id = _userId;
      if (id == 0) return [];
      final data = await getWalletHistoryWithDate(id, from, to);
      return _buildDailyCounts(data, from, to);
    } catch (e) {
      SnackBarComp.showError(e, title: 'Wallet history unavailable');
      return [];
    }
  }

  Future<void> fetchWalletHistoryWithDate(DateTime from, DateTime to) async {
    try {
      isLoading.value = true;
      final id = _userId;
      if (id == 0) return;
      final data = await getWalletHistoryWithDate(id, from, to);
      walletHistory.value = data;
      walletHistoryForChart.value = _buildDailyCounts(data, from, to);
    } catch (e) {
      SnackBarComp.showError(e, title: 'Wallet history unavailable');
    } finally {
      isLoading.value = false;
    }
  }

  PaymentMethodController get _paymentMethods =>
      Get.find<PaymentMethodController>();

  void addPaymentMethod() {
    _paymentMethods.openAddPaymentMethodPage();
  }

  void openPaymentMethods() {
    _paymentMethods.openPaymentMethodsPage();
  }

  Future<void> refreshWalletData() async {
    await Future.wait([
      fetchWallet(),
      _paymentMethods.fetchUserPaymentMethods(),
    ]);
  }

  void openFullWalletHistory() {
    Get.to(() => const WalletHistoryPage());
  }

  void openTransferMoney() {
    if (!ensureWalletCanTransact(wallet.value)) return;
    final navContext = Get.context;
    if (navContext == null) return;
    Navigator.of(navContext, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const TransferMoneyPage()),
    );
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
