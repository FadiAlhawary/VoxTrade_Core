import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/cards/order_card.dart';
import 'package:voxtrade_core/assembler/Controller/OrderHistory.dart';

const Color _kOrdersPageBackground = Color(0xFFF5F7FA);
const Color _kOrdersLabelMuted = Color(0xFF64748B);

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late final OrderHistoryController _controller;

  @override
  void initState() {
    super.initState();
    debugPrint('PAGE LOADED');
    _controller = Get.find<OrderHistoryController>();
    _controller.fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: _kOrdersPageBackground,
      appBar: AppBar(
        title: Text(
          'Orders',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: _kOrdersPageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.errorMessage.value != null &&
            _controller.orders.isEmpty) {
          return _OrdersErrorState(
            message: _controller.errorMessage.value!,
            onRetry: () => _controller.fetchOrders(),
          );
        }

        if (_controller.orders.isEmpty) {
          return const _OrdersEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => _controller.fetchOrders(),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: _controller.orders.length,
            itemBuilder: (context, index) {
              return OrderCard(order: _controller.orders[index]);
            },
          ),
        );
      }),
    );
  }
}

class _OrdersEmptyState extends StatelessWidget {
  const _OrdersEmptyState();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: _kOrdersLabelMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No orders yet',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: _kOrdersLabelMuted,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color: _kOrdersLabelMuted.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: _kOrdersLabelMuted,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
