import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:voxtrade_core/Components/ModelDto/DashboardDtos.dart';
import 'package:voxtrade_core/utils/chart_theme_helpers.dart';

class UserDashboardChartCard extends StatelessWidget {
  const UserDashboardChartCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.legend,
    this.expandChild = true,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? legend;
  final bool expandChild;

  @override
  Widget build(BuildContext context) {
    final muted = dashboardChartMutedText(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: dashboardChartCardDecoration(context),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: expandChild ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color:
                  isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: TextStyle(fontSize: 12, color: muted)),
          ],
          const SizedBox(height: 12),
          if (expandChild) Expanded(child: child) else child,
          if (legend != null) ...[const SizedBox(height: 8), legend!],
        ],
      ),
    );
  }
}

class UserDashboardKpiCard extends StatelessWidget {
  const UserDashboardKpiCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.accentColor,
    this.subtitle,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? accentColor;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = accentColor ?? scheme.primary;

    return Container(
      decoration: dashboardChartCardDecoration(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 4, color: accent),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (icon != null)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, size: 16, color: accent),
                    ),
                  if (icon != null) const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                            color: dashboardChartMutedText(context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                            color:
                                isDark ? Colors.white : scheme.onSurface,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 1),
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              height: 1.2,
                              color: dashboardChartMutedText(context),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserPortfolioAllocationDonut extends StatelessWidget {
  const UserPortfolioAllocationDonut({super.key, required this.data});

  final UserDashboardSummaryDto data;

  @override
  Widget build(BuildContext context) {
    final sections = _buildSections();
    if (sections.isEmpty) {
      return userDashboardEmptyState(context, 'No portfolio data');
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 44,
        sections: sections,
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final cash = data.wallet.availableBalance;
    final positions = data.positions.totalMarketValue;
    final total = cash + positions;
    if (total <= 0) return [];

    final items = [
      _Slice('Cash', cash, const Color(0xFF42A5F5)),
      _Slice('Positions', positions, const Color(0xFF7E57C2)),
    ].where((e) => e.value > 0).toList();

    return items.map((item) {
      final pct = (item.value / total * 100).toStringAsFixed(0);
      return PieChartSectionData(
        color: item.color,
        value: item.value,
        title: '$pct%',
        radius: 52,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}

class UserOrderStatusDonut extends StatelessWidget {
  const UserOrderStatusDonut({super.key, required this.data});

  final UserDashboardSummaryDto data;

  @override
  Widget build(BuildContext context) {
    final sections = _buildSections();
    if (sections.isEmpty) {
      return userDashboardEmptyState(context, 'No orders yet');
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 44,
        sections: sections,
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final orders = data.orders;
    final total = orders.total;
    if (total <= 0) return [];

    final items = [
      _Slice('Pending', orders.pending.toDouble(), const Color(0xFFFFB74D)),
      _Slice(
        'Partial',
        orders.partiallyFilled.toDouble(),
        const Color(0xFF29B6F6),
      ),
      _Slice('Filled', orders.filled.toDouble(), const Color(0xFF66BB6A)),
      _Slice('Cancelled', orders.cancelled.toDouble(), const Color(0xFFEF5350)),
    ].where((e) => e.value > 0).toList();

    return items.map((item) {
      final pct = (item.value / total * 100).toStringAsFixed(0);
      return PieChartSectionData(
        color: item.color,
        value: item.value,
        title: '$pct%',
        radius: 52,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}

class UserWalletBalanceBar extends StatelessWidget {
  const UserWalletBalanceBar({super.key, required this.data});

  final UserDashboardSummaryDto data;

  @override
  Widget build(BuildContext context) {
    final muted = dashboardChartMutedText(context);
    final grid = dashboardChartGridLine(context);
    final border = dashboardChartBorder(context);

    final available = data.wallet.availableBalance;
    final reserved = data.wallet.reservedBalance;
    final total = data.wallet.balance;
    if (total <= 0 && available <= 0 && reserved <= 0) {
      return userDashboardEmptyState(context, 'No wallet balance data');
    }

    final maxY = (total > 0 ? total : available + reserved) * 1.15;

    return BarChart(
      BarChartData(
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (_) => FlLine(color: grid, strokeWidth: 1),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: border),
            left: BorderSide(color: border),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, meta) => Text(
                _formatCompact(value),
                style: TextStyle(fontSize: 10, color: muted),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const labels = ['Available', 'Reserved', 'Total'];
                final i = value.toInt();
                if (i < 0 || i >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: muted,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          _barGroup(0, available, const Color(0xFF66BB6A)),
          _barGroup(1, reserved, const Color(0xFFFFB74D)),
          _barGroup(2, total, Theme.of(context).colorScheme.primary),
        ],
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double value, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          color: color,
          width: 28,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }
}

class UserPositionsPnlBar extends StatelessWidget {
  const UserPositionsPnlBar({super.key, required this.data});

  final UserDashboardSummaryDto data;

  @override
  Widget build(BuildContext context) {
    final muted = dashboardChartMutedText(context);
    final grid = dashboardChartGridLine(context);
    final border = dashboardChartBorder(context);

    final unrealized = data.positions.totalUnrealizedPnl;
    final realized = data.positions.totalRealizedPnl;
    final marketValue = data.positions.totalMarketValue;

    if (marketValue <= 0 && unrealized == 0 && realized == 0) {
      return userDashboardEmptyState(context, 'No open positions');
    }

    final values = [marketValue, unrealized.abs(), realized.abs()];
    final maxY = values.reduce((a, b) => a > b ? a : b) * 1.2;
    final chartMax = maxY <= 0 ? 100.0 : maxY;

    return BarChart(
      BarChartData(
        maxY: chartMax,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: chartMax / 4,
          getDrawingHorizontalLine: (_) => FlLine(color: grid, strokeWidth: 1),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: border),
            left: BorderSide(color: border),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, meta) => Text(
                _formatCompact(value),
                style: TextStyle(fontSize: 10, color: muted),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const labels = ['Market', 'Unreal.', 'Realized'];
                final i = value.toInt();
                if (i < 0 || i >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: muted,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: marketValue,
                color: const Color(0xFF7E57C2),
                width: 26,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: unrealized.abs(),
                color:
                    unrealized >= 0
                        ? const Color(0xFF66BB6A)
                        : const Color(0xFFEF5350),
                width: 26,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: realized.abs(),
                color:
                    realized >= 0
                        ? const Color(0xFF26A69A)
                        : const Color(0xFFEF5350),
                width: 26,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UserActivityTypeBarChart extends StatelessWidget {
  const UserActivityTypeBarChart({super.key, required this.items});

  final List<DashboardActivityItemDto> items;

  @override
  Widget build(BuildContext context) {
    final muted = dashboardChartMutedText(context);
    final grid = dashboardChartGridLine(context);
    final border = dashboardChartBorder(context);

    final counts = _countByType();
    if (counts.every((e) => e.value <= 0)) {
      return userDashboardEmptyState(context, 'No recent activity');
    }

    final maxY = counts.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final chartMax = maxY <= 0 ? 5.0 : maxY * 1.25;

    return BarChart(
      BarChartData(
        maxY: chartMax,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: chartMax / 4,
          getDrawingHorizontalLine: (_) => FlLine(color: grid, strokeWidth: 1),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: border),
            left: BorderSide(color: border),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: TextStyle(fontSize: 10, color: muted),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= counts.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    counts[i].label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: muted,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < counts.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: counts[i].value.toDouble(),
                  color: counts[i].color,
                  width: 32,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            ),
        ],
      ),
    );
  }

  List<_ActivityCount> _countByType() {
    var orders = 0;
    var trades = 0;
    var wallet = 0;

    for (final item in items) {
      switch (item.activityType.toLowerCase()) {
        case 'trade':
          trades++;
        case 'wallet':
          wallet++;
        default:
          orders++;
      }
    }

    return [
      _ActivityCount('Orders', orders, const Color(0xFF7E57C2)),
      _ActivityCount('Trades', trades, const Color(0xFF26A69A)),
      _ActivityCount('Wallet', wallet, const Color(0xFF42A5F5)),
    ];
  }
}

class UserTradesSummaryBar extends StatelessWidget {
  const UserTradesSummaryBar({super.key, required this.data});

  final UserDashboardSummaryDto data;

  @override
  Widget build(BuildContext context) {
    final muted = dashboardChartMutedText(context);
    final grid = dashboardChartGridLine(context);
    final border = dashboardChartBorder(context);
    final scheme = Theme.of(context).colorScheme;

    final total = data.totalTrades.toDouble();
    final last7 = data.tradesLast7Days.toDouble();
    if (total <= 0 && last7 <= 0) {
      return userDashboardEmptyState(context, 'No trades yet');
    }

    final maxY = total > last7 ? total : last7;
    final chartMax = maxY <= 0 ? 10.0 : maxY * 1.2;

    return BarChart(
      BarChartData(
        maxY: chartMax,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: chartMax / 4,
          getDrawingHorizontalLine: (_) => FlLine(color: grid, strokeWidth: 1),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: border),
            left: BorderSide(color: border),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: TextStyle(fontSize: 10, color: muted),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const labels = ['All time', 'Last 7 days'];
                final i = value.toInt();
                if (i < 0 || i >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: muted,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: total,
                color: scheme.primary,
                width: 36,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: last7,
                color: const Color(0xFF26A69A),
                width: 36,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UserDashboardChartLegend extends StatelessWidget {
  const UserDashboardChartLegend({super.key, required this.items});

  final List<UserLegendItem> items;

  @override
  Widget build(BuildContext context) {
    final muted = dashboardChartMutedText(context);
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        for (final item in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${item.label} (${item.value})',
                style: TextStyle(fontSize: 11, color: muted),
              ),
            ],
          ),
      ],
    );
  }
}

class UserLegendItem {
  const UserLegendItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;
}

Widget userDashboardEmptyState(BuildContext context, String message) {
  return Center(
    child: Text(
      message,
      style: TextStyle(
        color: dashboardChartMutedText(context),
        fontSize: 13,
      ),
    ),
  );
}

String _formatCompact(double value) {
  final abs = value.abs();
  if (abs >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
  if (abs >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
  return value.toStringAsFixed(0);
}

String formatDashboardMoney(double value, String currency) {
  final symbol = currency == 'USD' ? '\$' : '$currency ';
  return '$symbol${value.toStringAsFixed(2)}';
}

class _Slice {
  const _Slice(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;
}

class _ActivityCount {
  const _ActivityCount(this.label, this.value, this.color);
  final String label;
  final int value;
  final Color color;
}
