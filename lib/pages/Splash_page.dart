import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/assembler/common/auth_session.dart';
import 'package:voxtrade_core/routes/route_names.dart';

/// Cold start: sends user to shell or sign-in based on stored session.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _routeFromSession());
  }

  Future<void> _routeFromSession() async {
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    if (readIsLoggedIn()) {
      Get.offAllNamed(RouteStrings.root);
    } else {
      Get.offAllNamed(RouteStrings.signIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
