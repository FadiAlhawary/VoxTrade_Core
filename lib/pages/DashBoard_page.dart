import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/Dashboard/ProfitLossChart.dart';
import 'package:voxtrade_core/Components/Dashboard/UserDashboardCharts.dart';
import 'package:voxtrade_core/Components/Dashboard/WalletHistoryChart.dart';
import 'package:voxtrade_core/Components/ModelDto/DashboardDtos.dart';
import 'package:voxtrade_core/assembler/Controller/Dashboard_Controller.dart';
import 'package:voxtrade_core/assembler/Controller/NavBarController.dart';
import 'package:voxtrade_core/assembler/Controller/ThemeController.dart';
import 'package:voxtrade_core/assembler/Controller/PortfolioController.dart';
import 'package:voxtrade_core/assembler/Controller/Wallet_Controller.dart';
import 'package:voxtrade_core/routes/route_names.dart';
import 'package:voxtrade_core/Components/shimer/page_loading_shimmers.dart';
import 'package:voxtrade_core/utils/chart_theme_helpers.dart';

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({super.key});

  @override
  State<StatefulWidget> createState() => DashBoardPageState();
}

class DashBoardPageState extends State<DashBoardPage> {
  static const int _dashboardTabIndex = 3;

  late final DashboardController dashboardController;
  final WalletController walletController = Get.find<WalletController>();
  final PortfolioController portfolioController =
      Get.find<PortfolioController>();
  late DateTime _fromDate;
  late DateTime _toDate;
  bool _wasDashboardTabVisible = false;

  @override
  void initState() {
    super.initState();
    dashboardController = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());
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
      dashboardController.refreshDashboard(),
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
              child: Obx(() {
                final isLoading = dashboardController.isLoadingSummary.value;
                final summary = dashboardController.summary.value;
                final activity = dashboardController.recentActivity.toList(
                  growable: false,
                );

                if (isLoading && summary == null) {
                  return const DashboardPageShimmer();
                }

                if (summary == null) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.5,
                        child: Center(
                          child: TextButton(
                            onPressed: dashboardController.fetchSummary,
                            child: const Text('Retry loading dashboard'),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 720;
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        _OverviewHeader(data: summary),
                        if (summary.wallet.isFrozen) ...[
                          const SizedBox(height: 10),
                          _FrozenWalletBanner(),
                        ],
                        const SizedBox(height: 14),
                        _PrimaryKpiRow(data: summary),
                        const SizedBox(height: 14),
                        if (wide)
                          SizedBox(
                            height: 260,
                            child: Row(
                              children: [
                                Expanded(
                                  child: UserDashboardChartCard(
                                    title: 'Portfolio mix',
                                    subtitle: formatDashboardMoney(
                                      summary.totalPortfolioValue,
                                      summary.wallet.currencySymbol,
                                    ),
                                    legend: UserDashboardChartLegend(
                                      items: [
                                        UserLegendItem(
                                          label: 'Cash',
                                          value: formatDashboardMoney(
                                            summary.wallet.availableBalance,
                                            summary.wallet.currencySymbol,
                                          ),
                                          color: const Color(0xFF42A5F5),
                                        ),
                                        UserLegendItem(
                                          label: 'Positions',
                                          value: formatDashboardMoney(
                                            summary.positions.totalMarketValue,
                                            summary.wallet.currencySymbol,
                                          ),
                                          color: const Color(0xFF7E57C2),
                                        ),
                                      ],
                                    ),
                                    child: UserPortfolioAllocationDonut(
                                      data: summary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: UserDashboardChartCard(
                                    title: 'Wallet balances',
                                    subtitle: 'Available vs reserved funds',
                                    child: UserWalletBalanceBar(data: summary),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          SizedBox(
                            height: 260,
                            child: UserDashboardChartCard(
                              title: 'Portfolio mix',
                              subtitle: formatDashboardMoney(
                                summary.totalPortfolioValue,
                                summary.wallet.currencySymbol,
                              ),
                              child: UserPortfolioAllocationDonut(data: summary),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 260,
                            child: UserDashboardChartCard(
                              title: 'Wallet balances',
                              subtitle: 'Available vs reserved funds',
                              child: UserWalletBalanceBar(data: summary),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        if (wide)
                          SizedBox(
                            height: 260,
                            child: Row(
                              children: [
                                Expanded(
                                  child: UserDashboardChartCard(
                                    title: 'Order status',
                                    subtitle: '${summary.orders.total} total · ${summary.orders.active} active',
                                    legend: UserDashboardChartLegend(
                                      items: [
                                        UserLegendItem(
                                          label: 'Pending',
                                          value: '${summary.orders.pending}',
                                          color: const Color(0xFFFFB74D),
                                        ),
                                        UserLegendItem(
                                          label: 'Filled',
                                          value: '${summary.orders.filled}',
                                          color: const Color(0xFF66BB6A),
                                        ),
                                        UserLegendItem(
                                          label: 'Cancelled',
                                          value: '${summary.orders.cancelled}',
                                          color: const Color(0xFFEF5350),
                                        ),
                                      ],
                                    ),
                                    child: UserOrderStatusDonut(data: summary),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: UserDashboardChartCard(
                                    title: 'Positions & P/L',
                                    subtitle:
                                        '${summary.positions.positionCount} open positions',
                                    child: UserPositionsPnlBar(data: summary),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          SizedBox(
                            height: 260,
                            child: UserDashboardChartCard(
                              title: 'Order status',
                              subtitle: '${summary.orders.total} total orders',
                              child: UserOrderStatusDonut(data: summary),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 260,
                            child: UserDashboardChartCard(
                              title: 'Positions & P/L',
                              subtitle:
                                  '${summary.positions.positionCount} open positions',
                              child: UserPositionsPnlBar(data: summary),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        if (wide)
                          SizedBox(
                            height: 240,
                            child: Row(
                              children: [
                                Expanded(
                                  child: UserDashboardChartCard(
                                    title: 'Trade activity',
                                    subtitle: 'All-time vs last 7 days',
                                    child: UserTradesSummaryBar(data: summary),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: UserDashboardChartCard(
                                    title: 'Recent activity mix',
                                    subtitle: 'Orders, trades & wallet events',
                                    child: UserActivityTypeBarChart(
                                      items: activity,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          SizedBox(
                            height: 240,
                            child: UserDashboardChartCard(
                              title: 'Trade activity',
                              subtitle: 'All-time vs last 7 days',
                              child: UserTradesSummaryBar(data: summary),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 240,
                            child: UserDashboardChartCard(
                              title: 'Recent activity mix',
                              subtitle: 'Orders, trades & wallet events',
                              child: UserActivityTypeBarChart(items: activity),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 320,
                          child: WalletHistoryChart(
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
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 340,
                          child: ProfitLossChart(
                            points: portfolioController.profitLossChart.toList(
                              growable: false,
                            ),
                            isLoading:
                                portfolioController
                                    .isLoadingProfitLossChart
                                    .value,
                            title: 'Profit / Loss (7 days)',
                            onRefresh: _refreshDashboardData,
                          ),
                        ),
                      ],
                    );
                  },
                );
              }),
            ),
          );
        });
      },
    );
  }
}

class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader({required this.data});

  final UserDashboardSummaryDto data;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = dashboardChartMutedText(context);
    final name =
        data.firstNameEn.isNotEmpty ? data.firstNameEn : data.username;

    return Container(
      decoration: dashboardChartCardDecoration(context),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, $name',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.positions.positionCount} positions · ${data.orders.active} active orders · ${data.tradesLast7Days} trades this week',
                  style: TextStyle(fontSize: 13, color: muted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.pie_chart_outline_rounded,
                  size: 16,
                  color: scheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  formatDashboardMoney(
                    data.totalPortfolioValue,
                    data.wallet.currencySymbol,
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryKpiRow extends StatelessWidget {
  const _PrimaryKpiRow({required this.data});

  final UserDashboardSummaryDto data;

  @override
  Widget build(BuildContext context) {
    final currency = data.wallet.currencySymbol;

    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          SizedBox(
            width: 168,
            child: UserDashboardKpiCard(
              label: 'Portfolio',
              value: formatDashboardMoney(
                data.totalPortfolioValue,
                currency,
              ),
              icon: Icons.account_balance_wallet_outlined,
              accentColor: const Color(0xFF42A5F5),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 168,
            child: UserDashboardKpiCard(
              label: 'Available cash',
              value: formatDashboardMoney(
                data.wallet.availableBalance,
                currency,
              ),
              icon: Icons.savings_outlined,
              accentColor: const Color(0xFF66BB6A),
              subtitle:
                  '${formatDashboardMoney(data.wallet.reservedBalance, currency)} reserved',
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 168,
            child: UserDashboardKpiCard(
              label: 'Positions',
              value: '${data.positions.positionCount}',
              icon: Icons.candlestick_chart_outlined,
              accentColor: const Color(0xFF7E57C2),
              subtitle: formatDashboardMoney(
                data.positions.totalMarketValue,
                currency,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 168,
            child: UserDashboardKpiCard(
              label: 'Unrealized P/L',
              value: formatDashboardMoney(
                data.positions.totalUnrealizedPnl.abs(),
                currency,
              ),
              icon: Icons.trending_up_rounded,
              accentColor:
                  data.positions.totalUnrealizedPnl >= 0
                      ? const Color(0xFF26A69A)
                      : const Color(0xFFEF5350),
              subtitle:
                  data.positions.totalUnrealizedPnl >= 0 ? 'In profit' : 'In loss',
            ),
          ),
        ],
      ),
    );
  }
}

class _FrozenWalletBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: dashboardChartCardDecoration(context).copyWith(
        border: Border.all(color: Colors.orange.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Icon(Icons.ac_unit_rounded, size: 18, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Wallet is frozen — transfers and trading are disabled.',
              style: TextStyle(color: Colors.orange.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
