import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/shimer/page_loading_shimmers.dart';
import 'package:voxtrade_core/Components/cards/order_card.dart';
import 'package:voxtrade_core/assembler/Controller/OrderHistory.dart';
import 'package:voxtrade_core/assembler/Controller/ThemeController.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderHistoryController controller =
        Get.find<OrderHistoryController>();

    return Obx(() {
      Get.find<ThemeController>().isDarkMode.value;
      controller.cancellingOrderId.value;
      final cs = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;

      if (controller.isLoading.value && controller.orders.isEmpty) {
        return Scaffold(
          backgroundColor: cs.surface,
          appBar: _ordersAppBar(textTheme, cs),
          body: const ListCardsPageShimmer(
            padding: EdgeInsets.fromLTRB(10, 6, 10, 18),
            cardHeight: 72,
          ),
        );
      }

      if (controller.errorMessage.value != null && controller.orders.isEmpty) {
        return Scaffold(
          backgroundColor: cs.surface,
          appBar: _ordersAppBar(textTheme, cs),
          body: _OrdersErrorState(
            message: controller.errorMessage.value!,
            onRetry: () => controller.fetchOrders(),
          ),
        );
      }

      if (controller.orders.isEmpty) {
        return Scaffold(
          backgroundColor: cs.surface,
          appBar: _ordersAppBar(textTheme, cs),
          body: const _OrdersEmptyState(),
        );
      }

      return Scaffold(
        backgroundColor: cs.surface,
        appBar: _ordersAppBar(textTheme, cs),
        body: RefreshIndicator(
          onRefresh: () => controller.fetchOrders(),
          color: cs.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 18),
            child: OrderHistoryTable(
              orders: controller.orders,
              onCancelPending: (o) => controller.cancelOrder(o),
              isCancelling: (id) => controller.cancellingOrderId.value == id,
            ),
          ),
        ),
      );
    });
  }

  static PreferredSizeWidget _ordersAppBar(
    TextTheme textTheme,
    ColorScheme cs,
  ) {
    return AppBar(
      title: Text(
        'Orders',
        style: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
          letterSpacing: -0.3,
        ),
      ),
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      foregroundColor: cs.onSurface,
    );
  }
}

class _OrdersEmptyState extends StatelessWidget {
  const _OrdersEmptyState();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: muted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No orders yet',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: muted,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersErrorState extends StatelessWidget {
  const _OrdersErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color: cs.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
