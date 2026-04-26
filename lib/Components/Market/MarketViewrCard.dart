import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/ModelDto/InstrumentDTO.dart';
import 'package:voxtrade_core/Models/LiveCandle.dart';
import 'package:voxtrade_core/assembler/Controller/market_chart_controller.dart';
import 'package:voxtrade_core/routes/route_names.dart';

class MarketChartTile extends StatelessWidget {
  const MarketChartTile({super.key, required this.instrument, this.index = 0});

  final InstrumentDTO instrument;
  final int index;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      MarketChartController(instrument.symbol),
      tag: instrument.symbol,
    );
    final meta = _symbolMeta(instrument.symbol);
    final initialIsOpen =
        meta.marketType == _MarketType.forex
            ? true
            : _isMarketOpen(
              meta.marketType,
              _referenceUtcFromHub(controller.candles),
            );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:
            initialIsOpen
                ? () => Get.toNamed(
                  RouteStrings.marketBuySell,
                  arguments: instrument.id,
                )
                : null,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0xFF1F2C46),
            border: Border.all(
              color:
                  initialIsOpen
                      ? const Color(0xFF2C3C5D)
                      : const Color(0xFF5A6785),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: GetBuilder<MarketChartController>(
              key: ValueKey(instrument.symbol),
              tag: instrument.symbol,
              id: controller.priceUpdateId,
              builder: (controller) {
                final candles = controller.candles;
                final referenceUtc = _referenceUtcFromHub(candles);
                final isOpen =
                    meta.marketType == _MarketType.forex
                        ? true
                        : _isMarketOpen(meta.marketType, referenceUtc);
                final sparkline = candles
                    .map((c) => c.close)
                    .where((v) => v.isFinite)
                    .toList(growable: false);
                final lastPrice =
                    controller.lastPrice.value > 0
                        ? controller.lastPrice.value
                        : (candles.isNotEmpty ? candles.last.close : 0.0);
                final open = candles.isNotEmpty ? candles.first.open : 0.0;
                final delta =
                    open == 0 ? 0.0 : ((lastPrice - open) / open) * 100;
                final isUp = delta >= 0;
                final changeColor =
                    isUp ? const Color(0xFF34D399) : const Color(0xFFF87171);
                final mutedText = const Color(0xFF97A6C9);

                return Row(
                  children: [
                    _LogoTile(meta: meta),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            instrument.shortName.isNotEmpty
                                ? instrument.shortName
                                : meta.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color:
                                  isOpen
                                      ? const Color(0xFFEFF4FF)
                                      : const Color(0xFFCCD5E9),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            meta.ticker,
                            style: TextStyle(
                              color: mutedText,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 70,
                      height: 26,
                      child: CustomPaint(
                        painter: _SparklinePainter(
                          values: sparkline,
                          strokeColor:
                              isOpen ? changeColor : const Color(0xFF7D8AA8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (isOpen)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: changeColor.withValues(alpha: 0.16),
                            ),
                            child: Text(
                              '${isUp ? '+' : ''}${delta.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: changeColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: const Color(
                                0xFF616F8E,
                              ).withValues(alpha: 0.28),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lock_clock_rounded,
                                  size: 12,
                                  color: Color(0xFFD9E1F5),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Market Closed',
                                  style: TextStyle(
                                    color: Color(0xFFD9E1F5),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 6),
                        Text(
                          '\$${lastPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color:
                                isOpen ? Colors.white : const Color(0xFFD3DAEC),
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                            letterSpacing: -0.4,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

DateTime _referenceUtcFromHub(List<LiveCandle> candles) {
  if (candles.isNotEmpty) {
    return DateTime.fromMillisecondsSinceEpoch(candles.last.time, isUtc: true);
  }
  return DateTime.now().toUtc();
}

class _LogoTile extends StatelessWidget {
  const _LogoTile({required this.meta});

  final _SymbolMeta meta;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FF),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(meta.icon, color: meta.iconColor, size: 22),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values, required this.strokeColor});

  final List<double> values;
  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final span = (maxV - minV).abs();
    final paint =
        Paint()
          ..color = strokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final normalized = span <= 0.000001 ? 0.5 : (values[i] - minV) / span;
      final y = size.height - (normalized * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.strokeColor != strokeColor;
  }
}

class _SymbolMeta {
  const _SymbolMeta({
    required this.name,
    required this.ticker,
    required this.icon,
    required this.iconColor,
    required this.marketType,
  });

  final String name;
  final String ticker;
  final IconData icon;
  final Color iconColor;
  final _MarketType marketType;
}

_SymbolMeta _symbolMeta(String symbol) {
  final raw =
      symbol.contains(':') ? symbol.split(':').last : symbol.toUpperCase();
  final exchange =
      symbol.contains(':') ? symbol.split(':').first.toUpperCase() : '';
  switch (raw) {
    case 'AAPL':
      return const _SymbolMeta(
        name: 'Apple Inc.',
        ticker: 'AAPL',
        icon: Icons.phone_iphone_rounded,
        iconColor: Color(0xFF101216),
        marketType: _MarketType.stock,
      );
    case 'NVDA':
      return const _SymbolMeta(
        name: 'Nvidia',
        ticker: 'NVDA',
        icon: Icons.memory_rounded,
        iconColor: Color(0xFF3B9B36),
        marketType: _MarketType.stock,
      );
    case 'ZM':
      return const _SymbolMeta(
        name: 'Zoom Video',
        ticker: 'ZM',
        icon: Icons.videocam_rounded,
        iconColor: Color(0xFF3B82F6),
        marketType: _MarketType.stock,
      );
    case 'MSFT':
      return const _SymbolMeta(
        name: 'Microsoft',
        ticker: 'MSFT',
        icon: Icons.window_rounded,
        iconColor: Color(0xFF0B66C3),
        marketType: _MarketType.stock,
      );
    default:
      final inferredType = _inferMarketType(raw: raw, exchange: exchange);
      return _SymbolMeta(
        name: raw.replaceAll('_', '/'),
        ticker: raw,
        icon: Icons.show_chart_rounded,
        iconColor: const Color(0xFF3555C8),
        marketType: inferredType,
      );
  }
}

enum _MarketType { stock, crypto, forex }

_MarketType _inferMarketType({required String raw, required String exchange}) {
  if (exchange == 'BINANCE' ||
      raw.contains('BTC') ||
      raw.contains('ETH') ||
      raw.endsWith('USDT')) {
    return _MarketType.crypto;
  }
  if (exchange == 'OANDA' || raw.contains('_') || raw.contains('/')) {
    return _MarketType.forex;
  }
  return _MarketType.stock;
}

bool _isMarketOpen(_MarketType marketType, DateTime nowUtc) {
  switch (marketType) {
    case _MarketType.crypto:
      return true; // Crypto trades 24/7.
    case _MarketType.forex:
      return _isForexMarketOpen(nowUtc);
    case _MarketType.stock:
      // US session approximation in UTC: 13:30 - 20:00.
      if (nowUtc.weekday == DateTime.saturday ||
          nowUtc.weekday == DateTime.sunday) {
        return false;
      }
      final minutes = (nowUtc.hour * 60) + nowUtc.minute;
      const openMinutes = (13 * 60) + 30;
      const closeMinutes = 20 * 60;
      return minutes >= openMinutes && minutes < closeMinutes;
  }
}

bool _isForexMarketOpen(DateTime utcInput) {
  final nowUtc = utcInput.isUtc ? utcInput : utcInput.toUtc();

  // Approx New York offset:
  // EDT = UTC-4, EST = UTC-5.
  final isDst = _isNewYorkDst(nowUtc);
  final nyNow = nowUtc.subtract(Duration(hours: isDst ? 4 : 5));

  final day = nyNow.weekday; // Monday = 1, Sunday = 7
  final timeMinutes = (nyNow.hour * 60) + nyNow.minute;
  const fivePm = 17 * 60;

  // Sunday before 5 PM NY = closed
  if (day == DateTime.sunday && timeMinutes < fivePm) {
    return false;
  }

  // Friday after/equal 5 PM NY = closed
  if (day == DateTime.friday && timeMinutes >= fivePm) {
    return false;
  }

  // Saturday = closed
  if (day == DateTime.saturday) {
    return false;
  }

  return true;
}

bool _isNewYorkDst(DateTime utc) {
  final year = utc.year;

  final dstStart = _nthSundayOfMonthUtc(year, 3, 2, 7);
  final dstEnd = _nthSundayOfMonthUtc(year, 11, 1, 6);

  return utc.isAfter(dstStart) && utc.isBefore(dstEnd);
}

DateTime _nthSundayOfMonthUtc(int year, int month, int nth, int hourUtc) {
  final firstDay = DateTime.utc(year, month, 1);
  final daysUntilSunday = DateTime.sunday - firstDay.weekday;
  final firstSunday = firstDay.add(
    Duration(days: daysUntilSunday < 0 ? daysUntilSunday + 7 : daysUntilSunday),
  );

  return firstSunday.add(Duration(days: (nth - 1) * 7, hours: hourUtc));
}

class MarketListDivider extends StatelessWidget {
  const MarketListDivider({super.key});
  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 10);
  }
}
