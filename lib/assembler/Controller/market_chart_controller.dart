import 'dart:async';
import 'package:get/get.dart';
import 'package:voxtrade_core/Models/LiveCandle.dart';
import 'package:voxtrade_core/assembler/Services/Market_Services.dart';
import 'package:voxtrade_core/assembler/Services/market_socket_service.dart';

class ChartPoint {
  final int time;
  final double price;

  ChartPoint({required this.time, required this.price});
}

class MarketChartController extends GetxController {
  final String symbol;
  MarketChartController(this.symbol);

  final RxDouble lastPrice = 0.0.obs;
  final RxList<LiveCandle> candles = <LiveCandle>[].obs;
  String get priceUpdateId => 'market_price_$symbol';
  String get highLowUpdateId => 'market_high_low_$symbol';

  StreamSubscription<MarketTick>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _initializeChart();
  }

  Future<void> _initializeChart() async {
    await _loadHistoricalCandles();
    _startLiveFeed();
  }

  Future<void> _loadHistoricalCandles() async {
    try {
      final nowUnixSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const last24HoursInSeconds = 24 * 60 * 60;
      final fromUnixSeconds = nowUnixSeconds - last24HoursInSeconds;
      final requestSymbol = _symbolForHistoricalRequest(symbol);

      var historicalCandles = await getHistoricalCandles(
        requestSymbol,
        '1',
        fromUnixSeconds,
        nowUnixSeconds,
      );
      // Some backends expect milliseconds instead of seconds for range params.
      if (historicalCandles.isEmpty) {
        historicalCandles = await getHistoricalCandles(
          requestSymbol,
          '1',
          fromUnixSeconds * 1000,
          nowUnixSeconds * 1000,
        );
      }

      if (historicalCandles.isEmpty) return;

      candles.assignAll(
        historicalCandles
            .map(
              (candle) => LiveCandle(
                time: candle.time.millisecondsSinceEpoch,
                open: candle.open,
                high: candle.high,
                low: candle.low,
                close: candle.close,
                volume: 0,
              ),
            )
            .toList()
          ..sort((a, b) => a.time.compareTo(b.time)),
      );

      lastPrice.value = candles.last.close;
      update([priceUpdateId, highLowUpdateId]);
    } catch (_) {
      // Keep the live feed running even if historical prefill fails.
    }
  }

  String _symbolForHistoricalRequest(String rawSymbol) {
    return rawSymbol.trim();
  }

  void _startLiveFeed() {
    final socket = Get.find<MarketSocketService>();

    _subscription = socket.subscribeToSymbol(symbol).listen((tick) {
      lastPrice.value = tick.price;
      update([priceUpdateId]);
      _applyTickToCandles(tick);
    });
  }

  void _applyTickToCandles(MarketTick tick) {
    const candleSeconds = 5; // 5-second candles for testing
    final bucketMs = candleSeconds * 1000;
    final candleTime = (tick.timestampUnixMs ~/ bucketMs) * bucketMs;

    if (candles.isEmpty || candles.last.time != candleTime) {
      candles.add(
        LiveCandle(
          time: candleTime,
          open: tick.price,
          high: tick.price,
          low: tick.price,
          close: tick.price,
          volume: tick.volume,
        ),
      );
    } else {
      final current = candles.last;
      current.high = current.high < tick.price ? tick.price : current.high;
      current.low = current.low > tick.price ? tick.price : current.low;
      current.close = tick.price;
      current.volume += tick.volume;

      candles[candles.length - 1] = current;
    }

    if (candles.length > 100) {
      candles.removeRange(0, candles.length - 100);
    }

    update([highLowUpdateId]);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
