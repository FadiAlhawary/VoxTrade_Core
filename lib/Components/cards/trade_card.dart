import 'package:flutter/material.dart';
import 'package:voxtrade_core/Components/ModelDto/TradeHistoryDTO.dart';

class TradeCard extends StatelessWidget {
  const TradeCard({super.key, required this.trade});

  final TradeHistory trade;

  static const Color _kLabelMuted = Color(0xFF64748B);
  static const Color _kTitle = Color(0xFF0F172A);
  static const Color _kBuy = Color(0xFF16A34A);
  static const Color _kSell = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final sideLabel = _sideLabel(trade.side);
    final isBuy = _isBuy(trade.side);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _displaySymbol(trade.symbol),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: _kTitle,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _SideBadge(label: sideLabel, isBuy: isBuy),
            ],
          ),
          const SizedBox(height: 12),
          _MetricRow(
            label: 'Amount',
            value: _formatNum(trade.quantity),
            textTheme: textTheme,
          ),
          const SizedBox(height: 8),
          _MetricRow(
            label: 'Price',
            value: _formatNum(trade.price),
            textTheme: textTheme,
          ),
          const Spacer(),
          const Divider(height: 16, color: Color(0xFFE2E8F0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'P/L',
                style: textTheme.bodySmall?.copyWith(
                  color: _kLabelMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _pnlDisplay(trade),
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: _pnlColor(trade),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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

  /// API has no realized P/L field; show em dash unless extended later.
  static String _pnlDisplay(TradeHistory t) {
    return '—';
  }

  static Color _pnlColor(TradeHistory t) {
    return _kLabelMuted;
  }
}

class _SideBadge extends StatelessWidget {
  const _SideBadge({required this.label, required this.isBuy});

  final String label;
  final bool isBuy;

  @override
  Widget build(BuildContext context) {
    final bg = isBuy
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFFEE2E2);
    final fg = isBuy ? TradeCard._kBuy : TradeCard._kSell;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
    required this.textTheme,
  });

  final String label;
  final String value;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: TradeCard._kLabelMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: TradeCard._kTitle,
          ),
        ),
      ],
    );
  }
}
