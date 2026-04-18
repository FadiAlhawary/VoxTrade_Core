import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/assembler/common/auth_session.dart';
import 'package:voxtrade_core/routes/route_names.dart';

/// Sends unauthenticated users to sign-in before shell routes open.
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!readIsLoggedIn()) {
      return const RouteSettings(name: RouteStrings.signIn);
    }
    return null;
  }
}
