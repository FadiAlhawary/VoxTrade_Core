import 'package:flutter/material.dart';
import 'package:voxtrade_core/Components/shimer/themed_shimmer.dart';
import 'package:voxtrade_core/utils/chart_theme_helpers.dart';

class WalletHistoryChartShimer extends StatefulWidget {
  final String? title;
  final VoidCallback? onRefresh;

  const WalletHistoryChartShimer({super.key, this.title, this.onRefresh});

  @override
  State<WalletHistoryChartShimer> createState() => _WalletHistoryChartShimerState();
}

class _WalletHistoryChartShimerState extends State<WalletHistoryChartShimer>
    with SingleTickerProviderStateMixin {
  static const _shimmerDuration = Duration(milliseconds: 950);
  late final AnimationController _shimmerAnimCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerAnimCtrl = AnimationController(
      vsync: this,
      duration: _shimmerDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerAnimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mutedText = dashboardChartMutedText(context);

    return Container(
      decoration: dashboardChartCardDecoration(context),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title ?? 'Wallet History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.onRefresh,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                color: mutedText,
                tooltip: 'Refresh',
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ThemedShimmerBox(
                  animation: _shimmerAnimCtrl,
                  height: 42,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ThemedShimmerBox(
                  animation: _shimmerAnimCtrl,
                  height: 42,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ThemedShimmerBox(
                  animation: _shimmerAnimCtrl,
                  height: 42,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ThemedShimmerBox(
              animation: _shimmerAnimCtrl,
              height: double.infinity,
            ),
          ),
        ],
      ),
    );
  }
}
