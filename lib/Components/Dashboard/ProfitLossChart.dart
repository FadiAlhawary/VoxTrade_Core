import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:voxtrade_core/Components/ModelDto/PortfolioProfitLossPointDto.dart';
import 'package:voxtrade_core/Components/shimer/ProfitLossChartShimer.dart';

class ProfitLossChart extends StatelessWidget {
  final List<PortfolioProfitLossPointDto> points;
  final bool isLoading;
  final String? title;
  final VoidCallback? onRefresh;

  const ProfitLossChart({
    super.key,
    required this.points,
    required this.isLoading,
    this.title,
    this.onRefresh,
  });

  List<Color> get gradientColors => [Colors.cyanAccent, Colors.blueAccent];
  static const int _maxRenderedPoints = 90;

  String _formatCompact(double value) {
    final abs = value.abs();
    if (abs >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    }
    if (abs >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  Widget bottomTitleWidgets(
    double value,
    TitleMeta meta,
    List<PortfolioProfitLossPointDto> displayPoints,
  ) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
    final index = value.toInt();
    if (index < 0 || index >= displayPoints.length) {
      return const SizedBox.shrink();
    }

    final date = displayPoints[index].time;
    final text = '${date.month}/${date.day}';
    return SideTitleWidget(meta: meta, child: Text(text, style: style));
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 11,
      color: Colors.white70,
    );
    return Text(
      _formatCompact(value),
      style: style,
      textAlign: TextAlign.left,
    );
  }

  _PreparedSeries _prepareSeries(List<PortfolioProfitLossPointDto> rawPoints) {
    if (rawPoints.length <= _maxRenderedPoints) {
      return _PreparedSeries(points: rawPoints, isDownsampled: false);
    }

    final sampled = <PortfolioProfitLossPointDto>[];
    final step = (rawPoints.length / _maxRenderedPoints).ceil();
    for (var i = 0; i < rawPoints.length; i += step) {
      sampled.add(rawPoints[i]);
    }
    if (sampled.last.time != rawPoints.last.time) {
      sampled.add(rawPoints.last);
    }
    return _PreparedSeries(points: sampled, isDownsampled: true);
  }

  LineChartData mainData(List<PortfolioProfitLossPointDto> displayPoints) {
    final spots = <FlSpot>[
      for (int i = 0; i < displayPoints.length; i++)
        FlSpot(i.toDouble(), displayPoints[i].profitLoss),
    ];

    final minYValue = displayPoints
        .map((e) => e.profitLoss)
        .reduce((a, b) => a < b ? a : b);
    final maxYValue = displayPoints
        .map((e) => e.profitLoss)
        .reduce((a, b) => a > b ? a : b);

    final adjustedMinY = minYValue > 0 ? 0.0 : (minYValue * 1.15);
    final adjustedMaxY = maxYValue < 0 ? 0.0 : (maxYValue * 1.15);
    final interval =
        ((adjustedMaxY - adjustedMinY).abs() / 4).clamp(0.01, 1000000).toDouble();
    final xLabelInterval =
        (displayPoints.length / 6).ceil().toDouble().clamp(1, 1000000).toDouble();

    return LineChartData(
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (spot) => const Color(0xff1b2530),
          getTooltipItems:
              (touchedSpots) =>
                  touchedSpots
                      .map(
                        (e) => LineTooltipItem(
                          '${displayPoints[e.x.toInt()].time.month}/${displayPoints[e.x.toInt()].time.day}\nP/L: ${e.y.toStringAsFixed(2)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      )
                      .toList(),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: interval,
        verticalInterval: xLabelInterval,
        getDrawingHorizontalLine: (value) {
          return const FlLine(color: Color(0xff263341), strokeWidth: 0.8);
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(color: Color(0xff263341), strokeWidth: 0.8);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: xLabelInterval,
            getTitlesWidget: (value, meta) =>
                bottomTitleWidgets(value, meta, displayPoints),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: interval,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 52,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff2e3a46)),
      ),
      minX: 0,
      maxX: (displayPoints.length - 1).toDouble(),
      minY: adjustedMinY,
      maxY: adjustedMaxY == adjustedMinY ? adjustedMinY + 1 : adjustedMaxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: displayPoints.length <= 60,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors:
                  gradientColors
                      .map((color) => color.withValues(alpha: 0.2))
                      .toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
      return ProfitLossChartShimer(title: title, onRefresh: onRefresh);
    }
    if (points.isEmpty) {
      return Container(
        decoration: cardDecoration,
        child: const Center(
          child: Text('No profit/loss history in selected range'),
        ),
      );
    }

    final prepared = _prepareSeries(points);
    final displayPoints = prepared.points;
    final latestValue = points.last.profitLoss;
    final previousValue =
        points.length > 1 ? points[points.length - 2].profitLoss : 0.0;
    final delta = latestValue - previousValue;
    final isPositive = latestValue >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: cardDecoration,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title ?? 'Profit / Loss',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    _formatCompact(latestValue),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isPositive ? Colors.greenAccent : Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (delta >= 0 ? Colors.green : Colors.red).withValues(
                            alpha: 0.18,
                          ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: delta >= 0 ? Colors.greenAccent : Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AspectRatio(
                aspectRatio: 1.7,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 8,
                    left: 4,
                    top: 8,
                    bottom: 4,
                  ),
                  child: RepaintBoundary(child: LineChart(mainData(displayPoints))),
                ),
              ),
              if (prepared.isDownsampled)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Optimized view: sampled points for smoother rendering',
                    style: TextStyle(fontSize: 10, color: Colors.white54),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreparedSeries {
  final List<PortfolioProfitLossPointDto> points;
  final bool isDownsampled;

  const _PreparedSeries({required this.points, required this.isDownsampled});
}
