import 'package:flutter/material.dart';
import 'package:voxtrade_core/Models/Wallet_Transaction_Model.dart';

class WalletHistoryPage extends StatelessWidget {
  const WalletHistoryPage({
    super.key,
    this.transactions = const [],
  });

  static const Color _kPageBackground = Color(0xFFF5F7FA);
  static const Color _kLabelMuted = Color(0xFF64748B);
  static const Color _kCardWhite = Color(0xFFFFFFFF);
  static const Color _kBorderSubtle = Color(0xFFE2E8F0);
  static const Color _kPositiveGreen = Color(0xFF16A34A);
  static const Color _kNegativeRed = Color(0xFFDC2626);

  final List<WalletTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: _kPageBackground,
      appBar: AppBar(
        title: Text(
          'Wallet history',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: _kPageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: transactions.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'No wallet transactions available yet.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: _kLabelMuted,
                    height: 1.4,
                  ),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                final amountColor =
                    transaction.isPositive ? _kPositiveGreen : _kNegativeRed;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _kCardWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _kBorderSubtle),
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
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  transaction.formattedDate,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: _kLabelMuted,
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
                      const Divider(height: 1, color: _kBorderSubtle),
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
            ),
    );
  }
}

class _HistoryInfoTile extends StatelessWidget {
  const _HistoryInfoTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: WalletHistoryPage._kLabelMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
