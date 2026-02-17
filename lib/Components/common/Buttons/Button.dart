import 'package:flutter/material.dart';
import 'package:voxtrade_core/Components/Loader.dart';

import '../../../assembler/common/enum.dart';

class Button extends StatelessWidget {
  final ButtonPurpose Purpose;
  final bool IsLoading;
  final String Lable;

  const Button({
    super.key,
    required this.Purpose,
    required this.IsLoading,
    required this.Lable,
  });

  @override
  Widget build(BuildContext context) {
    final Widget child = IsLoading ? Loader() : Text(Lable);
    switch (Purpose) {
      case ButtonPurpose.primary:
        return FilledButton(onPressed: () {}, child: child);
      case ButtonPurpose.secondary:
        return FilledButton(onPressed: () {}, child: child);
      case ButtonPurpose.danger:
        return FilledButton(onPressed: () {}, child: child);
      // default:
      //   return SnackBar(content: Text("This button type is not recognized"));
    }
  }
}
