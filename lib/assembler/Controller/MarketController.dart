import 'package:get/get.dart';
import 'package:voxtrade_core/Components/ModelDto/PlaceOrderRequestDTO.dart';
import 'package:voxtrade_core/Components/ModelDto/PlaceOrderResponseDTO.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/assembler/Controller/User_&_Auth/User_Controller.dart';
import 'package:voxtrade_core/assembler/Controller/Wallet_Controller.dart';
import 'package:voxtrade_core/assembler/Services/Market_Services.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';
import 'package:voxtrade_core/assembler/common/wallet_guards.dart';

class MarketController extends GetxController {
  final userController = Get.find<UserController>();
  final RxList<PlaceOrderResponseDTO> orders = RxList<PlaceOrderResponseDTO>(
    [],
  );
  RxBool isLoading = false.obs;

  Future<void> callPlaceOrder(
    int instrumentId,
    String side, // buy / sell
    String orderType, // market / limit
    double quantity,
    double? limitPrice,
    int? currencyId,
    String sourceCode,
  ) async {
    if (Get.isRegistered<WalletController>()) {
      final wallet = Get.find<WalletController>().wallet.value;
      if (!ensureWalletCanTransact(wallet)) {
        return;
      }
    }

    isLoading.value = true;
    try {
      PlaceOrderRequestDTO request = PlaceOrderRequestDTO(
        userId: userController.user.value!.id,
        instrumentId: instrumentId,
        side: side,
        orderType: orderType,
        quantity: quantity,
        limitPrice: limitPrice,
        currencyId: currencyId,
        sourceCode: sourceCode,
      );
      var data = await placeOrder(request);
      orders.value = data;
      if (data.isEmpty) {
        SnackBarComp.show(
          'Order placed successfully',
          title: 'Success',
          status: SnackBarCompStatus.success,
        );
      } else {
        if (data.first.success == false) {
          SnackBarComp.show(
            data.first.message,
            title: 'Error',
            status: SnackBarCompStatus.danger,
          );
        } else {
          SnackBarComp.show(
            data.first.message,
            title: side.toUpperCase(),
            status: SnackBarCompStatus.success,
          );
        }
      }
    } catch (e) {
      SnackBarComp.show(
        e.toString(),
        title: 'Error',
        status: SnackBarCompStatus.danger,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
