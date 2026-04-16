import 'dart:async';
import 'package:get/get.dart';
import 'package:voxtrade_core/Models/LiveCandle.dart';
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

  StreamSubscription<MarketTick>? _subscription;

  @override
  void onInit() {
    super.onInit();

    final socket = Get.find<MarketSocketService>();

    _subscription = socket.subscribeToSymbol(symbol).listen((tick) {
      lastPrice.value = tick.price;
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
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
