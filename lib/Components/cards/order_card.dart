import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:voxtrade_core/Components/ModelDto/OrderHistoryDTO.dart';
import 'package:voxtrade_core/Components/PopUp/PopUpModal.dart';

/// Horizontally scrollable orders table (matches [TradeHistoryTable] styling).
class OrderHistoryTable extends StatelessWidget {
  const OrderHistoryTable({
    super.key,
    required this.orders,
    required this.onCancelPending,
    required this.isCancelling,
  });

  final List<OrderHistory> orders;

  /// Invoked when user taps Cancel on a pending row.
  final Future<void> Function(OrderHistory order) onCancelPending;

  final bool Function(int orderId) isCancelling;

  static const double _minTableWidth = 880;

  static const Color _kOpen = Color(0xFFF97316);
  static const Color _kFilled = Color(0xFF16A34A);
  static const Color _kCancelled = Color(0xFFDC2626);

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
              child: _OrdersTableFrame(
                isDark: isDark,
                cs: cs,
                child: Table(
                  defaultColumnWidth: const FlexColumnWidth(1),
                  columnWidths: const {
                    0: FlexColumnWidth(1.25),
                    1: FlexColumnWidth(2.1),
                    2: FlexColumnWidth(1.35),
                    3: FlexColumnWidth(1.45),
                    4: FlexColumnWidth(1.25),
                    5: FlexColumnWidth(1.45),
                    6: FlexColumnWidth(1.65),
                  },
                  border: TableBorder.symmetric(
                    inside: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: isDark ? 0.25 : 0.4),
                    ),
                  ),
                  children: [
                    _headerRow(cs, textTheme, isDark),
                    ...orders.asMap().entries.map(
                          (e) => _dataRow(
                            context,
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
        _headerCell('Action', cs, textTheme),
        _headerCell('Symbol', cs, textTheme),
        _headerCell('Side', cs, textTheme),
        _headerCell('Type', cs, textTheme),
        _headerCell('Qty', cs, textTheme),
        _headerCell('Price', cs, textTheme),
        _headerCell('Status', cs, textTheme),
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

  TableRow _dataRow(
    BuildContext context,
    OrderHistory order,
    int index,
    ColorScheme cs,
    TextTheme textTheme,
    bool isDark,
  ) {
    final stripe = _stripeForDataRow(index, cs, isDark);
    final onSurface = cs.onSurface;
    final muted = cs.onSurfaceVariant;
    final statusColors = _statusStyle(order.status, isDark);

    return TableRow(
      decoration: BoxDecoration(color: stripe),
      children: [
        _actionCell(context, order, cs, textTheme, muted),
        _dataCell(
          textTheme,
          _displaySymbol(order.symbol),
          fontWeight: FontWeight.w800,
          fontSize: 13.75,
          color: onSurface,
        ),
        _dataCell(
          textTheme,
          order.actionType.isEmpty ? '—' : order.actionType,
          color: onSurface,
        ),
        _dataCell(
          textTheme,
          _orderTypeLabel(order.orderType),
          color: onSurface,
        ),
        _dataCell(
          textTheme,
          _formatQty(order),
          color: onSurface,
        ),
        _dataCell(
          textTheme,
          _formatPrice(order),
          color: onSurface,
        ),
        _statusCell(order.status, statusColors, textTheme),
      ],
    );
  }

  Widget _statusCell(
    String status,
    _BadgeColors colors,
    TextTheme textTheme,
  ) {
    final label = status.isEmpty ? '—' : status;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      child: Align(
        alignment: Alignment.centerLeft,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.bg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: colors.fg.withValues(alpha: 0.22)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.fg,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionCell(
    BuildContext context,
    OrderHistory order,
    ColorScheme cs,
    TextTheme textTheme,
    Color muted,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: order.isPendingStatus
            ? _cancelButton(context, order, cs, textTheme)
            : Text(
                '—',
                style: textTheme.bodyMedium?.copyWith(color: muted),
              ),
      ),
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

  Widget _cancelButton(
    BuildContext context,
    OrderHistory order,
    ColorScheme cs,
    TextTheme textTheme,
  ) {
    final busy = isCancelling(order.id);
    if (busy) {
      return SizedBox(
        height: 32,
        width: 32,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: cs.primary,
            ),
          ),
        ),
      );
    }

    return TextButton(
      onPressed: order.canCancel
          ? () => _showCancelConfirmation(context, order)
          : null,
      style: TextButton.styleFrom(
        foregroundColor: order.canCancel ? cs.error : cs.onSurfaceVariant,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        'Cancel',
        style: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

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

  static _BadgeColors _statusStyle(String raw, bool isDark) {
    final s = raw.toLowerCase().trim();
    if (s.contains('open') ||
        s.contains('pending') ||
        s.contains('partial') ||
        s.contains('working')) {
      return _BadgeColors(
        fg: _kOpen,
        bg: isDark
            ? _kOpen.withValues(alpha: 0.2)
            : const Color(0xFFFFEDD5),
      );
    }
    if (s.contains('fill') ||
        s.contains('complete') ||
        s.contains('executed')) {
      return _BadgeColors(
        fg: _kFilled,
        bg: isDark
            ? _kFilled.withValues(alpha: 0.2)
            : const Color(0xFFDCFCE7),
      );
    }
    if (s.contains('cancel') ||
        s.contains('reject') ||
        s.contains('expire')) {
      return _BadgeColors(
        fg: _kCancelled,
        bg: isDark
            ? _kCancelled.withValues(alpha: 0.2)
            : const Color(0xFFFEE2E2),
      );
    }
    return _BadgeColors(
      fg: const Color(0xFF64748B),
      bg: isDark
          ? const Color(0xFF64748B).withValues(alpha: 0.18)
          : const Color(0xFFF1F5F9),
    );
  }

  static String _formatQty(OrderHistory o) {
    final num q = o.quantity ?? o.filledQuantity;
    return _formatNum(q);
  }

  static String _formatPrice(OrderHistory o) {
    final num? p =
        o.limitPrice ?? o.price ?? o.executionPrice ?? o.averageFillPrice;
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

class _OrdersTableFrame extends StatelessWidget {
  const _OrdersTableFrame({
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
