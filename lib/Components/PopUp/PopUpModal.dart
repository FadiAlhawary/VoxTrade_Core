import 'package:flutter/material.dart';
import 'package:voxtrade_core/Components/common/Buttons/Button.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';

class PopUpModal extends StatelessWidget {
  final String title;
  final Widget content;
  final double height;
  final bool centerTitle;
  final Future<void> Function() onApply;
  const PopUpModal({
    super.key,
    required this.title,
    required this.content,
    this.height = 200,
    this.centerTitle = false,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: centerTitle ? Center(child: Text(title)) : Text(title),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
      content: SizedBox(height: height, child: content),

      actions: [
        Button(
          purpose: ButtonPurpose.secondary,
          isLoading: false,
          buttonWidth: 20,
          buttonHeight: 10,
          label: "Close",
          onPress: () async {
            Navigator.of(context).pop();
          },
        ),
        Button(
          purpose: ButtonPurpose.primary,
          isLoading: false,
          label: "Apply",
          buttonWidth: 20,
          buttonHeight: 10,
          onPress: () async {
            await onApply();
          },
        ),
      ],
    );
  }
}
