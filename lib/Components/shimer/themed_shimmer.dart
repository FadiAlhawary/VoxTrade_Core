import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:voxtrade_core/utils/shimmer_theme.dart';

/// Animated shimmer mask that adapts to light and dark [Theme].
class ThemedShimmer extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const ThemedShimmer({
    super.key,
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, widgetChild) {
        final shimmerValue = animation.value;
        final pulseOpacity =
            0.86 + (0.14 * ((math.sin(shimmerValue * 2 * math.pi) + 1) / 2));
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-2.0 + (4.0 * shimmerValue), -0.25),
              end: Alignment(-0.8 + (4.0 * shimmerValue), 0.25),
              colors: shimmerMaskGradientColors(context),
              stops: const [0.42, 0.5, 0.58],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: Opacity(opacity: pulseOpacity, child: widgetChild),
        );
      },
    );
  }
}

/// Rounded placeholder block with themed base color and animated shimmer.
class ThemedShimmerBox extends StatelessWidget {
  final Animation<double> animation;
  final double height;
  final double widthFactor;
  final double borderRadius;

  const ThemedShimmerBox({
    super.key,
    required this.animation,
    required this.height,
    this.widthFactor = 1,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    final box = Container(
      height: height == double.infinity ? null : height,
      decoration: BoxDecoration(
        color: shimmerBaseColor(context),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );

    final shimmerChild = ThemedShimmer(animation: animation, child: box);

    if (widthFactor >= 1) {
      return shimmerChild;
    }

    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: shimmerChild,
    );
  }
}
