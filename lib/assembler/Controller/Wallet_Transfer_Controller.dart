import 'dart:async';

import 'package:get/get.dart';
import 'package:voxtrade_core/Components/ModelDto/TransferMoneyDtos.dart';
import 'package:voxtrade_core/Components/ModelDto/UserSearchResultDto.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/assembler/Controller/User_&_Auth/User_Controller.dart';
import 'package:voxtrade_core/assembler/Controller/Wallet_Controller.dart';
import 'package:voxtrade_core/assembler/Controller/Dashboard_Controller.dart';
import 'package:voxtrade_core/assembler/Services/Wallet_Services.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';
import 'package:voxtrade_core/assembler/common/wallet_guards.dart';

class WalletTransferController extends GetxController {
  final RxList<UserSearchResultDto> searchResults = <UserSearchResultDto>[].obs;
  final Rx<UserSearchResultDto?> selectedRecipient =
      Rx<UserSearchResultDto?>(null);
  final RxBool isSearching = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isLoadingSenderWallet = false.obs;
  final RxDouble senderAvailableBalance = 0.0.obs;
  final RxBool senderWalletFrozen = false.obs;

  Timer? _debounce;

  int? get _currentUserId => Get.find<UserController>().user.value?.id;

  UserSearchResultDto? get currentSender {
    final user = Get.find<UserController>().user.value;
    if (user == null) return null;
    final name = '${user.firstNameEn} ${user.lastNameEn}'.trim();
    return UserSearchResultDto(
      id: user.id,
      username: user.username,
      firstNameEn: user.firstNameEn,
      lastNameEn: user.lastNameEn,
      displayName: name.isNotEmpty ? name : user.username,
    );
  }

  @override
  void onInit() {
    super.onInit();
    _loadSenderWallet();
  }

  void onSearchChanged(String value) {
    final selected = selectedRecipient.value;
    if (selected != null && value.trim() != selected.label) {
      selectedRecipient.value = null;
    }

    _debounce?.cancel();
    if (value.trim().length < 2) {
      searchResults.clear();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _runSearch(value.trim());
    });
  }

  Future<void> _runSearch(String query) async {
    final senderId = _currentUserId;
    if (senderId == null) return;

    try {
      isSearching.value = true;
      final dashboard = Get.isRegistered<DashboardController>()
          ? Get.find<DashboardController>()
          : Get.put(DashboardController());
      searchResults.assignAll(
        await dashboard.searchTransferRecipients(query),
      );
    } catch (e) {
      SnackBarComp.show(e.toString());
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  void selectRecipient(UserSearchResultDto user) {
    selectedRecipient.value = user;
    searchResults.clear();
  }

  void clearRecipient() {
    selectedRecipient.value = null;
  }

  Future<void> _loadSenderWallet() async {
    final id = _currentUserId;
    if (id == null) return;

    try {
      isLoadingSenderWallet.value = true;
      final wallet = await getWallet(id, false);
      senderAvailableBalance.value = wallet.availableBalance;
      senderWalletFrozen.value = wallet.isFrozen;
    } catch (e) {
      SnackBarComp.showError(e, title: 'Wallet unavailable');
      senderAvailableBalance.value = 0;
      senderWalletFrozen.value = false;
    } finally {
      isLoadingSenderWallet.value = false;
    }
  }

  Future<TransferMoneyResponseDto?> submitTransfer({
    required double amount,
    String? description,
  }) async {
    final sender = currentSender;
    final recipient = selectedRecipient.value;

    if (sender == null) {
      SnackBarComp.show('Not logged in');
      return null;
    }
    if (recipient == null) {
      SnackBarComp.show('Select a recipient first');
      return null;
    }
    if (sender.id == recipient.id) {
      SnackBarComp.show('Cannot transfer to yourself');
      return null;
    }
    if (amount <= 0) {
      SnackBarComp.show('Amount must be greater than zero');
      return null;
    }
    if (senderWalletFrozen.value) {
      SnackBarComp.show(
        walletFrozenUserMessage,
        title: 'Wallet frozen',
        status: SnackBarCompStatus.warning,
      );
      return null;
    }
    if (amount > senderAvailableBalance.value) {
      SnackBarComp.show(
        'Insufficient available balance',
        title: 'Transfer blocked',
        status: SnackBarCompStatus.warning,
      );
      return null;
    }

    try {
      isSubmitting.value = true;
      final response = await transferMoney(
        TransferMoneyRequestDto(
          fromUserId: sender.id,
          toUserId: recipient.id,
          amount: amount,
          description: description,
        ),
      );

      if (response.success) {
        SnackBarComp.show(
          response.message,
          title: 'Transfer complete',
          status: SnackBarCompStatus.success,
        );
        if (Get.isRegistered<WalletController>()) {
          await Get.find<WalletController>().refreshWalletData();
        }
        clearRecipient();
        await _loadSenderWallet();
      } else {
        SnackBarComp.show(
          response.message,
          title: 'Transfer failed',
          status: SnackBarCompStatus.danger,
        );
      }
      return response;
    } catch (e) {
      SnackBarComp.show(e.toString());
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
