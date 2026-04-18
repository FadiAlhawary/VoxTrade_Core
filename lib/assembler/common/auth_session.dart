import 'package:get_storage/get_storage.dart';

/// Whether a non-zero user id is stored (same rule as [UserController.initUser]).
bool readIsLoggedIn() {
  final dynamic raw = GetStorage().read('userId');
  if (raw == null) return false;
  final int? id = raw is int
      ? raw
      : raw is num
          ? raw.toInt()
          : int.tryParse('$raw');
  return id != null && id != 0;
}
