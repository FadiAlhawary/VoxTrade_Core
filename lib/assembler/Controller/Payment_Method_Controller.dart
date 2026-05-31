import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/ModelDto/PaymentMethodDtos.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/assembler/Controller/User_&_Auth/User_Controller.dart';
import 'package:voxtrade_core/assembler/Controller/Wallet_Controller.dart';
import 'package:voxtrade_core/assembler/Services/Payment_Method_Service.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';
import 'package:voxtrade_core/pages/Add_Payment_Method_Page.dart';
import 'package:voxtrade_core/pages/Payment_Methods_Page.dart';

class PaymentMethodController extends GetxController {
  final RxList<PaymentMethodTypeDto> paymentMethodTypes =
      <PaymentMethodTypeDto>[].obs;
  final RxList<UserPaymentMethodDto> userPaymentMethods =
      <UserPaymentMethodDto>[].obs;
  final RxBool isLoadingTypes = false.obs;
  final RxBool isLoadingMethods = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxInt deletingMethodId = 0.obs;

  int get _userId => Get.find<UserController>().user.value?.id ?? 0;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> fetchPaymentMethodTypes({bool force = false}) async {
    if (!force && paymentMethodTypes.isNotEmpty) return;

    try {
      isLoadingTypes.value = true;
      final types = await getPaymentMethodTypes();
      paymentMethodTypes.assignAll(types.where((t) => t.isActive));
    } catch (e) {
      SnackBarComp.showError(e, title: 'Payment types unavailable');
    } finally {
      isLoadingTypes.value = false;
    }
  }

  Future<void> fetchUserPaymentMethods() async {
    final id = _userId;
    if (id == 0) return;

    try {
      isLoadingMethods.value = true;
      userPaymentMethods.assignAll(await getUserPaymentMethods(id));
    } catch (e) {
      SnackBarComp.showError(e, title: 'Payment methods unavailable');
    } finally {
      isLoadingMethods.value = false;
    }
  }

  Future<bool> addPaymentMethod({
    required int paymentMethodId,
    required String attributeValue1,
    String? attributeValue2,
  }) async {
    final id = _userId;
    if (id == 0) {
      SnackBarComp.show('Not logged in');
      return false;
    }

    final primary = attributeValue1.trim();
    if (primary.isEmpty) {
      SnackBarComp.show('Primary detail is required');
      return false;
    }

    try {
      isSubmitting.value = true;
      final response = await addUserPaymentMethod(
        id,
        AddPaymentMethodRequestDto(
          paymentMethodId: paymentMethodId,
          attributeValue1: primary,
          attributeValue2: attributeValue2,
        ),
      );

      if (response.success) {
        SnackBarComp.show(
          response.message,
          title: 'Payment method added',
          status: SnackBarCompStatus.success,
        );
        await fetchUserPaymentMethods();
        if (Get.isRegistered<WalletController>()) {
          await Get.find<WalletController>().refreshWalletData();
        }
        return true;
      }

      SnackBarComp.show(
        response.message,
        title: 'Could not add method',
        status: SnackBarCompStatus.danger,
      );
      return false;
    } catch (e) {
      SnackBarComp.showError(e, title: 'Could not add method');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> confirmAndRemovePaymentMethod(UserPaymentMethodDto method) async {
    final context = Get.context;
    if (context == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Remove payment method?'),
            content: Text(
              'Remove ${method.methodName} · ${method.displayLabel}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                ),
                child: const Text('Remove'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await removePaymentMethod(method.id);
    }
  }

  Future<void> removePaymentMethod(int userPaymentMethodId) async {
    final id = _userId;
    if (id == 0) return;

    try {
      deletingMethodId.value = userPaymentMethodId;
      await deleteUserPaymentMethod(id, userPaymentMethodId);
      userPaymentMethods.removeWhere((m) => m.id == userPaymentMethodId);
      SnackBarComp.show(
        'Payment method removed.',
        title: 'Removed',
        status: SnackBarCompStatus.success,
      );
    } catch (e) {
      SnackBarComp.showError(e, title: 'Could not remove method');
    } finally {
      deletingMethodId.value = 0;
    }
  }

  void openPaymentMethodsPage() {
    Get.to(() => const PaymentMethodsPage());
  }

  void openAddPaymentMethodPage() {
    Get.to(() => const AddPaymentMethodPage());
  }

  IconData iconForMethodType(String methodType) {
    switch (methodType.toLowerCase()) {
      case 'card':
        return Icons.credit_card_rounded;
      case 'bank':
      case 'bank_account':
        return Icons.account_balance_rounded;
      case 'paypal':
        return Icons.payments_rounded;
      case 'crypto':
        return Icons.currency_bitcoin_rounded;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }
}
