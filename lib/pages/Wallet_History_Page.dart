import 'package:flutter/material.dart';

/// Placeholder full-screen wallet transaction history.
class WalletHistoryPage extends StatelessWidget {
  const WalletHistoryPage({super.key});

  static const Color _kPageBackground = Color(0xFFF5F7FA);
  static const Color _kLabelMuted = Color(0xFF64748B);

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Full transaction history will appear here.',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: _kLabelMuted,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
