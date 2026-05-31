import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/Admin/AdminDashboardCharts.dart';
import 'package:voxtrade_core/Components/ModelDto/AdminDtos.dart';
import 'package:voxtrade_core/assembler/Controller/Admin_Controller.dart';
import 'package:voxtrade_core/Components/shimer/page_loading_shimmers.dart';
import 'package:voxtrade_core/pages/admin/admin_page_scaffold.dart';
import 'package:voxtrade_core/utils/chart_theme_helpers.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late final AdminController _admin;

  @override
  void initState() {
    super.initState();
    _admin = Get.put(AdminController());
    _admin.loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageScaffold(
      title: 'Admin dashboard',
      body: Obx(() {
        if (_admin.isLoadingDashboard.value) {
          return const AdminDashboardPageShimmer();
        }
        final data = _admin.dashboard.value;
        if (data == null) {
          return Center(
            child: TextButton(
              onPressed: _admin.loadDashboard,
              child: const Text('Retry'),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: _admin.loadDashboard,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 720;
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _OverviewHeader(data: data),
                  const SizedBox(height: 16),
                  _PrimaryKpiRow(data: data),
                  const SizedBox(height: 16),
                  _SecondaryKpiGrid(data: data),
                  const SizedBox(height: 20),
                  if (wide)
                    SizedBox(
                      height: 260,
                      child: Row(
                        children: [
                          Expanded(child: _OrderStatusCard(data: data)),
                          const SizedBox(width: 12),
                          Expanded(child: _UserStatusCard(data: data)),
                        ],
                      ),
                    )
                  else ...[
                    SizedBox(height: 260, child: _OrderStatusCard(data: data)),
                    const SizedBox(height: 12),
                    SizedBox(height: 260, child: _UserStatusCard(data: data)),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 280,
                    child: AdminChartCard(
                      title: 'Trade volume',
                      subtitle: 'Total trade value over the last 7 days',
                      child: AdminTradeVolumeLineChart(
                        trades: _admin.trades.toList(growable: false),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (wide)
                    SizedBox(
                      height: 280,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: AdminChartCard(
                              title: 'Platform overview',
                              subtitle: 'Key entity counts across the system',
                              child: AdminPlatformBarChart(data: data),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: AdminChartCard(
                              title: 'Wallet balances',
                              subtitle: 'Available vs reserved funds',
                              child: AdminWalletBalanceBar(data: data),
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    SizedBox(
                      height: 260,
                      child: AdminChartCard(
                        title: 'Platform overview',
                        subtitle: 'Key entity counts across the system',
                        child: AdminPlatformBarChart(data: data),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 260,
                      child: AdminChartCard(
                        title: 'Wallet balances',
                        subtitle: 'Available vs reserved funds',
                        child: AdminWalletBalanceBar(data: data),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  AdminChartCard(
                    title: 'Recent activity',
                    subtitle: 'Latest admin audit events',
                    expandChild: false,
                    child: AdminRecentActivityList(
                      logs: _admin.auditLogs.toList(growable: false),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }),
    );
  }
}

class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader({required this.data});

  final AdminDashboardDto data;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = dashboardChartMutedText(context);

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
                  'Platform snapshot',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.totalUsers} users · ${data.totalOrders} orders · ${data.totalTrades} trades',
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
                Icon(Icons.account_balance_wallet_outlined, size: 16, color: scheme.primary),
                const SizedBox(width: 6),
                Text(
                  data.totalWalletBalance.toStringAsFixed(2),
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

  final AdminDashboardDto data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          SizedBox(
            width: 168,
            child: AdminKpiCard(
              label: 'Total users',
              value: '${data.totalUsers}',
              icon: Icons.people_outline,
              accentColor: const Color(0xFF42A5F5),
              subtitle: '${data.activeUsers} active',
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 168,
            child: AdminKpiCard(
              label: 'Total orders',
              value: '${data.totalOrders}',
              icon: Icons.receipt_long_outlined,
              accentColor: const Color(0xFF7E57C2),
              subtitle: '${data.pendingOrders} pending',
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 168,
            child: AdminKpiCard(
              label: 'Total trades',
              value: '${data.totalTrades}',
              icon: Icons.swap_horiz,
              accentColor: const Color(0xFF26A69A),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 168,
            child: AdminKpiCard(
              label: 'Instruments',
              value: '${data.activeInstruments}',
              icon: Icons.candlestick_chart_outlined,
              accentColor: const Color(0xFFFF7043),
              subtitle: 'of ${data.totalInstruments} total',
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryKpiGrid extends StatelessWidget {
  const _SecondaryKpiGrid({required this.data});

  final AdminDashboardDto data;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.9,
      children: [
        AdminKpiCard(
          label: 'Locked users',
          value: '${data.lockedUsers}',
          icon: Icons.lock_outline,
          accentColor: const Color(0xFFEF5350),
        ),
        AdminKpiCard(
          label: 'Filled orders',
          value: '${data.filledOrders}',
          icon: Icons.check_circle_outline,
          accentColor: const Color(0xFF66BB6A),
        ),
        AdminKpiCard(
          label: 'Cancelled orders',
          value: '${data.cancelledOrders}',
          icon: Icons.cancel_outlined,
          accentColor: const Color(0xFF78909C),
        ),
        AdminKpiCard(
          label: 'Reserved balance',
          value: data.totalReservedBalance.toStringAsFixed(2),
          icon: Icons.savings_outlined,
          accentColor: const Color(0xFFFFB74D),
        ),
      ],
    );
  }
}

class _OrderStatusCard extends StatelessWidget {
  const _OrderStatusCard({required this.data});

  final AdminDashboardDto data;

  @override
  Widget build(BuildContext context) {
    return AdminChartCard(
      title: 'Order status',
      subtitle: '${data.totalOrders} total orders',
      legend: AdminChartLegend(
        items: [
          AdminLegendItem(
            label: 'Pending',
            value: data.pendingOrders,
            color: const Color(0xFFFFB74D),
          ),
          AdminLegendItem(
            label: 'Filled',
            value: data.filledOrders,
            color: const Color(0xFF66BB6A),
          ),
          AdminLegendItem(
            label: 'Cancelled',
            value: data.cancelledOrders,
            color: const Color(0xFFEF5350),
          ),
        ],
      ),
      child: AdminOrderStatusDonut(data: data),
    );
  }
}

class _UserStatusCard extends StatelessWidget {
  const _UserStatusCard({required this.data});

  final AdminDashboardDto data;

  @override
  Widget build(BuildContext context) {
    final inactive =
        (data.totalUsers - data.activeUsers - data.lockedUsers).clamp(0, data.totalUsers);

    return AdminChartCard(
      title: 'User status',
      subtitle: '${data.totalUsers} registered users',
      legend: AdminChartLegend(
        items: [
          AdminLegendItem(
            label: 'Active',
            value: data.activeUsers,
            color: const Color(0xFF42A5F5),
          ),
          AdminLegendItem(
            label: 'Locked',
            value: data.lockedUsers,
            color: const Color(0xFFEF5350),
          ),
          AdminLegendItem(
            label: 'Inactive',
            value: inactive,
            color: const Color(0xFF78909C),
          ),
        ],
      ),
      child: AdminUserStatusDonut(data: data),
    );
  }
}
