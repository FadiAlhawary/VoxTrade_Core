import 'dart:async';

import 'package:flutter/foundation.dart';
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

  Timer? _reconnectTimer;

  static const Duration _reconnectInterval = Duration(seconds: 15);

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
      _scheduleReconnectIfNeeded();
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

    await _startConnectionSafe();
    if (!isConnected.value) {
      _scheduleReconnectIfNeeded();
    }

    return this;
  }

  void _scheduleReconnectIfNeeded() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(_reconnectInterval, (_) async {
      if (isConnected.value) return;
      await _startConnectionSafe();
    });
  }

  /// Does not throw — app must start even when LAN/API is unreachable or server is down.
  Future<void> _startConnectionSafe() async {
    if (_hubConnection.state == HubConnectionState.Connected) {
      isConnected.value = true;
      return;
    }

    try {
      await _hubConnection.start();
      isConnected.value = true;
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
    } catch (e, st) {
      isConnected.value = false;
      debugPrint('MarketSocketService: connect failed ($e)');
      debugPrint('$st');
    }
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
      scheduleMicrotask(() => _invokeSubscribe(normalized));
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
    try {
      if (_hubConnection.state != HubConnectionState.Connected) {
        await _startConnectionSafe();
      }
      if (_hubConnection.state != HubConnectionState.Connected) return;

      await _hubConnection.invoke('SubscribeSymbol', args: [symbol]);
    } catch (e) {
      debugPrint('MarketSocketService: SubscribeSymbol failed ($e)');
    }
  }

  Future<void> _invokeUnsubscribe(String symbol) async {
    if (_hubConnection.state != HubConnectionState.Connected) return;

    try {
      await _hubConnection.invoke('UnsubscribeSymbol', args: [symbol]);
    } catch (e) {
      debugPrint('MarketSocketService: UnsubscribeSymbol failed ($e)');
    }
  }

  @override
  void onClose() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    for (final controller in _symbolControllers.values) {
      controller.close();
    }
    _hubConnection.stop();
    super.onClose();
  }
}
