import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../assembler/common/enum.dart';

class SnackBarComp {
  static void show(
    String message, {
    String title = "Notice",
    SnackBarCompStatus? status = SnackBarCompStatus.success,
  }) {
    Color color = Colors.green;
    switch (status) {
      case SnackBarCompStatus.success:
        color = Colors.green;
        break;
      case SnackBarCompStatus.info:
        color = Colors.blue;
        break;
      case SnackBarCompStatus.warning:
        color = Colors.orange;
        break;
      case SnackBarCompStatus.danger:
        color = Colors.red;
        break;
      default:
        color = Colors.green;
    }
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.all(10),
      borderRadius: 8,
      backgroundColor: color,
      colorText: Colors.white,
    );
  }
}
