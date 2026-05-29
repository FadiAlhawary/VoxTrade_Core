import 'package:flutter/material.dart';
import 'package:voxtrade_core/utils/shimmer_theme.dart';

BoxDecoration dashboardChartCardDecoration(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  if (isDark) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: const LinearGradient(
        colors: [Color(0xff111821), Color(0xff0b1118)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(color: const Color(0xff273443)),
      boxShadow: const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.25),
          blurRadius: 12,
          offset: Offset(0, 6),
        ),
      ],
    );
  }

  return BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    color: scheme.surfaceContainerLow,
    border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.45)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

Color dashboardChartMutedText(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return Theme.of(context).brightness == Brightness.dark
      ? Colors.white70
      : scheme.onSurfaceVariant;
}

Color dashboardChartGridLine(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xff263341)
      : scheme.outlineVariant.withValues(alpha: 0.35);
}

Color dashboardChartBorder(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xff2e3a46)
      : scheme.outlineVariant.withValues(alpha: 0.5);
}

Color dashboardChartTooltipBackground(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xff1b2530)
      : scheme.inverseSurface;
}

List<Color> dashboardShimmerBlockColors(BuildContext context) {
  return shimmerStaticGradientColors(context);
}
