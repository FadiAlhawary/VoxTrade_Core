import 'dart:async';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:voxtrade_core/Components/ModelDto/RegisterDTO.dart';
import 'package:voxtrade_core/Components/ModelDto/UserDTO.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/assembler/Services/Auth_User_Services.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';
import 'package:voxtrade_core/routes/route_names.dart';

class UserController extends GetxController {
  final Rx<UserDTO?> user = Rx<UserDTO?>(null);
  RxBool isLoading = false.obs;
  RxBool isLoggedIn = false.obs;

  Timer? _sessionCheckTimer;
  static const _sessionCheckInterval = Duration(seconds: 45);

  Future<void> initUser() async {
    final dynamic raw = GetStorage().read('userId');
    if (raw == null) {
      isLoggedIn.value = false;
      user.value = null;
      return;
    }
    final int? userId =
        raw is int
            ? raw
            : raw is num
            ? raw.toInt()
            : int.tryParse('$raw');
    if (userId == null || userId == 0) {
      isLoggedIn.value = false;
      user.value = null;
      return;
    }
    final dynamic stored = GetStorage().read('user');
    if (stored is Map<String, dynamic>) {
      final parsed = UserDTO.fromJson(stored);
      if (!parsed.canAccessApp) {
        await GetStorage().remove('user');
        await GetStorage().remove('userId');
        isLoggedIn.value = false;
        user.value = null;
        return;
      }
      user.value = parsed;
      isLoggedIn.value = true;
      _startSessionWatch();
    } else {
      isLoggedIn.value = false;
      user.value = null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    initUser();
  }

  @override
  void onClose() {
    _stopSessionWatch();
    super.onClose();
  }

  void _startSessionWatch() {
    _stopSessionWatch();
    if (!isLoggedIn.value) return;
    _sessionCheckTimer = Timer.periodic(
      _sessionCheckInterval,
      (_) => refreshSessionStatus(silent: true),
    );
  }

  void _stopSessionWatch() {
    _sessionCheckTimer?.cancel();
    _sessionCheckTimer = null;
  }

  /// Validates stored session on cold start before entering the app shell.
  Future<bool> verifySessionOnStartup() async {
    if (!isLoggedIn.value) return false;
    return refreshSessionStatus(silent: false);
  }

  /// Polls profile; logs out if account is locked or deleted.
  Future<bool> refreshSessionStatus({bool silent = false}) async {
    final currentId = user.value?.id;
    if (currentId == null || currentId == 0) return false;
    try {
      final profile = await getUserProfileData(currentId);
      if (!profile.canAccessApp) {
        await forceLogoutRestricted(
          profile.isLocked
              ? 'Your account has been locked. Contact support.'
              : 'Your account is no longer active.',
        );
        return false;
      }
      await setUser(profile, restartWatch: false);
      return true;
    } catch (_) {
      if (!silent) {
        // Network errors during background poll should not sign the user out.
      }
      return isLoggedIn.value;
    }
  }

  bool _applyUserIfAllowed(UserDTO next, {bool showMessage = true}) {
    if (!next.canAccessApp) {
      if (showMessage) {
        SnackBarComp.show(
          next.isLocked
              ? 'This account is locked and cannot sign in.'
              : 'This account is deactivated.',
          title: 'Access denied',
          status: SnackBarCompStatus.danger,
        );
      }
      user.value = null;
      isLoggedIn.value = false;
      return false;
    }
    user.value = next;
    isLoggedIn.value = true;
    return true;
  }

  Future<void> setUser(UserDTO user, {bool restartWatch = true}) async {
    if (!_applyUserIfAllowed(user)) {
      await GetStorage().remove('user');
      await GetStorage().remove('userId');
      return;
    }
    await GetStorage().write('user', user.toJson());
    await GetStorage().write('userId', user.id);
    if (restartWatch) _startSessionWatch();
  }

  Future<void> forceLogoutRestricted(String message) async {
    _stopSessionWatch();
    await GetStorage().remove('user');
    await GetStorage().remove('userId');
    user.value = null;
    isLoggedIn.value = false;
    SnackBarComp.show(
      message,
      title: 'Signed out',
      status: SnackBarCompStatus.warning,
    );
    if (Get.currentRoute != RouteStrings.signIn) {
      Get.offAllNamed(RouteStrings.signIn);
    }
  }

  Future<void> logoutFunction() async {
    _stopSessionWatch();
    await GetStorage().remove('user');
    await GetStorage().remove('userId');
    user.value = null;
    isLoggedIn.value = false;
    Get.offAllNamed(RouteStrings.signIn);
  }

  Future<bool> registerFunction(RegisterDTO registerDTO) async {
    try {
      isLoading.value = true;
      var data = await register(registerDTO);
      if (data.success) {
        if (data.user != null) {
          if (!data.user!.canAccessApp) {
            SnackBarComp.show(
              'Account cannot be used.',
              title: 'Error',
              status: SnackBarCompStatus.danger,
            );
            return false;
          }
          await setUser(data.user!);
        }
        SnackBarComp.show(
          data.message,
          title: "Success",
          status: SnackBarCompStatus.success,
        );
        return true;
      } else {
        SnackBarComp.show(
          data.message,
          title: "Error",
          status: SnackBarCompStatus.danger,
        );
        return false;
      }
    } catch (e) {
      SnackBarComp.showError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> loginFunction(String userName, String password) async {
    try {
      isLoading.value = true;
      var data = await login(userName, password);
      if (data.success && data.user != null) {
        if (!data.user!.canAccessApp) {
          SnackBarComp.show(
            data.user!.isLocked
                ? 'Your account is locked. Contact an administrator.'
                : 'Your account is deactivated.',
            title: 'Access denied',
            status: SnackBarCompStatus.danger,
          );
          return false;
        }
        await setUser(data.user!);
        final verified = await refreshSessionStatus(silent: true);
        if (!verified) return false;
        SnackBarComp.show(
          data.message,
          title: "Success",
          status: SnackBarCompStatus.success,
        );
        return true;
      }
      final msg = data.message.toLowerCase();
      if (msg.contains('lock')) {
        SnackBarComp.show(
          data.message,
          title: 'Account locked',
          status: SnackBarCompStatus.danger,
        );
      } else {
        SnackBarComp.show(
          data.message,
          title: "Error",
          status: SnackBarCompStatus.danger,
        );
      }
      return false;
    } catch (e) {
      SnackBarComp.showError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  bool get isAdmin => user.value?.isAdmin ?? false;

  Future<void> fetchUserProfileData() async {
    try {
      isLoading.value = true;
      final dynamic raw = GetStorage().read('userId');
      final int? userId =
          raw is int
              ? raw
              : raw is num
              ? raw.toInt()
              : int.tryParse('$raw');
      if (userId == null || userId == 0) {
        throw StateError('Not logged in');
      }
      var data = await getUserProfileData(userId);
      if (!data.canAccessApp) {
        await forceLogoutRestricted(
          data.isLocked
              ? 'Your account has been locked. Contact support.'
              : 'Your account is no longer active.',
        );
        return;
      }
      await setUser(data, restartWatch: false);
    } catch (e) {
      SnackBarComp.showError(e);
    } finally {
      isLoading.value = false;
    }
  }
}
