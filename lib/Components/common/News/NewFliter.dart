import 'package:flutter/material.dart';
import 'package:voxtrade_core/Components/PopUp/PopUpModal.dart';
import 'package:voxtrade_core/Components/common/Buttons/Button.dart';
import 'package:voxtrade_core/Components/common/TextField/TextBoxField.dart';
import 'package:voxtrade_core/assembler/Controller/NewsController.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';
import 'package:get/get.dart';

class Newfliter extends StatelessWidget {
  Newfliter({super.key});

  final newsController = Get.find<NewsController>();
  final TextEditingController symbolController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Button(
      purpose: ButtonPurpose.primary,
      isLoading: false,
      label: "FILTER",
      buttonWidth: 120,
      onPress: () async {
        // await newsController.fetchCompanyNews(
        //   symbol: "AAPL",
        //   from: "2025-01-01",
        //   to: "2025-12-31",
        // );
        showDialog(
          context: context,
          builder:
              (context) => PopUpModal(
                title: "Filter",
                onApply: () async {
                  await newsController.fetchCompanyNews(
                    symbol: "AAPL",
                    from: "2025-01-01",
                    to: "2025-12-31",
                  );
                },
                content: Column(
                  children: [
                    TextBoxField(
                      placeHolder: 'Symbol',
                      objectName: symbolController,
                    ),
                  ],
                ),
              ),
        );
      },
    );
  }
}
