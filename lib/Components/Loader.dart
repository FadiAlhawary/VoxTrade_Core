import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final bool isCenter;
  final double? height;
  final double? width;

  const Loader({super.key, this.isCenter = false, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    final Widget indicator = SizedBox(
      height: height ?? 50,
      width: width ?? 50,
        child: CircularProgressIndicator(strokeAlign: 5, trackGap: 20 ),

    );
    return isCenter ? Center(child: indicator) : indicator;
  }
}
