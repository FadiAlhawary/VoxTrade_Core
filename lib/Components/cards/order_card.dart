import 'package:flutter/material.dart';
import 'package:voxtrade_core/Components/ModelDto/OrderHistoryDTO.dart';
import 'package:voxtrade_core/Components/PopUp/PopUpModal.dart';

class OrderHistoryTable extends StatelessWidget {
  const OrderHistoryTable({
    super.key,
    required this.orders,
    required this.onCancelPending,
    required this.isCancelling,
  });

  final List<OrderHistory> orders;
  final Future<void> Function(OrderHistory order) onCancelPending;
  final bool Function(int orderId) isCancelling;

  static const Color _kPending = Color(0xFFF59E0B);
  static const Color _kCompleted = Color(0xFF22C55E);
  static const Color _kCancelled = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: List.generate(orders.length, (index) {
        final order = orders[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 240 + (index * 24)),
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
              _OrderTile(
                order: order,
                isDark: isDark,
                isCancelling: isCancelling(order.id),
                statusStyle: _statusStyle(order.status, isDark),
                onCancel: () => _showCancelConfirmation(context, order),
              ),
              if (index != orders.length - 1)
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

  void _showCancelConfirmation(BuildContext context, OrderHistory order) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final body = Theme.of(dialogContext).textTheme.bodyLarge;
        return PopUpModal(
          title: 'Cancel order',
          height: 140,
          centerTitle: true,
          content: Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Are you sure you want to cancel order #${order.id} for '
              '${order.symbol.trim().isEmpty ? '—' : order.symbol}?',
              style: body,
            ),
          ),
          onApply: () async {
            Navigator.of(dialogContext).pop();
            await onCancelPending(order);
          },
        );
      },
    );
  }

  static _StatusStyle _statusStyle(String raw, bool isDark) {
    final s = raw.toLowerCase().trim();
    if (s.contains('open') ||
        s.contains('pending') ||
        s.contains('partial') ||
        s.contains('working')) {
      return _StatusStyle(
        fg: _kPending,
        bg: _kPending.withValues(alpha: isDark ? 0.18 : 0.12),
      );
    }
    if (s.contains('fill') ||
        s.contains('complete') ||
        s.contains('executed')) {
      return _StatusStyle(
        fg: _kCompleted,
        bg: _kCompleted.withValues(alpha: isDark ? 0.18 : 0.12),
      );
    }
    if (s.contains('cancel') ||
        s.contains('reject') ||
        s.contains('expire')) {
      return _StatusStyle(
        fg: _kCancelled,
        bg: _kCancelled.withValues(alpha: isDark ? 0.16 : 0.1),
      );
    }
    return _StatusStyle(
      fg: const Color(0xFF94A3B8),
      bg: const Color(0xFF94A3B8).withValues(alpha: isDark ? 0.16 : 0.1),
    );
  }

  static String formatNum(num? v) {
    if (v == null) return '—';
    final d = v.toDouble();
    if (d == d.roundToDouble()) return d.toStringAsFixed(0);
    return d.toStringAsFixed(4).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  static String formatQty(OrderHistory o) {
    final num q = o.quantity ?? o.filledQuantity;
    return formatNum(q);
  }

  static String formatPrice(OrderHistory o) {
    final num? p = o.limitPrice ?? o.price ?? o.executionPrice ?? o.averageFillPrice;
    return formatNum(p);
  }

  static String orderTypeLabel(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return '—';
    final lower = s.toLowerCase();
    if (lower.contains('market')) return 'Market';
    if (lower.contains('limit')) return 'Limit';
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }
}

class _OrderTile extends StatefulWidget {
  const _OrderTile({
    required this.order,
    required this.statusStyle,
    required this.isDark,
    required this.isCancelling,
    required this.onCancel,
  });

  final OrderHistory order;
  final _StatusStyle statusStyle;
  final bool isDark;
  final bool isCancelling;
  final VoidCallback onCancel;

  @override
  State<_OrderTile> createState() => _OrderTileState();
}

class _OrderTileState extends State<_OrderTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final symbol = widget.order.symbol.trim().isEmpty ? '—' : widget.order.symbol;
    final pendingTint = widget.order.isPendingStatus
        ? const Color(0xFFF59E0B).withValues(alpha: widget.isDark ? 0.07 : 0.045)
        : Colors.transparent;

    final tile = AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: _pressed ? 0.985 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Color.alphaBlend(pendingTint, cs.surfaceContainerLowest),
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
                _StatusChip(label: widget.order.status, style: widget.statusStyle),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.order.actionType} • ${OrderHistoryTable.orderTypeLabel(widget.order.orderType)}',
              style: textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _kv(context, 'Quantity', OrderHistoryTable.formatQty(widget.order)),
                ),
                Expanded(
                  child: _kv(context, 'Price', OrderHistoryTable.formatPrice(widget.order)),
                ),
                Expanded(
                  child: _kv(context, 'Time', _fmtDate(widget.order.createdAt)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.order.isPendingStatus && widget.order.canCancel)
                  _cancelButton(context),
              ],
            ),
          ],
        ),
      ),
    );

    if (!widget.order.isPendingStatus || !widget.order.canCancel) {
      return _tileInk(context, tile);
    }

    return Dismissible(
      key: ValueKey('order-${widget.order.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        widget.onCancel();
        return false;
      },
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Cancel Order',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
        ),
      ),
      child: _tileInk(context, tile),
    );
  }

  Widget _tileInk(BuildContext context, Widget child) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: () {},
        child: child,
      ),
    );
  }

  Widget _cancelButton(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    if (widget.isCancelling) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: cs.primary,
        ),
      );
    }
    return FilledButton.tonal(
      onPressed: widget.onCancel,
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 34),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: cs.errorContainer.withValues(alpha: 0.22),
      ),
      child: Text(
        'Cancel Order',
        style: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: cs.error,
        ),
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v) {
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
            color: cs.onSurface,
            fontWeight: FontWeight.w600,
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.style});

  final String label;
  final _StatusStyle style;

  @override
  Widget build(BuildContext context) {
    final display = label.trim().isEmpty ? 'Unknown' : label;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: style.fg.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: style.fg.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        display,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: style.fg,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _StatusStyle {
  const _StatusStyle({required this.fg, required this.bg});

  final Color fg;
  final Color bg;
}
