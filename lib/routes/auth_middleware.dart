import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:voxtrade_core/Components/ModelDto/UserDTO.dart';
import 'package:voxtrade_core/assembler/common/auth_session.dart';
import 'package:voxtrade_core/routes/route_names.dart';

/// Sends unauthenticated or restricted users to sign-in before shell routes open.
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!readIsLoggedIn()) {
      return const RouteSettings(name: RouteStrings.signIn);
    }
    final stored = GetStorage().read('user');
    if (stored is Map<String, dynamic>) {
      final parsed = UserDTO.fromJson(stored);
      if (!parsed.canAccessApp) {
        return const RouteSettings(name: RouteStrings.signIn);
      }
    }
    return null;
  }
}
