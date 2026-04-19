import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/Loader.dart';
import 'package:voxtrade_core/Components/cards/trade_card.dart';
import 'package:voxtrade_core/assembler/Controller/ThemeController.dart';
import 'package:voxtrade_core/assembler/Controller/TradeHistoryController.dart';

class TradesPage extends StatelessWidget {
  const TradesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TradeHistoryController controller =
        Get.find<TradeHistoryController>();

    return Obx(() {
      Get.find<ThemeController>().isDarkMode.value;
      final cs = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;

      if (controller.isLoading.value && controller.trades.isEmpty) {
        return Scaffold(
          backgroundColor: cs.surface,
          appBar: _tradesAppBar(textTheme, cs),
          body: const Loader(isCenter: true),
        );
      }

      if (controller.errorMessage.value != null &&
          controller.trades.isEmpty) {
        return Scaffold(
          backgroundColor: cs.surface,
          appBar: _tradesAppBar(textTheme, cs),
          body: _ErrorState(
            message: controller.errorMessage.value!,
            onRetry: controller.fetchTrades,
          ),
        );
      }

      if (controller.trades.isEmpty) {
        return Scaffold(
          backgroundColor: cs.surface,
          appBar: _tradesAppBar(textTheme, cs),
          body: const _EmptyState(
            icon: Icons.swap_horiz_rounded,
            message: 'No trades yet',
          ),
        );
      }

      return Scaffold(
        backgroundColor: cs.surface,
        appBar: _tradesAppBar(textTheme, cs),
        body: RefreshIndicator(
          onRefresh: controller.fetchTrades,
          color: cs.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 18),
            child: TradeHistoryTable(trades: controller.trades),
          ),
        ),
      );
    });
  }

  static PreferredSizeWidget _tradesAppBar(TextTheme textTheme, ColorScheme cs) {
    return AppBar(
      title: Text(
        'Trades',
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final muted = cs.onSurfaceVariant;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 56,
              color: muted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

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
