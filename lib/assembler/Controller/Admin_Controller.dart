import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/ModelDto/AdminDtos.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/assembler/Controller/User_&_Auth/User_Controller.dart';
import 'package:voxtrade_core/assembler/Services/Admin_Service.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';

class AdminController extends GetxController {
  final Rx<AdminDashboardDto?> dashboard = Rx<AdminDashboardDto?>(null);
  final RxList<AdminUserDto> users = <AdminUserDto>[].obs;
  final RxList<AdminWalletDto> wallets = <AdminWalletDto>[].obs;
  final RxList<AdminOrderDto> orders = <AdminOrderDto>[].obs;
  final RxList<AdminTradeDto> trades = <AdminTradeDto>[].obs;
  final RxList<AdminInstrumentDto> instruments = <AdminInstrumentDto>[].obs;
  final RxList<AdminRoleDto> roles = <AdminRoleDto>[].obs;
  final RxList<AdminCurrencyDto> currencies = <AdminCurrencyDto>[].obs;
  final RxList<AdminAuditLogDto> auditLogs = <AdminAuditLogDto>[].obs;

  final RxBool isLoadingDashboard = false.obs;
  final RxBool isLoadingUsers = false.obs;
  final RxBool isLoadingWallets = false.obs;
  final RxBool isLoadingOrders = false.obs;
  final RxBool isLoadingTrades = false.obs;
  final RxBool isLoadingInstruments = false.obs;
  final RxBool isLoadingAudit = false.obs;
  final RxBool isMutating = false.obs;

  int? get _adminUserId => Get.find<UserController>().user.value?.id;

  Future<void> loadDashboard() async {
    try {
      isLoadingDashboard.value = true;
      final results = await Future.wait([
        adminGetDashboard(),
        adminGetTrades(),
        adminGetAuditLogs(),
      ]);
      dashboard.value = results[0] as AdminDashboardDto;
      trades.assignAll(results[1] as List<AdminTradeDto>);
      auditLogs.assignAll(results[2] as List<AdminAuditLogDto>);
    } catch (e) {
      SnackBarComp.show(e.toString());
    } finally {
      isLoadingDashboard.value = false;
    }
  }

  Future<void> loadUsers() async {
    try {
      isLoadingUsers.value = true;
      users.assignAll(await adminGetUsers());
    } catch (e) {
      SnackBarComp.show(e.toString());
    } finally {
      isLoadingUsers.value = false;
    }
  }

  Future<void> loadWallets() async {
    try {
      isLoadingWallets.value = true;
      wallets.assignAll(await adminGetWallets());
    } catch (e) {
      SnackBarComp.show(e.toString());
    } finally {
      isLoadingWallets.value = false;
    }
  }

  Future<void> loadOrders() async {
    try {
      isLoadingOrders.value = true;
      orders.assignAll(await adminGetOrders());
    } catch (e) {
      SnackBarComp.show(e.toString());
    } finally {
      isLoadingOrders.value = false;
    }
  }

  Future<void> loadTrades() async {
    try {
      isLoadingTrades.value = true;
      trades.assignAll(await adminGetTrades());
    } catch (e) {
      SnackBarComp.show(e.toString());
    } finally {
      isLoadingTrades.value = false;
    }
  }

  Future<void> loadInstruments() async {
    try {
      isLoadingInstruments.value = true;
      instruments.assignAll(await adminGetInstruments());
    } catch (e) {
      SnackBarComp.show(e.toString());
    } finally {
      isLoadingInstruments.value = false;
    }
  }

  Future<void> loadAuditLogs() async {
    try {
      isLoadingAudit.value = true;
      auditLogs.assignAll(await adminGetAuditLogs());
    } catch (e) {
      SnackBarComp.show(e.toString());
    } finally {
      isLoadingAudit.value = false;
    }
  }

  Future<bool> _runMutation(
    Future<AdminActionResponseDto> Function() call, {
    String successTitle = 'Done',
    VoidCallback? onSuccess,
  }) async {
    final adminId = _adminUserId;
    if (adminId == null) {
      SnackBarComp.show('Not logged in');
      return false;
    }
    try {
      isMutating.value = true;
      final response = await call();
      if (response.success) {
        SnackBarComp.show(
          response.message,
          title: successTitle,
          status: SnackBarCompStatus.success,
        );
        onSuccess?.call();
        return true;
      }
      SnackBarComp.show(
        response.message,
        title: 'Failed',
        status: SnackBarCompStatus.danger,
      );
      return false;
    } catch (e) {
      SnackBarComp.show(e.toString());
      return false;
    } finally {
      isMutating.value = false;
    }
  }

  Future<bool> lockUser(int targetUserId, {String? reason}) {
    final adminId = _adminUserId!;
    return _runMutation(
      () => adminLockUser(targetUserId, adminId, reason: reason),
      successTitle: 'User locked',
      onSuccess: loadUsers,
    );
  }

  Future<bool> unlockUser(int targetUserId) {
    final adminId = _adminUserId!;
    return _runMutation(
      () => adminUnlockUser(targetUserId, adminId),
      successTitle: 'User unlocked',
      onSuccess: loadUsers,
    );
  }

  Future<bool> restoreUser(int targetUserId) {
    final adminId = _adminUserId!;
    return _runMutation(
      () => adminRestoreUser(targetUserId, adminId),
      successTitle: 'User restored',
      onSuccess: loadUsers,
    );
  }

  Future<bool> freezeWallet(int targetUserId, {String? reason}) {
    final adminId = _adminUserId!;
    return _runMutation(
      () => adminFreezeWallet(targetUserId, adminId, reason: reason),
      successTitle: 'Wallet frozen',
      onSuccess: loadWallets,
    );
  }

  Future<bool> unfreezeWallet(int targetUserId) {
    final adminId = _adminUserId!;
    return _runMutation(
      () => adminUnfreezeWallet(targetUserId, adminId),
      successTitle: 'Wallet unfrozen',
      onSuccess: loadWallets,
    );
  }

  Future<bool> cancelOrder(int orderId) {
    final adminId = _adminUserId!;
    return _runMutation(
      () => adminCancelOrder(orderId, adminId),
      successTitle: 'Order cancelled',
      onSuccess: loadOrders,
    );
  }

  Future<bool> deactivateInstrument(int instrumentId) {
    final adminId = _adminUserId!;
    return _runMutation(
      () => adminDeactivateInstrument(instrumentId, adminId),
      successTitle: 'Instrument deactivated',
      onSuccess: loadInstruments,
    );
  }

  Future<bool> restoreInstrument(int instrumentId) {
    return _runMutation(
      () => adminRestoreInstrument(instrumentId),
      successTitle: 'Instrument restored',
      onSuccess: loadInstruments,
    );
  }
}
