import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:voxtrade_core/Components/ModelDto/TradeHistoryDTO.dart';

/// Wide, horizontally scrollable trade table with primary header and zebra rows.
class TradeHistoryTable extends StatelessWidget {
  const TradeHistoryTable({super.key, required this.trades});

  final List<TradeHistory> trades;

  static const Color _kBuy = Color(0xFF16A34A);
  static const Color _kSell = Color(0xFFDC2626);

  /// Minimum content width so columns stay readable; narrower viewports scroll horizontally.
  static const double _minTableWidth = 760;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final minW = math.max(constraints.maxWidth, _minTableWidth);

        return Scrollbar(
          thickness: 5,
          radius: const Radius.circular(6),
          thumbVisibility: false,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: minW),
              child: _TableFrame(
                isDark: isDark,
                cs: cs,
                child: Table(
                  defaultColumnWidth: const FlexColumnWidth(1),
                  columnWidths: const {
                    0: FlexColumnWidth(2.35),
                    1: FlexColumnWidth(1.45),
                    2: FlexColumnWidth(1.45),
                    3: FlexColumnWidth(1.55),
                    4: FlexColumnWidth(1.65),
                    5: FlexColumnWidth(1.15),
                  },
                  border: TableBorder.symmetric(
                    inside: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: isDark ? 0.25 : 0.4),
                    ),
                  ),
                  children: [
                    _headerRow(cs, textTheme, isDark),
                    ...trades.asMap().entries.map(
                          (e) => _dataRow(
                            e.value,
                            e.key,
                            cs,
                            textTheme,
                            isDark,
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  TableRow _headerRow(
    ColorScheme cs,
    TextTheme textTheme,
    bool isDark,
  ) {
    return TableRow(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary,
            Color.lerp(cs.primary, cs.surface, isDark ? 0.12 : 0.08) ??
                cs.primary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.24),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      children: [
        _headerCell('Symbol', cs, textTheme),
        _headerCell('Side', cs, textTheme),
        _headerCell('Qty', cs, textTheme),
        _headerCell('Price', cs, textTheme),
        _headerCell('Value', cs, textTheme),
        _headerCell('P/L', cs, textTheme),
      ],
    );
  }

  Widget _headerCell(String label, ColorScheme cs, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Text(
        label.toUpperCase(),
        style: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 11.5,
          letterSpacing: 0.85,
          color: cs.onPrimary,
        ),
      ),
    );
  }

  /// Row index 0 = visual row 1 (light), 1 = row 2 (grey), 2 = row 3 (light), …
  TableRow _dataRow(
    TradeHistory trade,
    int index,
    ColorScheme cs,
    TextTheme textTheme,
    bool isDark,
  ) {
    final stripe = _stripeForDataRow(index, cs, isDark);
    final onSurface = cs.onSurface;
    final muted = cs.onSurfaceVariant;

    return TableRow(
      decoration: BoxDecoration(color: stripe),
      children: [
        _dataCell(
          textTheme,
          _displaySymbol(trade.symbol),
          fontWeight: FontWeight.w800,
          fontSize: 13.75,
          color: onSurface,
        ),
        _sideCell(trade, textTheme, isDark),
        _dataCell(
          textTheme,
          _formatNum(trade.quantity),
          color: onSurface,
        ),
        _dataCell(
          textTheme,
          _formatNum(trade.price),
          color: onSurface,
        ),
        _dataCell(
          textTheme,
          _formatNum(trade.tradeValue),
          color: onSurface,
        ),
        _dataCell(
          textTheme,
          _pnlDisplay(trade),
          color: muted,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }

  /// Row 1, 3, 5… (index 0, 2, 4…) = light stripe; row 2, 4… = grey stripe.
  Color _stripeForDataRow(int index, ColorScheme cs, bool isDark) {
    final isEven = index.isEven;
    if (!isDark) {
      return isEven ? Colors.white : const Color(0xFFE8EDF4);
    }
    if (isEven) {
      return cs.surface;
    }
    return Color.alphaBlend(
      cs.onSurface.withValues(alpha: 0.072),
      cs.surface,
    );
  }

  Widget _dataCell(
    TextTheme textTheme,
    String text, {
    FontWeight fontWeight = FontWeight.w600,
    double? fontSize,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: textTheme.bodyLarge?.copyWith(
          fontWeight: fontWeight,
          fontSize: fontSize ?? 13.25,
          color: color,
          height: 1.25,
        ),
      ),
    );
  }

  Widget _sideCell(
    TradeHistory trade,
    TextTheme textTheme,
    bool isDark,
  ) {
    final label = _sideLabel(trade.side);
    final isBuy = _isBuy(trade.side);
    final bg = _sideBadgeBackground(isBuy, isDark);
    final fg = isBuy ? _kBuy : _kSell;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      child: Align(
        alignment: Alignment.centerLeft,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: fg.withValues(alpha: isDark ? 0.35 : 0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.25,
                color: fg,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _sideBadgeBackground(bool isBuy, bool isDark) {
    if (isBuy) {
      return isDark
          ? const Color(0xFF14532D).withValues(alpha: 0.55)
          : const Color(0xFFDCFCE7);
    }
    return isDark
        ? const Color(0xFF7F1D1D).withValues(alpha: 0.55)
        : const Color(0xFFFEE2E2);
  }

  static String _displaySymbol(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return '—';
    return s;
  }

  static String _sideLabel(String raw) {
    final s = raw.toLowerCase().trim();
    if (s.contains('buy') || s == 'b') return 'Buy';
    if (s.contains('sell') || s == 's') return 'Sell';
    if (raw.trim().isEmpty) return '—';
    return raw[0].toUpperCase() + raw.substring(1).toLowerCase();
  }

  static bool _isBuy(String raw) {
    final s = raw.toLowerCase().trim();
    return s.contains('buy') || s == 'b';
  }

  static String _formatNum(num? v) {
    if (v == null) return '—';
    final d = v.toDouble();
    if (d == d.roundToDouble()) return d.toStringAsFixed(0);
    return d.toStringAsFixed(4).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  static String _pnlDisplay(TradeHistory t) {
    return '—';
  }
}

class _TableFrame extends StatelessWidget {
  const _TableFrame({
    required this.child,
    required this.cs,
    required this.isDark,
  });

  final Widget child;
  final ColorScheme cs;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
            spreadRadius: -3,
          ),
          BoxShadow(
            color: cs.primary.withValues(alpha: isDark ? 0.1 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: isDark ? 0.45 : 0.55),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: cs.surface,
          child: child,
        ),
      ),
    );
  }
}
