import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/shimer/page_loading_shimmers.dart';
import 'package:voxtrade_core/Models/Wallet_Transaction_Model.dart';
import 'package:voxtrade_core/assembler/Controller/Wallet_Controller.dart';

class WalletHistoryPage extends StatelessWidget {
  const WalletHistoryPage({super.key, this.transactions = const []});

  static const Color _kPositiveGreen = Color(0xFF16A34A);
  static const Color _kNegativeRed = Color(0xFFDC2626);

  final List<WalletTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    final walletController = Get.find<WalletController>();
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(
          'Wallet history',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: scheme.onSurface,
      ),
      body: Obx(() {
        final List<WalletTransaction> effectiveTransactions =
            transactions.isNotEmpty
                ? transactions
                : walletController.wallet.value.walletHistory
                    .map(WalletTransaction.fromDto)
                    .toList();

        if (walletController.isLoading.value && effectiveTransactions.isEmpty) {
          return const ListCardsPageShimmer(
            cardHeight: 88,
            borderRadius: 16,
          );
        }

        if (effectiveTransactions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'No wallet transactions available yet.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: effectiveTransactions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final transaction = effectiveTransactions[index];
            final amountColor =
                transaction.isPositive ? _kPositiveGreen : _kNegativeRed;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.transactionType,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              transaction.formattedDate,
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        transaction.formattedAmount,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: amountColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(
                    height: 1,
                    color: scheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _HistoryInfoTile(
                          label: 'Balance before',
                          value:
                              '\$${transaction.balanceBefore.toStringAsFixed(2)}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _HistoryInfoTile(
                          label: 'Balance after',
                          value:
                              '\$${transaction.balanceAfter.toStringAsFixed(2)}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

class _HistoryInfoTile extends StatelessWidget {
  const _HistoryInfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}
