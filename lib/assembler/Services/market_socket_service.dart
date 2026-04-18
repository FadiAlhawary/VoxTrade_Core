import 'dart:async';
import 'package:get/get.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:voxtrade_core/assembler/common/.env.dart';

class MarketTick {
  final String symbol;
  final double price;
  final double volume;
  final int timestampUnixMs;
  final List<String> conditions;
  final String source;

  MarketTick({
    required this.symbol,
    required this.price,
    required this.volume,
    required this.timestampUnixMs,
    required this.conditions,
    required this.source,
  });

  factory MarketTick.fromJson(Map<String, dynamic> json) {
    return MarketTick(
      symbol: json['symbol']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      volume: (json['volume'] as num?)?.toDouble() ?? 0,
      timestampUnixMs: (json['timestampUnixMs'] as num?)?.toInt() ?? 0,
      conditions:
          (json['conditions'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      source: json['source']?.toString() ?? '',
    );
  }
}

class MarketSocketService extends GetxService {
  late HubConnection _hubConnection;

  final RxBool isConnected = false.obs;

  // symbol -> stream controller
  final Map<String, StreamController<MarketTick>> _symbolControllers = {};

  // symbol -> local subscriber count
  final Map<String, int> _localSubscriberCounts = {};

  Future<MarketSocketService> init() async {
    _hubConnection =
        HubConnectionBuilder()
            .withUrl(
              '${ENV.apiBaseUrl}/hubs/market',
              options: HttpConnectionOptions(
                // logging: (level, message) {
                //   print('[SignalR] $message');
                // },
              ),
            )
            .withAutomaticReconnect()
            .build();

    _hubConnection.onclose(({Exception? error}) {
      isConnected.value = false;
      // print('SignalR closed: $error');
    });

    _hubConnection.onreconnected(({String? connectionId}) async {
      isConnected.value = true;
      // print('SignalR reconnected: $connectionId');

      // resubscribe all active symbols after reconnect
      for (final symbol in _localSubscriberCounts.keys) {
        await _invokeSubscribe(symbol);
      }
    });

    _hubConnection.on('MarketTick', (arguments) {
      if (arguments == null || arguments.isEmpty) return;

      final raw = arguments.first;
      if (raw is Map<String, dynamic>) {
        final tick = MarketTick.fromJson(raw);
        _symbolControllers[tick.symbol]?.add(tick);
      } else if (raw is Map) {
        final tick = MarketTick.fromJson(Map<String, dynamic>.from(raw));
        _symbolControllers[tick.symbol]?.add(tick);
      }
    });

    await _startConnection();

    return this;
  }

  Future<void> _startConnection() async {
    if (_hubConnection.state == HubConnectionState.Connected) return;

    await _hubConnection.start();
    isConnected.value = true;
  }

  Stream<MarketTick> subscribeToSymbol(String symbol) {
    final normalized = symbol.trim().toUpperCase();

    if (!_symbolControllers.containsKey(normalized)) {
      _symbolControllers[normalized] = StreamController<MarketTick>.broadcast(
        onCancel: () async {
          await unsubscribeSymbol(normalized);
        },
      );
    }

    final current = _localSubscriberCounts[normalized] ?? 0;
    _localSubscriberCounts[normalized] = current + 1;

    if (current == 0) {
      _invokeSubscribe(normalized);
    }

    return _symbolControllers[normalized]!.stream;
  }

  Future<void> unsubscribeSymbol(String symbol) async {
    final normalized = symbol.trim().toUpperCase();
    final current = _localSubscriberCounts[normalized] ?? 0;

    if (current <= 1) {
      _localSubscriberCounts.remove(normalized);
      await _invokeUnsubscribe(normalized);
    } else {
      _localSubscriberCounts[normalized] = current - 1;
    }
  }

  Future<void> _invokeSubscribe(String symbol) async {
    if (_hubConnection.state != HubConnectionState.Connected) {
      await _startConnection();
    }

    await _hubConnection.invoke('SubscribeSymbol', args: [symbol]);
  }

  Future<void> _invokeUnsubscribe(String symbol) async {
    if (_hubConnection.state != HubConnectionState.Connected) return;

    await _hubConnection.invoke('UnsubscribeSymbol', args: [symbol]);
  }

  @override
  void onClose() {
    for (final controller in _symbolControllers.values) {
      controller.close();
    }
    _hubConnection.stop();
    super.onClose();
  }
}
