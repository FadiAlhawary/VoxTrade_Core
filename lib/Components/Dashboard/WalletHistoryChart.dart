import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:voxtrade_core/Components/ModelDto/WalletHistoryDTO.dart';
import 'package:voxtrade_core/Components/shimer/WalletHistoryChartShimer.dart';

class WalletHistoryChart extends StatelessWidget {
  final List<WalletHistoryDto> history;
  final bool isLoading;
  final DateTime fromDate;
  final DateTime toDate;
  final String? title;
  final VoidCallback? onRefresh;

  const WalletHistoryChart({
    super.key,
    required this.history,
    required this.isLoading,
    required this.fromDate,
    required this.toDate,
    this.title,
    this.onRefresh,
  });

  BarTouchData get barTouchData =>
      const BarTouchData(enabled: true, handleBuiltInTouches: true);

  String _weekdayLabel(DateTime date) {
    return switch (date.weekday) {
      DateTime.monday => 'Mn',
      DateTime.tuesday => 'Tu',
      DateTime.wednesday => 'Wd',
      DateTime.thursday => 'Th',
      DateTime.friday => 'Fr',
      DateTime.saturday => 'St',
      DateTime.sunday => 'Sn',
      _ => '',
    };
  }

  Widget getTitles(double value, TitleMeta meta, int length) {
    final style = const TextStyle(
      color: Colors.white70,
      fontWeight: FontWeight.w600,
      fontSize: 11,
    );
    final idx = value.toInt();
    if (idx < 0 || idx >= length) {
      return const SizedBox.shrink();
    }
    final date = fromDate.add(Duration(days: idx));
    final text = _weekdayLabel(date);
    return SideTitleWidget(
      meta: meta,
      space: 4,
      child: Text(text, style: style),
    );
  }

  FlTitlesData titlesData(int length) => FlTitlesData(
    show: true,
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 30,
        interval: (length / 7).ceil().toDouble().clamp(1, 1000000),
        getTitlesWidget: (value, meta) => getTitles(value, meta, length),
      ),
    ),
    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  );

  FlBorderData get borderData => FlBorderData(
    show: true,
    border: Border.all(color: const Color(0xff2e3a46)),
  );

  LinearGradient get _addBarsGradient => LinearGradient(
    colors: [Colors.green.shade400, Colors.lightGreenAccent],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  LinearGradient get _minusBarsGradient => LinearGradient(
    colors: [Colors.red.shade400, Colors.deepOrangeAccent],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  bool _isIncoming(WalletHistoryDto entry) {
    if (entry.amount < 0) return false;
    final type = entry.transactionType.toLowerCase();
    const incomingKeywords = [
      'deposit',
      'credit',
      'refund',
      'receive',
      'topup',
    ];
    const outgoingKeywords = [
      'withdraw',
      'debit',
      'fee',
      'charge',
      'payment',
      'buy',
      'spent',
    ];

    if (incomingKeywords.any(type.contains)) return true;
    if (outgoingKeywords.any(type.contains)) return false;
    return true;
  }

  List<_DailyFlow> _buildDailyFlows(
    List<WalletHistoryDto> history,
    DateTime from,
    DateTime to,
  ) {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    final totalDays = end.difference(start).inDays + 1;
    final flows = List<_DailyFlow>.generate(
      totalDays,
      (_) => const _DailyFlow(),
    );

    for (final item in history) {
      final day = DateTime(
        item.createdAt.year,
        item.createdAt.month,
        item.createdAt.day,
      );
      if (day.isBefore(start) || day.isAfter(end)) continue;
      final index = day.difference(start).inDays;
      final current = flows[index];
      if (_isIncoming(item)) {
        flows[index] = _DailyFlow(
          received: current.received + 1,
          spent: current.spent,
        );
      } else {
        flows[index] = _DailyFlow(
          received: current.received,
          spent: current.spent + 1,
        );
      }
    }

    return flows;
  }

  List<BarChartGroupData> _buildBarGroups(List<_DailyFlow> values) =>
      values.asMap().entries.map((entry) {
        final value = entry.value;
        return BarChartGroupData(
          x: entry.key,
          barsSpace: 8,
          barRods: [
            BarChartRodData(
              toY: value.received,
              width: 12,
              gradient: _addBarsGradient,
              label: BarChartRodLabel(
                text: value.received.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            BarChartRodData(
              toY: value.spent,
              width: 12,
              gradient: _minusBarsGradient,
              label: BarChartRodLabel(
                text: value.spent.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        );
      }).toList();

  @override
  Widget build(BuildContext context) {
    final chartValues = _buildDailyFlows(history, fromDate, toDate);
    final hasChartData = chartValues.any(
      (entry) => entry.received > 0 || entry.spent > 0,
    );
    final cardDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: const LinearGradient(
        colors: [Color(0xff111821), Color(0xff0b1118)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(color: const Color(0xff273443)),
      boxShadow: const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.25),
          blurRadius: 12,
          offset: Offset(0, 6),
        ),
      ],
    );

    if (isLoading) {
      return WalletHistoryChartShimer(title: title, onRefresh: onRefresh);
    }
    if (!hasChartData) {
      return Container(
        decoration: cardDecoration,
        child: const Center(child: Text('No wallet history in selected range')),
      );
    }

    final maxValue = chartValues.fold<double>(
      0,
      (maxSoFar, item) =>
          item.received > item.spent
              ? (item.received > maxSoFar ? item.received : maxSoFar)
              : (item.spent > maxSoFar ? item.spent : maxSoFar),
    );
    final dynamicMaxY = maxValue <= 0 ? 1.0 : (maxValue * 1.25);
    final totalIncoming = chartValues.fold<double>(
      0,
      (sum, e) => sum + e.received,
    );
    final totalOutgoing = chartValues.fold<double>(0, (sum, e) => sum + e.spent);
    final total = totalIncoming + totalOutgoing;

    return Container(
      decoration: cardDecoration,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    title!,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  tooltip: 'Refresh',
                  color: Colors.white70,
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
          ] else ...[
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                tooltip: 'Refresh',
                color: Colors.white70,
                splashRadius: 20,
              ),
            ),
          ],
          Row(
            children: [
              _MetricPill(
                label: 'Incoming',
                value: totalIncoming.toStringAsFixed(0),
                color: Colors.greenAccent,
              ),
              const SizedBox(width: 8),
              _MetricPill(
                label: 'Outgoing',
                value: totalOutgoing.toStringAsFixed(0),
                color: Colors.redAccent,
              ),
              const SizedBox(width: 8),
              _MetricPill(
                label: 'Total',
                value: total.toStringAsFixed(0),
                color: Colors.cyanAccent,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: Colors.greenAccent, label: 'Incoming'),
              SizedBox(width: 16),
              _LegendDot(color: Colors.redAccent, label: 'Outgoing'),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: BarChart(
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOutQuad,
                BarChartData(
                  barTouchData: barTouchData,
                  titlesData: titlesData(chartValues.length),
                  borderData: borderData,
                  barGroups: _buildBarGroups(chartValues),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (dynamicMaxY / 4).clamp(1, 1000000),
                    getDrawingHorizontalLine:
                        (value) => const FlLine(
                          color: Color(0xff263341),
                          strokeWidth: 0.7,
                        ),
                  ),
                  alignment: BarChartAlignment.spaceAround,
                  maxY: dynamicMaxY,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.32)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyFlow {
  final double received;
  final double spent;

  const _DailyFlow({this.received = 0, this.spent = 0});
}
