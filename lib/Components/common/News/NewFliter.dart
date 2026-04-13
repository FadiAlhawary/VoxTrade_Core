import 'package:flutter/material.dart';
import 'package:voxtrade_core/Components/DateFields/DatePicker.dart';
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
  String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }



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
                height: 280,
                onApply: () async {
                  print(newsController.selectedSymbol.value);
                  print(newsController.selectedFromDate.value);
                  print(newsController.selectedToDate.value);
                  await newsController.fetchCompanyNews();
                },
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextBoxField(
                        placeHolder: 'Symbol',
                        objectName: symbolController,
                        rxObjectName: newsController.selectedSymbol,
                      ),
                      const SizedBox(height: 12),
                      DatePickerField(
                        label: "From date",
                        initialDate: DateTime.parse(
                          newsController.selectedFromDate.value,
                        ),
                        firstDate: DateTime(2000),
                        // DateTime(2026) is 1 Jan 2026 — after that, "now" is invalid as initialDate.
                        lastDate: DateTime(2100),
                        onDateSelected: (date) {
                          newsController.selectedFromDate.value = formatDate(
                            date,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      DatePickerField(
                        label: "To date",
                        initialDate: DateTime.parse(
                          newsController.selectedToDate.value,
                        ),
                        firstDate: DateTime(2000),
                        // DateTime(2026) is 1 Jan 2026 — after that, "now" is invalid as initialDate.
                        lastDate: DateTime(2100),
                        onDateSelected: (date) {
                          newsController.selectedToDate.value = formatDate(
                            date,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
        );
      },
    );
  }
}
