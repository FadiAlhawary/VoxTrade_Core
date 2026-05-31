import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/utils/http_error_message.dart';

import '../../assembler/common/enum.dart';

class SnackBarComp {
  static void show(
    String message, {
    String title = 'Notice',
    SnackBarCompStatus? status = SnackBarCompStatus.success,
  }) {
    final trimmed = message.trim();
    final displayMessage =
        trimmed.length > 220 ? '${trimmed.substring(0, 217)}…' : trimmed;

    final context = Get.context;
    final isDark =
        context != null
            ? Theme.of(context).brightness == Brightness.dark
            : false;

    GetSnackBar(
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: EdgeInsets.zero,
      borderRadius: 18,
      backgroundColor: Colors.transparent,
      barBlur: 0,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      maxWidth: 420,
      duration: const Duration(seconds: 4),
      animationDuration: const Duration(milliseconds: 450),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      messageText: GlassNotificationBanner(
        title: title,
        message: displayMessage,
        status: status,
        isDark: isDark,
      ),
    ).show();
  }

  static void showError(
    Object error, {
    String title = 'Error',
  }) {
    show(
      friendlyErrorMessage(error),
      title: title,
      status: SnackBarCompStatus.danger,
    );
  }
}

/// Frosted-glass toast that blurs the page content behind it.
class GlassNotificationBanner extends StatelessWidget {
  const GlassNotificationBanner({
    super.key,
    required this.title,
    required this.message,
    required this.status,
    required this.isDark,
  });

  final String title;
  final String message;
  final SnackBarCompStatus? status;
  final bool isDark;

  static const double _blurSigma = 22;

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(status);
    final isError = status == SnackBarCompStatus.danger;
    final palette = _GlassPalette.of(isDark: isDark, accent: accent, isError: isError);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.fill,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: palette.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: palette.shadow,
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 16, 13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusIcon(accent: accent, status: status),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: palette.title,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          letterSpacing: -0.2,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        message,
                        style: TextStyle(
                          color: palette.message,
                          fontSize: 13.5,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color _accentColor(SnackBarCompStatus? status) {
    switch (status) {
      case SnackBarCompStatus.success:
        return const Color(0xFF16A34A);
      case SnackBarCompStatus.info:
        return const Color(0xFF4988C4);
      case SnackBarCompStatus.warning:
        return const Color(0xFFF59E0B);
      case SnackBarCompStatus.danger:
        return const Color(0xFFE2525C);
      default:
        return const Color(0xFF16A34A);
    }
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.accent, required this.status});

  final Color accent;
  final SnackBarCompStatus? status;

  @override
  Widget build(BuildContext context) {
    final icon = switch (status) {
      SnackBarCompStatus.success => Icons.check_circle_rounded,
      SnackBarCompStatus.warning => Icons.warning_amber_rounded,
      SnackBarCompStatus.danger => Icons.error_rounded,
      SnackBarCompStatus.info => Icons.info_outline_rounded,
      _ => Icons.notifications_none_rounded,
    };

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Icon(icon, color: accent, size: 19),
    );
  }
}

class _GlassPalette {
  const _GlassPalette({
    required this.fill,
    required this.border,
    required this.title,
    required this.message,
    required this.shadow,
  });

  final Color fill;
  final Color border;
  final Color title;
  final Color message;
  final Color shadow;

  factory _GlassPalette.of({
    required bool isDark,
    required Color accent,
    required bool isError,
  }) {
    if (isError) {
      return _GlassPalette(
        fill:
            isDark
                ? const Color(0xFF2A1215).withValues(alpha: 0.55)
                : const Color(0xFFFFFBFB).withValues(alpha: 0.62),
        border: accent.withValues(alpha: isDark ? 0.42 : 0.38),
        title: isDark ? Colors.white : const Color(0xFF7F1D1D),
        message:
            isDark
                ? Colors.white.withValues(alpha: 0.82)
                : const Color(0xFF991B1B).withValues(alpha: 0.88),
        shadow: accent.withValues(alpha: isDark ? 0.22 : 0.14),
      );
    }

    return _GlassPalette(
      fill:
          isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.white.withValues(alpha: 0.58),
      border:
          isDark
              ? Colors.white.withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.72),
      title: isDark ? Colors.white : const Color(0xFF111827),
      message:
          isDark
              ? Colors.white.withValues(alpha: 0.78)
              : const Color(0xFF374151),
      shadow:
          isDark
              ? Colors.black.withValues(alpha: 0.28)
              : Colors.black.withValues(alpha: 0.08),
    );
  }
}
