import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/Dashboard/ProfitLossChart.dart';
import 'package:voxtrade_core/Components/Dashboard/WalletHistoryChart.dart';
import 'package:voxtrade_core/assembler/Controller/PortfolioController.dart';
import 'package:voxtrade_core/assembler/Controller/Wallet_Controller.dart';

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({super.key});

  @override
  State<StatefulWidget> createState() => DashBoardPageState();
}

class DashBoardPageState extends State<DashBoardPage> {
  final WalletController walletController = Get.find<WalletController>();
  final PortfolioController portfolioController = Get.find<PortfolioController>();
  late final DateTime _fromDate;
  late final DateTime _toDate;

  @override
  void initState() {
    super.initState();
    _toDate = DateTime.now();
    _fromDate = _toDate.subtract(const Duration(days: 6));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      walletController.fetchWalletHistoryWithDate(_fromDate, _toDate);
      portfolioController.fetchProfitLossChart(_fromDate, _toDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            SizedBox(
              height: 320,
              child: Obx(
                () => WalletHistoryChart(
                  history: walletController.walletHistory.toList(growable: false),
                  isLoading: walletController.isLoading.value,
                  fromDate: _fromDate,
                  toDate: _toDate,
                  title: 'Wallet History (7 days)',
                  onRefresh:
                      () => walletController.fetchWalletHistoryWithDate(
                        _fromDate,
                        _toDate,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 340,
              child: Obx(
                () => ProfitLossChart(
                  points: portfolioController.profitLossChart.toList(
                    growable: false,
                  ),
                  isLoading: portfolioController.isLoadingProfitLossChart.value,
                  title: 'Profit / Loss (7 days)',
                  onRefresh:
                      () => portfolioController.fetchProfitLossChart(
                        _fromDate,
                        _toDate,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
