import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/Dashboard/ProfitLossChart.dart';
import 'package:voxtrade_core/Components/Dashboard/WalletHistoryChart.dart';
import 'package:voxtrade_core/assembler/Controller/NavBarController.dart';
import 'package:voxtrade_core/assembler/Controller/ThemeController.dart';
import 'package:voxtrade_core/assembler/Controller/PortfolioController.dart';
import 'package:voxtrade_core/assembler/Controller/Wallet_Controller.dart';
import 'package:voxtrade_core/routes/route_names.dart';

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({super.key});

  @override
  State<StatefulWidget> createState() => DashBoardPageState();
}

class DashBoardPageState extends State<DashBoardPage> {
  static const int _dashboardTabIndex = 3;

  final WalletController walletController = Get.find<WalletController>();
  final PortfolioController portfolioController =
      Get.find<PortfolioController>();
  late DateTime _fromDate;
  late DateTime _toDate;
  bool _wasDashboardTabVisible = false;

  @override
  void initState() {
    super.initState();
    _updateDateRange();
  }

  void _updateDateRange() {
    _toDate = DateTime.now();
    _fromDate = _toDate.subtract(const Duration(days: 6));
  }

  bool _isDashboardVisible(NavBarController navController) {
    return navController.tabIndex == _dashboardTabIndex ||
        Get.currentRoute == RouteStrings.dashBoard;
  }

  Future<void> _refreshDashboardData() async {
    if (!mounted) return;
    setState(_updateDateRange);
    await Future.wait([
      walletController.fetchWalletHistoryWithDate(_fromDate, _toDate),
      portfolioController.fetchProfitLossChart(_fromDate, _toDate),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<NavBarController>();
    final themeController = Get.find<ThemeController>();

    return GetBuilder<NavBarController>(
      builder: (_) {
        final isDashboardVisible = _isDashboardVisible(navController);
        if (isDashboardVisible && !_wasDashboardTabVisible) {
          _wasDashboardTabVisible = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _refreshDashboardData();
          });
        } else if (!isDashboardVisible) {
          _wasDashboardTabVisible = false;
        }

        return Obx(() {
          themeController.isDarkMode.value;
          return Scaffold(
          appBar: AppBar(title: const Text('Dashboard')),
          body: RefreshIndicator(
            onRefresh: _refreshDashboardData,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: 320,
                    child: Obx(
                      () => WalletHistoryChart(
                        history: walletController.walletHistory.toList(
                          growable: false,
                        ),
                        isLoading: walletController.isLoading.value,
                        fromDate: _fromDate,
                        toDate: _toDate,
                        title: 'Wallet History (7 days)',
                        onRefresh: _refreshDashboardData,
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
                        isLoading:
                            portfolioController.isLoadingProfitLossChart.value,
                        title: 'Profit / Loss (7 days)',
                        onRefresh: _refreshDashboardData,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        });
      },
    );
  }
}
