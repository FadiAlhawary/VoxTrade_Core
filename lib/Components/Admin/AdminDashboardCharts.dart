import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:voxtrade_core/Components/ModelDto/AdminDtos.dart';
import 'package:voxtrade_core/utils/chart_theme_helpers.dart';

class AdminChartCard extends StatelessWidget {
  const AdminChartCard({
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
              color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
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

class AdminOrderStatusDonut extends StatelessWidget {
  const AdminOrderStatusDonut({super.key, required this.data});

  final AdminDashboardDto data;

  @override
  Widget build(BuildContext context) {
    final sections = _buildSections(context);
    if (sections.isEmpty) {
      return _emptyState(context, 'No orders yet');
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 42,
        sections: sections,
      ),
    );
  }

  List<PieChartSectionData> _buildSections(BuildContext context) {
    final total = data.totalOrders;
    if (total <= 0) return [];

    final items = [
      _Slice('Pending', data.pendingOrders, const Color(0xFFFFB74D)),
      _Slice('Filled', data.filledOrders, const Color(0xFF66BB6A)),
      _Slice('Cancelled', data.cancelledOrders, const Color(0xFFEF5350)),
    ].where((e) => e.value > 0).toList();

    return items.map((item) {
      final pct = (item.value / total * 100).toStringAsFixed(0);
      return PieChartSectionData(
        color: item.color,
        value: item.value.toDouble(),
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

class AdminUserStatusDonut extends StatelessWidget {
  const AdminUserStatusDonut({super.key, required this.data});

  final AdminDashboardDto data;

  @override
  Widget build(BuildContext context) {
    final sections = _buildSections(context);
    if (sections.isEmpty) {
      return _emptyState(context, 'No users yet');
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 42,
        sections: sections,
      ),
    );
  }

  List<PieChartSectionData> _buildSections(BuildContext context) {
    final total = data.totalUsers;
    if (total <= 0) return [];

    final inactive = (total - data.activeUsers - data.lockedUsers).clamp(0, total);
    final items = [
      _Slice('Active', data.activeUsers, const Color(0xFF42A5F5)),
      _Slice('Locked', data.lockedUsers, const Color(0xFFEF5350)),
      _Slice('Inactive', inactive, const Color(0xFF78909C)),
    ].where((e) => e.value > 0).toList();

    return items.map((item) {
      final pct = (item.value / total * 100).toStringAsFixed(0);
      return PieChartSectionData(
        color: item.color,
        value: item.value.toDouble(),
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

class AdminPlatformBarChart extends StatelessWidget {
  const AdminPlatformBarChart({super.key, required this.data});

  final AdminDashboardDto data;

  @override
  Widget build(BuildContext context) {
    final muted = dashboardChartMutedText(context);
    final grid = dashboardChartGridLine(context);
    final border = dashboardChartBorder(context);
    final scheme = Theme.of(context).colorScheme;

    final groups = [
      _Bar('Users', data.totalUsers.toDouble(), scheme.primary),
      _Bar('Orders', data.totalOrders.toDouble(), const Color(0xFF7E57C2)),
      _Bar('Trades', data.totalTrades.toDouble(), const Color(0xFF26A69A)),
      _Bar('Instruments', data.totalInstruments.toDouble(), const Color(0xFFFF7043)),
    ];

    final maxY = groups.map((e) => e.value).reduce((a, b) => a > b ? a : b);
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
                final i = value.toInt();
                if (i < 0 || i >= groups.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    groups[i].label,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: muted),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < groups.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: groups[i].value,
                  color: groups[i].color,
                  width: 22,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class AdminTradeVolumeLineChart extends StatelessWidget {
  const AdminTradeVolumeLineChart({super.key, required this.trades});

  final List<AdminTradeDto> trades;

  static const int _days = 7;

  @override
  Widget build(BuildContext context) {
    final muted = dashboardChartMutedText(context);
    final grid = dashboardChartGridLine(context);
    final border = dashboardChartBorder(context);
    final scheme = Theme.of(context).colorScheme;
    final tooltipBg = dashboardChartTooltipBackground(context);

    final daily = _dailyVolume();
    if (daily.every((e) => e.value <= 0)) {
      return _emptyState(context, 'No trades in the last $_days days');
    }

    final spots = [
      for (var i = 0; i < daily.length; i++)
        FlSpot(i.toDouble(), daily[i].value),
    ];
    final maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final chartMax = maxY <= 0 ? 100.0 : maxY * 1.15;

    return LineChart(
      LineChartData(
        minY: 0,
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
              reservedSize: 44,
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
                final i = value.toInt();
                if (i < 0 || i >= daily.length) {
                  return const SizedBox.shrink();
                }
                final d = daily[i].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${d.month}/${d.day}',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: muted),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => tooltipBg,
            getTooltipItems: (spots) => spots.map((spot) {
              final i = spot.x.toInt();
              final label = i >= 0 && i < daily.length
                  ? '${daily[i].date.month}/${daily[i].date.day}'
                  : '';
              return LineTooltipItem(
                '$label\n${_formatCompact(spot.y)}',
                TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : scheme.onInverseSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: scheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 3,
                color: scheme.primary,
                strokeWidth: 1.5,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  scheme.primary.withValues(alpha: 0.35),
                  scheme.primary.withValues(alpha: 0.02),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_DayValue> _dailyVolume() {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: _days - 1));

    final buckets = <DateTime, double>{};
    for (var i = 0; i < _days; i++) {
      final day = start.add(Duration(days: i));
      buckets[DateTime(day.year, day.month, day.day)] = 0;
    }

    for (final trade in trades) {
      final at = trade.executedAt;
      if (at == null) continue;
      final key = DateTime(at.year, at.month, at.day);
      if (buckets.containsKey(key)) {
        buckets[key] = (buckets[key] ?? 0) + trade.tradeValue;
      }
    }

    return buckets.entries
        .map((e) => _DayValue(date: e.key, value: e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  static String _formatCompact(double value) {
    final abs = value.abs();
    if (abs >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (abs >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }
}

class AdminWalletBalanceBar extends StatelessWidget {
  const AdminWalletBalanceBar({super.key, required this.data});

  final AdminDashboardDto data;

  @override
  Widget build(BuildContext context) {
    final muted = dashboardChartMutedText(context);
    final grid = dashboardChartGridLine(context);
    final border = dashboardChartBorder(context);

    final available = data.totalAvailableBalance;
    final reserved = data.totalReservedBalance;
    final total = data.totalWalletBalance;
    if (total <= 0) {
      return _emptyState(context, 'No wallet balance data');
    }

    final maxY = total * 1.1;

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
                AdminTradeVolumeLineChart._formatCompact(value),
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
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: muted),
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
                toY: available,
                color: const Color(0xFF66BB6A),
                width: 28,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: reserved,
                color: const Color(0xFFFFB74D),
                width: 28,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: total,
                color: Theme.of(context).colorScheme.primary,
                width: 28,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AdminChartLegend extends StatelessWidget {
  const AdminChartLegend({super.key, required this.items});

  final List<AdminLegendItem> items;

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

class AdminLegendItem {
  const AdminLegendItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;
}

class AdminRecentActivityList extends StatelessWidget {
  const AdminRecentActivityList({super.key, required this.logs});

  final List<AdminAuditLogDto> logs;

  @override
  Widget build(BuildContext context) {
    final muted = dashboardChartMutedText(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recent = logs.take(6).toList();

    if (recent.isEmpty) {
      return _emptyState(context, 'No recent activity');
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: recent.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: dashboardChartGridLine(context),
      ),
      itemBuilder: (context, index) {
        final log = recent[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.actionCode,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (log.username != null) log.username,
                        log.entity,
                        if (log.description != null) log.description,
                      ].whereType<String>().join(' · '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: muted),
                    ),
                  ],
                ),
              ),
              if (log.createdAt != null)
                Text(
                  _formatTime(log.createdAt!),
                  style: TextStyle(fontSize: 10, color: muted),
                ),
            ],
          ),
        );
      },
    );
  }

  static String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${dt.month}/${dt.day}';
  }
}

Widget _emptyState(BuildContext context, String message) {
  return Center(
    child: Text(
      message,
      style: TextStyle(color: dashboardChartMutedText(context), fontSize: 13),
    ),
  );
}

class _Slice {
  const _Slice(this.label, this.value, this.color);
  final String label;
  final int value;
  final Color color;
}

class _Bar {
  const _Bar(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;
}

class _DayValue {
  const _DayValue({required this.date, required this.value});
  final DateTime date;
  final double value;
}
