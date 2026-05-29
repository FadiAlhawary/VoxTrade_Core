import 'package:flutter/material.dart';

bool isShimmerDark(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}

/// Placeholder fill behind the animated shimmer sweep.
Color shimmerBaseColor(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  if (isShimmerDark(context)) {
    return const Color(0xFF24303C);
  }
  return scheme.surfaceContainerHighest;
}

/// Gradient colors for the animated [ShaderMask] sweep.
List<Color> shimmerMaskGradientColors(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  if (isShimmerDark(context)) {
    return [
      Colors.white.withValues(alpha: 0.03),
      Colors.white.withValues(alpha: 0.42),
      Colors.white.withValues(alpha: 0.03),
    ];
  }
  return [
    scheme.surfaceContainerHighest.withValues(alpha: 0.4),
    scheme.onSurface.withValues(alpha: 0.1),
    scheme.surfaceContainerHighest.withValues(alpha: 0.4),
  ];
}

/// Static gradient for simple blocks (legacy chart shimmer helper).
List<Color> shimmerStaticGradientColors(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  if (isShimmerDark(context)) {
    return const [Color(0xff1b2632), Color(0xff354552), Color(0xff1b2632)];
  }
  return [
    scheme.surfaceContainerHighest,
    scheme.surfaceContainerHigh,
    scheme.surfaceContainerHighest,
  ];
}
