import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Your voxtrade_core imports
import 'package:voxtrade_core/Components/common/Buttons/Button.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';
// Note: Adjust this import if your TextBoxField is in a different folder
import 'package:voxtrade_core/Components/common/TextField/TextBoxField.dart';

class TradeController extends GetxController {
  final assetController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();

  var isSubmitting = false.obs;
  var availableBalance = 14250.75.obs; // Dummy balance to make the UI feel alive

  Future<void> executeTrade(String action) async {
    // Basic validation
    if (assetController.text.isEmpty || quantityController.text.isEmpty) {
      SnackBarComp.show(
        "Please enter an asset and quantity",
        title: "Missing Details",
        status: SnackBarCompStatus.warning,
      );
      return;
    }

    isSubmitting.value = true;

    // Simulate network delay to your .NET backend
    await Future.delayed(const Duration(seconds: 1));

    isSubmitting.value = false;

    SnackBarComp.show(
      "$action order placed for ${quantityController.text} ${assetController.text.toUpperCase()}",
      title: "Trade Executed",
      status: SnackBarCompStatus.success,
    );

    // Clear the form after a successful trade
    assetController.clear();
    quantityController.clear();
    priceController.clear();
  }

  @override
  void onClose() {
    assetController.dispose();
    quantityController.dispose();
    priceController.dispose();
    super.onClose();
  }
}

class TradePage extends StatelessWidget {
  TradePage({super.key});

  final TradeController controller = Get.put(TradeController());

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Manual Trade'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Available Balance Display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available Balance',
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                      Obx(() => Text(
                        '\$${controller.availableBalance.value.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  "Order Details",
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Asset Symbol Input
                TextBoxField(
                  placeHolder: 'Asset Symbol (e.g., BTC, AAPL)',
                  objectName: controller.assetController,
                  preFixIcon: Icon(
                    Icons.search,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 20),

                // Quantity Input
                TextBoxField(
                  placeHolder: 'Quantity',
                  objectName: controller.quantityController,
                  preFixIcon: Icon(
                    Icons.format_list_numbered,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 20),

                // Price Input
                TextBoxField(
                  placeHolder: 'Limit Price (Optional)',
                  objectName: controller.priceController,
                  preFixIcon: Icon(
                    Icons.attach_money,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 40),

                // Buy / Sell Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => Button(
                        purpose: ButtonPurpose.primary,
                        isLoading: controller.isSubmitting.value,
                        label: 'BUY',
                        buttonHeight: 55,
                        backGroundColor: const Color(0xFF2E7D32), // Standard Market Green
                        onPress: () => controller.executeTrade('BUY'),
                      )),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Obx(() => Button(
                        purpose: ButtonPurpose.danger,
                        isLoading: controller.isSubmitting.value,
                        label: 'SELL',
                        buttonHeight: 55,
                        onPress: () => controller.executeTrade('SELL'),
                      )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}