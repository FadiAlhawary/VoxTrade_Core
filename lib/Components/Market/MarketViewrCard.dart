import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/assembler/Controller/market_chart_controller.dart';
import 'package:voxtrade_core/routes/route_names.dart';

class MarketChartTile extends StatelessWidget {
  final String symbol;
  final int index;

  const MarketChartTile({super.key, required this.symbol, this.index = 0});

  static Color _accent(ColorScheme scheme, int i) {
    final accents = [scheme.primary, scheme.secondary, scheme.tertiary];
    return accents[i % accents.length];
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MarketChartController(symbol), tag: symbol);
    final scheme = Theme.of(context).colorScheme;
    final accent = _accent(scheme, index);
    final parts = symbol.split(':');
    final exchange = parts.length > 1 ? parts.first : '';
    final pair = parts.length > 1 ? parts.sublist(1).join(':') : symbol;

    return Obx(() {
      final hasCandles = controller.candles.isNotEmpty;
      final high = hasCandles ? controller.candles.first.high : null;
      final low = hasCandles ? controller.candles.first.low : null;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.toNamed(RouteStrings.marketBuySell, arguments: symbol);
          },
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.surfaceContainerHighest.withValues(alpha: 0.85),
                  scheme.surface.withValues(alpha: 0.98),
                ],
              ),
              border: Border.all(
                color: accent.withValues(alpha: 0.35),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.14),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [accent, scheme.secondary],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (exchange.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: accent.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Text(
                                exchange,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                  color: accent,
                                ),
                              ),
                            ),
                          ),
                        Text(
                          pair,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              'Last',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              controller.lastPrice.value.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                                color: scheme.primary,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _HlChip(
                                label: 'High',
                                value: high,
                                icon: Icons.north_east_rounded,
                                fg: _highFg(scheme),
                                bg: _highFg(scheme).withValues(alpha: 0.12),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: _HighLowSeparator(color: scheme),
                            ),
                            Expanded(
                              child: _HlChip(
                                label: 'Low',
                                value: low,
                                icon: Icons.south_west_rounded,
                                fg: _lowFg(scheme),
                                bg: _lowFg(scheme).withValues(alpha: 0.12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  static Color _highFg(ColorScheme scheme) {
    return scheme.brightness == Brightness.dark
        ? const Color(0xFF69F0AE)
        : const Color(0xFF00796B);
  }

  static Color _lowFg(ColorScheme scheme) {
    return scheme.brightness == Brightness.dark
        ? const Color(0xFFFF9E80)
        : const Color(0xFFC62828);
  }
}

class _HlChip extends StatelessWidget {
  const _HlChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.fg,
    required this.bg,
  });

  final String label;
  final double? value;
  final IconData icon;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    final text = value != null ? value!.toStringAsFixed(4) : '—';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: fg.withValues(alpha: 0.85),
                  ),
                ),
                Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: fg,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Vertical accent between session high / low — reads as a clear split without heavy chrome.
class _HighLowSeparator extends StatelessWidget {
  const _HighLowSeparator({required this.color});

  final ColorScheme color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
        height: 22,
        width: 14,
        child: Stack(
          alignment: Alignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.outlineVariant.withValues(alpha: 0.15),
                    color.primary.withValues(alpha: 0.55),
                    color.secondary.withValues(alpha: 0.45),
                    color.outlineVariant.withValues(alpha: 0.15),
                  ],
                ),
              ),
              child: const SizedBox(width: 3, height: 22),
            ),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.surfaceContainerHighest,
                border: Border.all(
                  color: color.primary.withValues(alpha: 0.65),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.primary.withValues(alpha: 0.25),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MarketListDivider extends StatelessWidget {
  const MarketListDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              height: 1,
              thickness: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(
              Icons.show_chart_rounded,
              size: 14,
              color: scheme.primary.withValues(alpha: 0.35),
            ),
          ),
          Expanded(
            child: Divider(
              height: 1,
              thickness: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}
