import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:financial_chart/financial_chart.dart';
import 'package:voxtrade_core/Models/LiveCandle.dart';
import 'package:voxtrade_core/assembler/Controller/ThemeController.dart';
import 'package:voxtrade_core/assembler/Controller/market_chart_controller.dart';

class LiveMarketChart extends StatefulWidget {
  final String symbol;
  const LiveMarketChart({super.key, required this.symbol});

  @override
  State<LiveMarketChart> createState() => _LiveMarketChartState();
}

class _LiveMarketChartState extends State<LiveMarketChart> {
  _ChartType _selected = _ChartType.candles;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MarketChartController>(tag: widget.symbol);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.symbol),
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

enum _ChartType { candles, ohlc, line, area, bar }

extension _ChartTypeUi on _ChartType {
  String get chartTitle => switch (this) {
    _ChartType.candles => 'Candles',
    _ChartType.ohlc => 'OHLC bars',
    _ChartType.line => 'Line',
    _ChartType.area => 'Area',
    _ChartType.bar => 'Volume bars',
  };

  IconData get chartIcon => switch (this) {
    _ChartType.candles => Icons.candlestick_chart_rounded,
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
  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeController>().isDarkMode.value;
    final dataSource = GDataSource<int, GData<int>>(
      dataList: widget.data,
      seriesProperties: const [
        GDataSeriesProperty(key: 'open', label: 'Open', precision: 2),
        GDataSeriesProperty(key: 'high', label: 'High', precision: 2),
        GDataSeriesProperty(key: 'low', label: 'Low', precision: 2),
        GDataSeriesProperty(key: 'close', label: 'Close', precision: 2),
        GDataSeriesProperty(key: 'volume', label: 'Volume', precision: 0),
      ],
    );

    final chart = GChart(
      dataSource: dataSource,
      theme: isDark ? GThemeDark() : GThemeLight(),
      panels: [
        GPanel(
          valueViewPorts: [
            GValueViewPort(
              valuePrecision: 2,
              autoScaleStrategy: GValueViewPortAutoScaleStrategyMinMax(
                dataKeys: _valueKeysForType(widget.chartType),
                marginStart: GSize.viewHeightRatio(0.08),
                marginEnd: GSize.viewHeightRatio(0.08),
              ),
            ),
          ],
          valueAxes: [GValueAxis()],
          pointAxes: [GPointAxis()],
          graphs: [GGraphGrids(), _buildGraph(widget.chartType)],
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: GChartWidget(chart: chart, tickerProvider: this),
    );
  }

  GGraph _buildGraph(_ChartType type) {
    switch (type) {
      case _ChartType.candles:
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
