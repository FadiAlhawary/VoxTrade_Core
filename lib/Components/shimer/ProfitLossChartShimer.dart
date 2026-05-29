import 'package:flutter/material.dart';
import 'package:voxtrade_core/Components/shimer/themed_shimmer.dart';
import 'package:voxtrade_core/utils/chart_theme_helpers.dart';

class ProfitLossChartShimer extends StatefulWidget {
  final String? title;
  final VoidCallback? onRefresh;

  const ProfitLossChartShimer({super.key, this.title, this.onRefresh});

  @override
  State<ProfitLossChartShimer> createState() => _ProfitLossChartShimerState();
}

class _ProfitLossChartShimerState extends State<ProfitLossChartShimer>
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
                  widget.title ?? 'Profit / Loss',
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
          ThemedShimmerBox(
            animation: _shimmerAnimCtrl,
            height: 24,
            widthFactor: 0.35,
          ),
          const SizedBox(height: 12),
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
