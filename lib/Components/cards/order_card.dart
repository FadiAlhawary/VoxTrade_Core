import 'package:flutter/material.dart';
import 'package:voxtrade_core/Components/ModelDto/OrderHistoryDTO.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order});

  final OrderHistory order;

  static const Color _kLabelMuted = Color(0xFF64748B);
  static const Color _kTitle = Color(0xFF0F172A);
  static const Color _kOpen = Color(0xFFF97316);
  static const Color _kFilled = Color(0xFF16A34A);
  static const Color _kCancelled = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final statusStyle = _statusStyle(order.status);

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
                  _displaySymbol(order.symbol),
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
              _StatusBadge(
                label: order.status.isEmpty ? '—' : order.status,
                fg: statusStyle.fg,
                bg: statusStyle.bg,
              ),
            ],
          ),
          const Spacer(),
          Center(
            child: Text(
              _orderTypeLabel(order.orderType),
              style: textTheme.bodyMedium?.copyWith(
                color: _kLabelMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: _BottomMetric(
                  label: 'Amount',
                  value: _formatQty(order),
                  textTheme: textTheme,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _BottomMetric(
                  label: 'Price',
                  value: _formatPrice(order),
                  textTheme: textTheme,
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

  static String _orderTypeLabel(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return '—';
    final lower = s.toLowerCase();
    if (lower.contains('market')) return 'Market';
    if (lower.contains('limit')) return 'Limit';
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  static _BadgeColors _statusStyle(String raw) {
    final s = raw.toLowerCase().trim();
    if (s.contains('open') ||
        s.contains('pending') ||
        s.contains('partial') ||
        s.contains('working')) {
      return _BadgeColors(fg: _kOpen, bg: const Color(0xFFFFEDD5));
    }
    if (s.contains('fill') ||
        s.contains('complete') ||
        s.contains('executed')) {
      return _BadgeColors(fg: _kFilled, bg: const Color(0xFFDCFCE7));
    }
    if (s.contains('cancel') ||
        s.contains('reject') ||
        s.contains('expire')) {
      return _BadgeColors(fg: _kCancelled, bg: const Color(0xFFFEE2E2));
    }
    return _BadgeColors(fg: _kLabelMuted, bg: const Color(0xFFF1F5F9));
  }

  static String _formatQty(OrderHistory o) {
    final num q = o.quantity ?? o.filledQuantity;
    return _formatNum(q);
  }

  static String _formatPrice(OrderHistory o) {
    final num? p =
        o.limitPrice ??
        o.price ??
        o.executionPrice ??
        o.averageFillPrice;
    return _formatNum(p);
  }

  static String _formatNum(num? v) {
    if (v == null) return '—';
    final d = v.toDouble();
    if (d == d.roundToDouble()) return d.toStringAsFixed(0);
    return d.toStringAsFixed(4).replaceFirst(RegExp(r'\.?0+$'), '');
  }
}

class _BadgeColors {
  const _BadgeColors({required this.fg, required this.bg});

  final Color fg;
  final Color bg;
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.fg,
    required this.bg,
  });

  final String label;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

class _BottomMetric extends StatelessWidget {
  const _BottomMetric({
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
            color: OrderCard._kLabelMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: OrderCard._kTitle,
          ),
        ),
      ],
    );
  }
}
