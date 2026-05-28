import 'package:flutter/material.dart';
import 'package:voxtrade_core/Components/ModelDto/TradeHistoryDTO.dart';

class TradeHistoryTable extends StatelessWidget {
  const TradeHistoryTable({super.key, required this.trades});

  final List<TradeHistory> trades;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: List.generate(trades.length, (index) {
        final trade = trades[index];
        final pnl = _derivedPnl(trade);
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 220 + (index * 24)),
          tween: Tween<double>(begin: 0, end: 1),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 14),
                child: child,
              ),
            );
          },
          child: Column(
            children: [
              _TradeTile(trade: trade, pnl: pnl, isDark: isDark),
              if (index != trades.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Divider(
                    height: 1,
                    thickness: 0.8,
                    color: cs.outlineVariant.withValues(alpha: 0.18),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  static double? _derivedPnl(TradeHistory trade) {
    if (trade.tradeValue == null || trade.price == null || trade.quantity == null) {
      return null;
    }
    final signed = _isBuy(trade.side) ? -1.0 : 1.0;
    return (trade.tradeValue!.toDouble() - (trade.price!.toDouble() * trade.quantity!.toDouble())) *
        signed;
  }

  static bool _isBuy(String raw) {
    final s = raw.toLowerCase().trim();
    return s.contains('buy') || s == 'b';
  }

  static String sideLabel(String raw) {
    final s = raw.toLowerCase().trim();
    if (s.contains('buy') || s == 'b') return 'Buy';
    if (s.contains('sell') || s == 's') return 'Sell';
    if (raw.trim().isEmpty) return '—';
    return raw[0].toUpperCase() + raw.substring(1).toLowerCase();
  }

  static String formatNum(num? v) {
    if (v == null) return '—';
    final d = v.toDouble();
    if (d == d.roundToDouble()) return d.toStringAsFixed(0);
    return d.toStringAsFixed(4).replaceFirst(RegExp(r'\.?0+$'), '');
  }
}

class _TradeTile extends StatefulWidget {
  const _TradeTile({
    required this.trade,
    required this.pnl,
    required this.isDark,
  });

  final TradeHistory trade;
  final double? pnl;
  final bool isDark;

  @override
  State<_TradeTile> createState() => _TradeTileState();
}

class _TradeTileState extends State<_TradeTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final symbol = widget.trade.symbol.trim().isEmpty ? '—' : widget.trade.symbol;
    final isBuy = TradeHistoryTable._isBuy(widget.trade.side);
    final pnlTint = widget.pnl == null
        ? Colors.transparent
        : widget.pnl! >= 0
            ? const Color(0xFF22C55E).withValues(alpha: widget.isDark ? 0.08 : 0.05)
            : const Color(0xFFEF4444).withValues(alpha: widget.isDark ? 0.08 : 0.05);
    final sideColor = isBuy ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: () {},
        child: AnimatedScale(
          duration: const Duration(milliseconds: 120),
          scale: _pressed ? 0.985 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Color.alphaBlend(pnlTint, cs.surfaceContainerLowest),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: widget.isDark ? 0.22 : 0.06),
                  blurRadius: _pressed ? 8 : 14,
                  offset: Offset(0, _pressed ? 3 : 6),
                  spreadRadius: -6,
                ),
              ],
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        symbol,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: sideColor.withValues(alpha: widget.isDark ? 0.2 : 0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: sideColor.withValues(alpha: 0.35)),
                      ),
                      child: Text(
                        TradeHistoryTable.sideLabel(widget.trade.side),
                        style: textTheme.labelSmall?.copyWith(
                          color: sideColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.trade.instrumentName.trim().isEmpty
                      ? 'Executed trade'
                      : widget.trade.instrumentName,
                  style: textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _kv(context, 'Quantity', TradeHistoryTable.formatNum(widget.trade.quantity)),
                    ),
                    Expanded(
                      child: _kv(context, 'Price', TradeHistoryTable.formatNum(widget.trade.price)),
                    ),
                    Expanded(
                      child: _kv(context, 'Value', TradeHistoryTable.formatNum(widget.trade.tradeValue)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _kv(context, 'Executed', _fmtDate(widget.trade.executedAt)),
                    ),
                    if (widget.pnl != null)
                      Expanded(
                        child: _kv(
                          context,
                          'PnL',
                          '${widget.pnl! >= 0 ? '+' : ''}${TradeHistoryTable.formatNum(widget.pnl)}',
                          valueColor: widget.pnl! >= 0
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFEF4444),
                        ),
                      )
                    else
                      const Spacer(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _kv(
    BuildContext context,
    String k,
    String v, {
    Color? valueColor,
  }) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          k,
          style: textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        Text(
          v,
          style: textTheme.bodyMedium?.copyWith(
            color: valueColor ?? cs.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  String _fmtDate(DateTime dt) {
    final local = dt.toLocal();
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$m/$d $hh:$mm';
  }
}
