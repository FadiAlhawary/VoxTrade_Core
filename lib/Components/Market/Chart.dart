import 'dart:math' as math;

import 'package:financial_chart/financial_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Models/LiveCandle.dart';
import 'package:voxtrade_core/assembler/Controller/ThemeController.dart';
import 'package:voxtrade_core/assembler/Controller/market_chart_controller.dart';
import 'package:voxtrade_core/utils/Helper.dart';

class LiveMarketChart extends StatefulWidget {
  final String symbol;
  const LiveMarketChart({super.key, required this.symbol});

  @override
  State<LiveMarketChart> createState() => _LiveMarketChartState();
}

class _LiveMarketChartState extends State<LiveMarketChart> {
  late _ChartType _selected;

  @override
  void initState() {
    super.initState();
    _selected = _defaultChartTypeForSymbol(widget.symbol);
  }

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.isRegistered<MarketChartController>(tag: widget.symbol)
            ? Get.find<MarketChartController>(tag: widget.symbol)
            : Get.put(MarketChartController(widget.symbol), tag: widget.symbol);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(displayMarketName(widget.symbol)),
        actions: [
          IconButton(
            tooltip: 'Chart settings',
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => _showChartTypeDialog(context, scheme),
          ),
        ],
      ),
      body: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Obx(() {
                if (_selected == _ChartType.candlesFl) {
                  return _FlCandlestickLiveChart(
                    key: const ValueKey('fl_candles'),
                    candles: List<LiveCandle>.from(controller.candles),
                  );
                }
                final chartData = buildChartData(controller.candles);
                return _LiveChartView(
                  key: ValueKey(_selected),
                  chartType: _selected,
                  data: chartData,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showChartTypeDialog(
    BuildContext context,
    ColorScheme scheme,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          icon: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primary.withValues(alpha: 0.12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(Icons.settings_rounded, color: scheme.primary),
            ),
          ),
          title: const Text('Chart type'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final t in _ChartType.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Material(
                      color:
                          _selected == t
                              ? scheme.primary.withValues(alpha: 0.1)
                              : scheme.surfaceContainerHighest.withValues(
                                alpha: 0.4,
                              ),
                      borderRadius: BorderRadius.circular(14),
                      child: RadioListTile<_ChartType>(
                        dense: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        value: t,
                        groupValue: _selected,
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _selected = v);
                          Navigator.of(dialogContext).pop();
                        },
                        secondary: Icon(
                          t.chartIcon,
                          color:
                              _selected == t
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                        ),
                        title: Text(
                          t.chartTitle,
                          style: TextStyle(
                            fontWeight:
                                _selected == t
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<GData<int>> buildChartData(List<LiveCandle> candles) {
    return candles.map((c) {
      return GData<int>(
        pointValue: c.time,
        seriesValues: [c.open, c.high, c.low, c.close, c.volume],
      );
    }).toList();
  }
}

/// Matches forex inference in [MarketViewrCard] (`_inferMarketType`).
bool _chartSymbolIsForex(String symbol) {
  final raw =
      symbol.contains(':') ? symbol.split(':').last : symbol.toUpperCase();
  final exchange =
      symbol.contains(':') ? symbol.split(':').first.toUpperCase() : '';
  const knownEquities = {'AAPL', 'NVDA', 'ZM', 'MSFT'};
  if (knownEquities.contains(raw)) return false;
  if (exchange == 'BINANCE' ||
      raw.contains('BTC') ||
      raw.contains('ETH') ||
      raw.endsWith('USDT')) {
    return false;
  }
  if (exchange == 'OANDA' || raw.contains('_') || raw.contains('/')) {
    return true;
  }
  return false;
}

_ChartType _defaultChartTypeForSymbol(String symbol) {
  if (_chartSymbolIsForex(symbol)) return _ChartType.line;
  return _ChartType.candlesFl;
}

enum _ChartType { candles, candlesFl, ohlc, line, area, bar }

extension _ChartTypeUi on _ChartType {
  String get chartTitle => switch (this) {
    _ChartType.candles => 'Candles',
    _ChartType.candlesFl => 'Candles FL',
    _ChartType.ohlc => 'OHLC bars',
    _ChartType.line => 'Line',
    _ChartType.area => 'Area',
    _ChartType.bar => 'Volume bars',
  };

  IconData get chartIcon => switch (this) {
    _ChartType.candles => Icons.candlestick_chart_rounded,
    _ChartType.candlesFl => Icons.multiline_chart_rounded,
    _ChartType.ohlc => Icons.view_week_rounded,
    _ChartType.line => Icons.show_chart_rounded,
    _ChartType.area => Icons.stacked_line_chart,
    _ChartType.bar => Icons.bar_chart_rounded,
  };
}

class _LiveChartView extends StatefulWidget {
  final _ChartType chartType;
  final List<GData<int>> data;

  const _LiveChartView({
    super.key,
    required this.chartType,
    required this.data,
  });

  @override
  State<_LiveChartView> createState() => _LiveChartViewState();
}

class _LiveChartViewState extends State<_LiveChartView>
    with TickerProviderStateMixin {
  late final GDataSource<int, GData<int>> _dataSource;
  late GChart _chart;

  @override
  void initState() {
    super.initState();
    _dataSource = _createDataSource(widget.data);
    _chart = _createChart(dataSource: _dataSource, chartType: widget.chartType);
  }

  @override
  void didUpdateWidget(covariant _LiveChartView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.chartType != widget.chartType) {
      _chart.dispose();
      _chart = _createChart(
        dataSource: _dataSource,
        chartType: widget.chartType,
      );
    }

    _syncChartData(widget.data);
  }

  @override
  void dispose() {
    _chart.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeController>().isDarkMode.value;
    _chart.theme = isDark ? GThemeDark() : GThemeLight();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: GChartWidget(chart: _chart, tickerProvider: this),
    );
  }

  GDataSource<int, GData<int>> _createDataSource(List<GData<int>> data) {
    return GDataSource<int, GData<int>>(
      dataList: List<GData<int>>.from(data),
      seriesProperties: const [
        GDataSeriesProperty(key: 'open', label: 'Open', precision: 2),
        GDataSeriesProperty(key: 'high', label: 'High', precision: 2),
        GDataSeriesProperty(key: 'low', label: 'Low', precision: 2),
        GDataSeriesProperty(key: 'close', label: 'Close', precision: 2),
        GDataSeriesProperty(key: 'volume', label: 'Volume', precision: 0),
      ],
    );
  }

  GChart _createChart({
    required GDataSource<int, GData<int>> dataSource,
    required _ChartType chartType,
  }) {
    return GChart(
      dataSource: dataSource,
      theme:
          Get.find<ThemeController>().isDarkMode.value
              ? GThemeDark()
              : GThemeLight(),
      panels: [
        GPanel(
          valueViewPorts: [
            GValueViewPort(
              valuePrecision: 2,
              autoScaleStrategy: GValueViewPortAutoScaleStrategyMinMax(
                dataKeys: _valueKeysForType(chartType),
                marginStart: GSize.viewHeightRatio(0.08),
                marginEnd: GSize.viewHeightRatio(0.08),
              ),
            ),
          ],
          valueAxes: [GValueAxis()],
          pointAxes: [GPointAxis()],
          graphs: [GGraphGrids(), _buildGraph(chartType)],
        ),
      ],
    );
  }

  void _syncChartData(List<GData<int>> nextData) {
    _dataSource.dataList
      ..clear()
      ..addAll(nextData);

    // Keep horizontal viewport (user pan/scroll) and only refresh drawing.
    _chart.autoScaleViewports(
      resetPointViewPort: false,
      resetValueViewPort: true,
      animation: false,
    );
    _chart.repaint(layout: false);
  }

  GGraph _buildGraph(_ChartType type) {
    switch (type) {
      case _ChartType.candles:
        return GGraphOhlc(
          ohlcValueKeys: const ['open', 'high', 'low', 'close'],
          drawAsCandle: true,
        );
      case _ChartType.candlesFl:
        // Rendered by [_FlCandlestickLiveChart], not [GChart].
        return GGraphOhlc(
          ohlcValueKeys: const ['open', 'high', 'low', 'close'],
          drawAsCandle: true,
        );
      case _ChartType.ohlc:
        return GGraphOhlc(
          ohlcValueKeys: const ['open', 'high', 'low', 'close'],
          drawAsCandle: false,
        );
      case _ChartType.line:
        return GGraphLine(
          valueKey: 'close',
          smoothing: true,
          crosshairHighlightValueKeys: const ['close'],
        );
      case _ChartType.area:
        return GGraphArea(valueKey: 'close', baseValue: 0);
      case _ChartType.bar:
        return GGraphBar(valueKey: 'volume', basePosition: 1.0);
    }
  }

  List<String> _valueKeysForType(_ChartType type) {
    switch (type) {
      case _ChartType.candles:
      case _ChartType.candlesFl:
      case _ChartType.ohlc:
        return const ['high', 'low'];
      case _ChartType.line:
      case _ChartType.area:
        return const ['close'];
      case _ChartType.bar:
        return const ['volume'];
    }
  }
}

/// Live OHLC feed as candlesticks using [fl_chart] (see fl_chart candlestick sample).
class _FlCandlestickLiveChart extends StatelessWidget {
  const _FlCandlestickLiveChart({super.key, required this.candles});

  final List<LiveCandle> candles;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (candles.isEmpty) {
      return Center(
        child: Text(
          'Waiting for chart data…',
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
      );
    }

    final gridLine = FlLine(
      color: scheme.outline.withValues(alpha: 0.35),
      strokeWidth: 0.4,
      dashArray: const [8, 4],
    );

    final spots =
        candles.asMap().entries.map((e) {
          final c = e.value;
          return CandlestickSpot(
            x: e.key.toDouble(),
            open: c.open,
            high: c.high,
            low: c.low,
            close: c.close,
          );
        }).toList();

    final maxX = math.max((candles.length - 1).toDouble(), 1.0);
    final labelEvery = math.max(1, (candles.length / 6).ceil());

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.only(right: 18),
        child: CandlestickChart(
          CandlestickChartData(
            candlestickSpots: spots,
            candlestickPainter: DefaultCandlestickPainter(
              candlestickStyleProvider: (spot, _) {
                final up = spot.open <= spot.close;
                final color = up ? scheme.primary : scheme.error;
                return CandlestickStyle(
                  lineColor: color,
                  lineWidth: 1.2,
                  bodyStrokeColor: color,
                  bodyStrokeWidth: 0,
                  bodyFillColor: color,
                  bodyWidth: 5,
                  bodyRadius: 0,
                );
              },
            ),
            minX: 0,
            maxX: maxX,
            gridData: FlGridData(
              show: true,
              getDrawingHorizontalLine: (_) => gridLine,
              getDrawingVerticalLine: (_) => gridLine,
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                drawBelowEverything: true,
                sideTitles: SideTitles(
                  showTitles: true,
                  maxIncluded: false,
                  minIncluded: false,
                  reservedSize: 56,
                  getTitlesWidget: (value, meta) => SideTitleWidget(
                    meta: meta,
                    child: Text(
                      meta.formattedValue,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                axisNameWidget: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Time',
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                axisNameSize: 28,
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  maxIncluded: false,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= candles.length) {
                      return const SizedBox.shrink();
                    }
                    if (i % labelEvery != 0 && i != candles.length - 1) {
                      return const SizedBox.shrink();
                    }
                    final t = candles[i].time;
                    final d = DateTime.fromMillisecondsSinceEpoch(t);
                    final label =
                        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(
                        label,
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            touchedPointIndicator: AxisSpotIndicator(
              painter: AxisLinesIndicatorPainter(
                verticalLineProvider: (x) {
                  final idx = x.round().clamp(0, candles.length - 1);
                  final c = candles[idx];
                  final up = c.open < c.close;
                  return VerticalLine(
                    x: x,
                    color: (up ? scheme.primary : scheme.error).withValues(
                      alpha: 0.45,
                    ),
                    strokeWidth: 1,
                  );
                },
                horizontalLineProvider: (y) => HorizontalLine(
                  y: y,
                  label: HorizontalLineLabel(
                    show: true,
                    style: TextStyle(
                      color: scheme.tertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    labelResolver: (hLine) =>
                        hLine.y.toStringAsFixed(hLine.y.abs() >= 100 ? 1 : 4),
                    alignment: Alignment.topLeft,
                  ),
                  color: scheme.tertiary.withValues(alpha: 0.85),
                  strokeWidth: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
