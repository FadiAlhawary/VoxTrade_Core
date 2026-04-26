import 'package:flutter/material.dart';

class WalletHistoryChartShimer extends StatelessWidget {
  final String? title;
  final VoidCallback? onRefresh;

  const WalletHistoryChartShimer({super.key, this.title, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xff111821), Color(0xff0b1118)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xff273443)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title ?? 'Wallet History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ),
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                color: Colors.white70,
                tooltip: 'Refresh',
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Expanded(child: _ShimmerBlock(height: 42)),
              SizedBox(width: 8),
              Expanded(child: _ShimmerBlock(height: 42)),
              SizedBox(width: 8),
              Expanded(child: _ShimmerBlock(height: 42)),
            ],
          ),
          const SizedBox(height: 10),
          const Expanded(child: _ShimmerBlock(height: double.infinity)),
        ],
      ),
    );
  }
}

class _ShimmerBlock extends StatelessWidget {
  final double height;

  const _ShimmerBlock({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height == double.infinity ? null : height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Color(0xff1b2632), Color(0xff253242), Color(0xff1b2632)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }
}
