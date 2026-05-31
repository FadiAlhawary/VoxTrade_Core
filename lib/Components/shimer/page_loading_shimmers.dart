import 'package:flutter/material.dart';
import 'package:voxtrade_core/Components/shimer/themed_shimmer.dart';
import 'package:voxtrade_core/utils/shimmer_theme.dart';

/// Shared animation duration for page-level shimmers.
const Duration kPageShimmerDuration = Duration(milliseconds: 950);

/// Vertical list of card-shaped shimmer placeholders (orders, trades, wallet history, etc.).
class ListCardsPageShimmer extends StatefulWidget {
  const ListCardsPageShimmer({
    super.key,
    this.itemCount = 6,
    this.cardHeight = 78,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 24),
    this.spacing = 10,
    this.borderRadius = 14,
  });

  final int itemCount;
  final double cardHeight;
  final EdgeInsets padding;
  final double spacing;
  final double borderRadius;

  @override
  State<ListCardsPageShimmer> createState() => _ListCardsPageShimmerState();
}

class _ListCardsPageShimmerState extends State<ListCardsPageShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: kPageShimmerDuration)
      ..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = shimmerBaseColor(context);

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: widget.padding,
      itemCount: widget.itemCount,
      separatorBuilder: (_, __) => SizedBox(height: widget.spacing),
      itemBuilder: (_, __) {
        return ThemedShimmer(
          animation: _anim,
          child: Container(
            height: widget.cardHeight,
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        );
      },
    );
  }
}

/// Dashboard overview shimmer: header, KPI row, and chart blocks.
class DashboardPageShimmer extends StatefulWidget {
  const DashboardPageShimmer({super.key});

  @override
  State<DashboardPageShimmer> createState() => _DashboardPageShimmerState();
}

class _DashboardPageShimmerState extends State<DashboardPageShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: kPageShimmerDuration)
      ..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Widget _block(double h, {double radius = 14, double? widthFactor}) {
    final box = Container(
      height: h,
      decoration: BoxDecoration(
        color: shimmerBaseColor(context),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
    final shimmer = ThemedShimmer(animation: _anim, child: box);
    if (widthFactor == null) return shimmer;
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: shimmer,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        _block(52, radius: 12),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _block(88, radius: 14)),
            const SizedBox(width: 10),
            Expanded(child: _block(88, radius: 14)),
            const SizedBox(width: 10),
            Expanded(child: _block(88, radius: 14)),
          ],
        ),
        const SizedBox(height: 14),
        _block(240, radius: 16),
        const SizedBox(height: 12),
        _block(240, radius: 16),
        const SizedBox(height: 16),
        _block(320, radius: 16),
        const SizedBox(height: 16),
        _block(340, radius: 16),
      ],
    );
  }
}

/// Admin dashboard shimmer with stat tiles and chart blocks.
class AdminDashboardPageShimmer extends StatefulWidget {
  const AdminDashboardPageShimmer({super.key});

  @override
  State<AdminDashboardPageShimmer> createState() =>
      _AdminDashboardPageShimmerState();
}

class _AdminDashboardPageShimmerState extends State<AdminDashboardPageShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: kPageShimmerDuration)
      ..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Widget _block(double h, {double radius = 14}) {
    return ThemedShimmer(
      animation: _anim,
      child: Container(
        height: h,
        decoration: BoxDecoration(
          color: shimmerBaseColor(context),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Row(
          children: [
            Expanded(child: _block(96, radius: 14)),
            const SizedBox(width: 10),
            Expanded(child: _block(96, radius: 14)),
            const SizedBox(width: 10),
            Expanded(child: _block(96, radius: 14)),
          ],
        ),
        const SizedBox(height: 14),
        _block(280, radius: 16),
        const SizedBox(height: 12),
        _block(280, radius: 16),
        const SizedBox(height: 12),
        _block(220, radius: 16),
      ],
    );
  }
}

/// Market list tile shimmer with symbol row and chart area.
class MarketsListPageShimmer extends StatefulWidget {
  const MarketsListPageShimmer({super.key, this.itemCount = 8});

  final int itemCount;

  @override
  State<MarketsListPageShimmer> createState() => _MarketsListPageShimmerState();
}

class _MarketsListPageShimmerState extends State<MarketsListPageShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: kPageShimmerDuration)
      ..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = shimmerBaseColor(context);

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: widget.itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, __) {
        return ThemedShimmer(
          animation: _anim,
          child: Container(
            height: 112,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: base.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 14,
                            width: 80,
                            decoration: BoxDecoration(
                              color: base.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 10,
                            width: 120,
                            decoration: BoxDecoration(
                              color: base.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 14,
                      width: 56,
                      decoration: BoxDecoration(
                        color: base.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: base.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Form-style shimmer for payment method type pickers and similar screens.
class FormFieldsPageShimmer extends StatefulWidget {
  const FormFieldsPageShimmer({super.key, this.fieldCount = 4});

  final int fieldCount;

  @override
  State<FormFieldsPageShimmer> createState() => _FormFieldsPageShimmerState();
}

class _FormFieldsPageShimmerState extends State<FormFieldsPageShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: kPageShimmerDuration)
      ..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Widget _block(double h, {double radius = 12}) {
    return ThemedShimmer(
      animation: _anim,
      child: Container(
        height: h,
        decoration: BoxDecoration(
          color: shimmerBaseColor(context),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _block(16, radius: 6),
        const SizedBox(height: 8),
        _block(14, radius: 6),
        const SizedBox(height: 20),
        _block(12, radius: 4),
        const SizedBox(height: 10),
        ...List.generate(widget.fieldCount, (_) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _block(56, radius: 14),
          );
        }),
        const SizedBox(height: 16),
        _block(52, radius: 14),
        const SizedBox(height: 12),
        _block(52, radius: 14),
      ],
    );
  }
}

/// Splash screen shimmer with logo placeholder and subtitle lines.
class SplashPageShimmer extends StatefulWidget {
  const SplashPageShimmer({super.key});

  @override
  State<SplashPageShimmer> createState() => _SplashPageShimmerState();
}

class _SplashPageShimmerState extends State<SplashPageShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: kPageShimmerDuration)
      ..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = shimmerBaseColor(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ThemedShimmer(
              animation: _anim,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ThemedShimmer(
              animation: _anim,
              child: Container(
                width: 160,
                height: 18,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ThemedShimmer(
              animation: _anim,
              child: Container(
                width: 120,
                height: 12,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small inline shimmer pill for search fields and trailing balance labels.
class InlineShimmerPill extends StatefulWidget {
  const InlineShimmerPill({
    super.key,
    this.width = 72,
    this.height = 16,
  });

  final double width;
  final double height;

  @override
  State<InlineShimmerPill> createState() => _InlineShimmerPillState();
}

class _InlineShimmerPillState extends State<InlineShimmerPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: kPageShimmerDuration)
      ..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemedShimmer(
      animation: _anim,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: shimmerBaseColor(context),
          borderRadius: BorderRadius.circular(widget.height / 2),
        ),
      ),
    );
  }
}
