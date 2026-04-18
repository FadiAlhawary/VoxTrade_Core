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
      user.value = UserDTO.fromJson(stored);
      isLoggedIn.value = true;
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

  Future<void> setUser(UserDTO user) async {
    this.user.value = user;
    isLoggedIn.value = true;
    await GetStorage().write('user', user.toJson());
    await GetStorage().write('userId', user.id);
  }

  Future<void> logoutFunction() async {
    await GetStorage().remove('user');
    await GetStorage().remove('userId');
    user.value = null;
    isLoggedIn.value = false;
    Get.offAllNamed(RouteStrings.signIn);
  }

  Future<void> registerFunction(RegisterDTO registerDTO) async {
    try {
      isLoading.value = true;
      var data = await register(registerDTO);
      if (data.success) {
        SnackBarComp.show(
          data.message,
          title: "Success",
          status: SnackBarCompStatus.success,
        );
      } else {
        SnackBarComp.show(
          data.message,
          title: "Error",
          status: SnackBarCompStatus.danger,
        );
      }
    } catch (e) {
      SnackBarComp.show(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> loginFunction(String userName, String password) async {
    try {
      isLoading.value = true;
      var data = await login(userName, password);
      if (data.success && data.user != null) {
        await setUser(data.user!);
        SnackBarComp.show(
          data.message,
          title: "Success",
          status: SnackBarCompStatus.success,
        );
        return true;
      }
      SnackBarComp.show(
        data.message,
        title: "Error",
        status: SnackBarCompStatus.danger,
      );
      return false;
    } catch (e) {
      SnackBarComp.show(e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

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
      await setUser(data);
    } catch (e) {
      SnackBarComp.show(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
