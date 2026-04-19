import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/cards/trade_card.dart';
import 'package:voxtrade_core/assembler/Controller/TradeHistoryController.dart';

const Color _kTradesPageBackground = Color(0xFFF5F7FA);
const Color _kTradesLabelMuted = Color(0xFF64748B);

class TradesPage extends StatefulWidget {
  const TradesPage({super.key});

  @override
  State<TradesPage> createState() => _TradesPageState();
}

class _TradesPageState extends State<TradesPage> {
  late final TradeHistoryController _controller;

  @override
  void initState() {
    super.initState();
    debugPrint('PAGE LOADED');
    _controller = Get.find<TradeHistoryController>();
    _controller.fetchTrades();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: _kTradesPageBackground,
      appBar: AppBar(
        title: Text(
          'Trades',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: _kTradesPageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.trades.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.errorMessage.value != null &&
            _controller.trades.isEmpty) {
          return _ErrorState(
            message: _controller.errorMessage.value!,
            onRetry: _controller.fetchTrades,
          );
        }

        if (_controller.trades.isEmpty) {
          return const _EmptyState(
            icon: Icons.swap_horiz_rounded,
            message: 'No trades yet',
          );
        }

        return RefreshIndicator(
          onRefresh: _controller.fetchTrades,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: _controller.trades.length,
            itemBuilder: (context, index) {
              return TradeCard(trade: _controller.trades[index]);
            },
          ),
        );
      }),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

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
              icon,
              size: 56,
              color: _kTradesLabelMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: _kTradesLabelMuted,
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

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
              color: _kTradesLabelMuted.withValues(alpha: 0.6),
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
                color: _kTradesLabelMuted,
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
