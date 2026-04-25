import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/assembler/Controller/market_chart_controller.dart';
import 'package:voxtrade_core/routes/route_names.dart';

class MarketChartTile extends StatelessWidget {
  const MarketChartTile({super.key, required this.symbol, this.index = 0});

  final String symbol;
  final int index;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MarketChartController(symbol), tag: symbol);
    final meta = _symbolMeta(symbol);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.toNamed(RouteStrings.marketBuySell, arguments: symbol),
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0xFF1F2C46),
            border: Border.all(color: const Color(0xFF2C3C5D), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: GetBuilder<MarketChartController>(
              tag: symbol,
              id: controller.priceUpdateId,
              builder: (controller) {
                final candles = controller.candles;
                final sparkline = candles
                    .map((c) => c.close)
                    .where((v) => v.isFinite)
                    .toList(growable: false);
                final lastPrice = controller.lastPrice.value;
                final open = candles.isNotEmpty ? candles.first.open : 0.0;
                final delta =
                    open == 0 ? 0.0 : ((lastPrice - open) / open) * 100;
                final isUp = delta >= 0;
                final changeColor =
                    isUp ? const Color(0xFF34D399) : const Color(0xFFF87171);

                return Row(
                  children: [
                    _LogoTile(meta: meta),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meta.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFEFF4FF),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            meta.ticker,
                            style: const TextStyle(
                              color: Color(0xFF97A6C9),
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
                          strokeColor: changeColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
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
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '\$${lastPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
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
  });

  final String name;
  final String ticker;
  final IconData icon;
  final Color iconColor;
}

_SymbolMeta _symbolMeta(String symbol) {
  final raw = symbol.contains(':') ? symbol.split(':').last : symbol;
  switch (raw.toUpperCase()) {
    case 'AAPL':
      return const _SymbolMeta(
        name: 'Apple Inc.',
        ticker: 'AAPL',
        icon: Icons.phone_iphone_rounded,
        iconColor: Color(0xFF101216),
      );
    case 'NVDA':
      return const _SymbolMeta(
        name: 'Nvidia',
        ticker: 'NVDA',
        icon: Icons.memory_rounded,
        iconColor: Color(0xFF3B9B36),
      );
    case 'ZM':
      return const _SymbolMeta(
        name: 'Zoom Video',
        ticker: 'ZM',
        icon: Icons.videocam_rounded,
        iconColor: Color(0xFF3B82F6),
      );
    case 'MSFT':
      return const _SymbolMeta(
        name: 'Microsoft',
        ticker: 'MSFT',
        icon: Icons.window_rounded,
        iconColor: Color(0xFF0B66C3),
      );
    default:
      return _SymbolMeta(
        name: raw.replaceAll('_', '/'),
        ticker: raw.toUpperCase(),
        icon: Icons.show_chart_rounded,
        iconColor: const Color(0xFF3555C8),
      );
  }
}

class MarketListDivider extends StatelessWidget {
  const MarketListDivider({super.key});
  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 10);
  }
}
