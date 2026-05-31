import 'package:flutter/material.dart';

class ResponsiveBreakpoints {
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double largeDesktop = 1440;
  static const double maxContentWidth = 1280;
  static const double tallScreenHeight = 800;
}

class ResponsiveInfo {
  const ResponsiveInfo({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  bool get isTablet => width >= ResponsiveBreakpoints.tablet;
  bool get isDesktop => width >= ResponsiveBreakpoints.desktop;
  bool get isLargeDesktop => width >= ResponsiveBreakpoints.largeDesktop;
  bool get isTallScreen => height >= ResponsiveBreakpoints.tallScreenHeight;

  double get horizontalPadding {
    if (isLargeDesktop) return 32;
    if (isDesktop) return 24;
    if (isTablet) return 16;
    return 0;
  }
}

ResponsiveInfo responsiveInfoOf(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  return ResponsiveInfo(width: size.width, height: size.height);
}

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final info = ResponsiveInfo(
          width: constraints.maxWidth,
          height: MediaQuery.sizeOf(context).height,
        );
        final maxWidth =
            info.isDesktop
                ? ResponsiveBreakpoints.maxContentWidth
                : constraints.maxWidth;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: info.horizontalPadding),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
