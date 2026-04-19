import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/Loader.dart';
import 'package:voxtrade_core/assembler/Controller/ThemeController.dart';

import '../../../assembler/common/enum.dart';

class Button extends StatelessWidget {
  final ButtonPurpose purpose;
  final bool isLoading;
  final String label;
  final Future<void> Function() onPress;
  final double buttonWidth;
  final double buttonHeight;
  final Color backGroundColor;

  const Button({
    super.key,
    required this.purpose,
    required this.isLoading,
    required this.label,
    required this.onPress,
    this.buttonWidth = 35,
    this.buttonHeight = 15,
    this.backGroundColor = const Color(0xFF4988C4),
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDarkMode = themeController.isDarkMode.value;
    final Color backgroundColor = isDarkMode ? Colors.white : Colors.black;
    final Color foregroundColor = isDarkMode ? Colors.black : Colors.white;
    final Widget child =
        isLoading
            ? Loader(width: buttonWidth, height: buttonHeight, isCenter: false)
            : Text(label);
    switch (purpose) {
      case ButtonPurpose.primary:
        return FilledButton(
          onPressed: isLoading ? null : onPress,
          child: child,
          style: FilledButton.styleFrom(
            minimumSize: Size(buttonWidth, buttonHeight),
            backgroundColor: backGroundColor,
            foregroundColor: foregroundColor,
            padding: EdgeInsets.symmetric(
              horizontal: buttonWidth - 10,
              vertical: buttonHeight,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        );

      case ButtonPurpose.secondary:
        return OutlinedButton(
          onPressed: isLoading ? null : onPress,
          child: child,
          style: OutlinedButton.styleFrom(
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            minimumSize: Size(buttonWidth, buttonHeight),
            padding: EdgeInsets.symmetric(
              horizontal: buttonWidth - 10,
              vertical: buttonHeight,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        );

      case ButtonPurpose.danger:
        return FilledButton(
          onPressed: isLoading ? null : onPress,
          child: child,
          style: FilledButton.styleFrom(
            minimumSize: Size(buttonWidth, buttonHeight),
            backgroundColor:
                backGroundColor == const Color(0xFF4988C4)
                    ? Colors.red
                    : backGroundColor,
            foregroundColor: foregroundColor,
            padding: EdgeInsets.symmetric(
              horizontal: buttonWidth - 10,
              vertical: buttonHeight,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        );

      // default:
      //   return SnackBar(content: Text("This button type is not recognized"));
    }
  }
}
