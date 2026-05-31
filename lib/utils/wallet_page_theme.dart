import 'package:flutter/material.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';

class WalletPagePalette {
  const WalletPagePalette({
    required this.pageBackground,
    required this.cardBackground,
    required this.inputFill,
    required this.primaryText,
    required this.mutedText,
    required this.border,
    required this.accent,
    required this.heroGradient,
    required this.ctaGradient,
  });

  final Color pageBackground;
  final Color cardBackground;
  final Color inputFill;
  final Color primaryText;
  final Color mutedText;
  final Color border;
  final Color accent;
  final List<Color> heroGradient;
  final List<Color> ctaGradient;

  static WalletPagePalette of(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = scheme.primary;
    final primaryDark = Color.lerp(primary, Colors.black, 0.22)!;
    final primaryLight = Color.lerp(primary, Colors.white, 0.18)!;

    if (isDark) {
      return WalletPagePalette(
        pageBackground: const Color(0xFF060B14),
        cardBackground: const Color(0xFF101827),
        inputFill: const Color(0xFF141F30),
        primaryText: scheme.onSurface,
        mutedText: scheme.onSurfaceVariant,
        border: scheme.outlineVariant.withValues(alpha: 0.45),
        accent: primaryLight,
        heroGradient: [
          Color.lerp(primaryDark, const Color(0xFF060B14), 0.35)!,
          primaryDark,
          primary,
        ],
        ctaGradient: [primaryLight, primary],
      );
    }

    return WalletPagePalette(
      pageBackground: const Color(0xFFF4F8FC),
      cardBackground: Colors.white,
      inputFill: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
      primaryText: scheme.onSurface,
      mutedText: scheme.onSurfaceVariant,
      border: scheme.outlineVariant.withValues(alpha: 0.55),
      accent: primaryColor,
      heroGradient: [primaryDark, primary, primaryLight],
      ctaGradient: [primary, Color.lerp(primary, const Color(0xFF0EA5E9), 0.45)!],
    );
  }
}

class WalletGradientButton extends StatelessWidget {
  const WalletGradientButton({
    super.key,
    required this.palette,
    required this.icon,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.loading = false,
    this.height = 54,
    this.radius = 30,
  });

  final WalletPagePalette palette;
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool loading;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final canTap = enabled && !loading && onPressed != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canTap ? onPressed : null,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  canTap
                      ? palette.ctaGradient
                      : [Colors.grey.shade500, Colors.grey.shade600],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(radius),
            boxShadow:
                canTap
                    ? [
                      BoxShadow(
                        color: palette.accent.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WalletOutlineButton extends StatelessWidget {
  const WalletOutlineButton({
    super.key,
    required this.palette,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.height = 48,
    this.radius = 30,
  });

  final WalletPagePalette palette;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: palette.cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(
          color: scheme.primary.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: scheme.primary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WalletSurfaceCard extends StatelessWidget {
  const WalletSurfaceCard({
    super.key,
    required this.palette,
    required this.child,
    this.radius = 20,
    this.padding,
  });

  final WalletPagePalette palette;
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.cardBackground,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
        ],
      ),
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );
  }
}
