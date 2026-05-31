import 'dart:async';

import 'package:get/get.dart';
import 'package:voxtrade_core/Components/ModelDto/AddFundsDtos.dart';
import 'package:voxtrade_core/Components/ModelDto/UserSearchResultDto.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/assembler/Controller/User_&_Auth/User_Controller.dart';
import 'package:voxtrade_core/Components/ModelDto/AdminDtos.dart';
import 'package:voxtrade_core/assembler/Services/Admin_Service.dart';
import 'package:voxtrade_core/assembler/Services/Wallet_Admin_Service.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';
import 'package:voxtrade_core/assembler/common/wallet_guards.dart';

class AdminWalletController extends GetxController {
  final RxList<UserSearchResultDto> searchResults = <UserSearchResultDto>[].obs;
  final Rx<UserSearchResultDto?> selectedUser = Rx<UserSearchResultDto?>(null);
  final RxBool isSearching = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString searchQuery = ''.obs;
  final RxBool targetWalletFrozen = false.obs;
  final RxBool isLoadingTargetWallet = false.obs;

  Timer? _debounce;

  void onSearchChanged(String value) {
    final selected = selectedUser.value;
    if (selected != null && value.trim() != selected.label) {
      selectedUser.value = null;
    }
    searchQuery.value = value;
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
    try {
      isSearching.value = true;
      searchResults.assignAll(await searchUsers(query));
    } catch (e) {
      SnackBarComp.show(e.toString());
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  void selectUser(UserSearchResultDto user) {
    selectedUser.value = user;
    searchResults.clear();
    searchQuery.value = user.label;
    _loadTargetWalletStatus(user.id);
  }

  void clearSelection() {
    selectedUser.value = null;
    searchQuery.value = '';
    searchResults.clear();
    targetWalletFrozen.value = false;
  }

  Future<void> _loadTargetWalletStatus(int userId) async {
    try {
      isLoadingTargetWallet.value = true;
      final wallet = await adminGetUserWallet(userId);
      targetWalletFrozen.value = wallet.isFrozen;
    } catch (_) {
      targetWalletFrozen.value = false;
    } finally {
      isLoadingTargetWallet.value = false;
    }
  }

  Future<AddFundsResponseDto?> submitAddFunds({
    required double amount,
    String? description,
  }) async {
    final target = selectedUser.value;
    if (target == null) {
      SnackBarComp.show('Select a user first');
      return null;
    }
    if (amount <= 0) {
      SnackBarComp.show('Amount must be greater than zero');
      return null;
    }

    if (targetWalletFrozen.value) {
      SnackBarComp.show(
        walletFrozenTargetMessage,
        title: 'Wallet frozen',
        status: SnackBarCompStatus.warning,
      );
      return null;
    }

    final adminId = Get.find<UserController>().user.value?.id;
    if (adminId == null) {
      SnackBarComp.show('Not logged in');
      return null;
    }

    try {
      isSubmitting.value = true;
      final response = await adminAddFunds(
        AdjustWalletRequestDto(
          adminUserId: adminId,
          targetUserId: target.id,
          amount: amount,
          description: description,
        ),
      );

      if (response.success) {
        SnackBarComp.show(
          response.message,
          title: 'Funds added',
          status: SnackBarCompStatus.success,
        );
        clearSelection();
      } else {
        SnackBarComp.show(
          response.message,
          title: 'Failed',
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
