import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/common/Buttons/Button.dart';
import 'package:voxtrade_core/Components/common/TextField/TextBoxField.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/assembler/Controller/ThemeController.dart';
import 'package:voxtrade_core/assembler/Controller/User_&_Auth/User_Controller.dart';
import 'package:voxtrade_core/routes/route_names.dart';
import 'package:voxtrade_core/utils/auth_credentials_validation.dart';

import '../assembler/common/enum.dart';

/// Invisible placeholder — [TextBoxField] requires a non-null [sufixIcon] when the field is not sensitive.
const Icon _kTextBoxEmptySuffix = Icon(
  Icons.circle,
  size: 0,
  color: Colors.transparent,
);

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ThemeController _themeController = Get.find<ThemeController>();
  bool _isLoading = false;
  bool _isButtonPressed = false;
  RxString _userNameErrorMessage = ''.obs;
  RxString _passwordErrorMessage = ''.obs;

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    _userNameErrorMessage.value = '';
    _passwordErrorMessage.value = '';

    final String userName = _userNameController.text.trim();
    final String password = _passwordController.text;

    final String? userNameError = validateAuthUsername(userName);
    if (userNameError != null) {
      _userNameErrorMessage.value = userNameError;
      SnackBarComp.show(
        userNameError,
        title: 'Validation Error',
        status: SnackBarCompStatus.warning,
      );
      return;
    }

    final String? passwordError = validateLoginPassword(password);
    if (passwordError != null) {
      _passwordErrorMessage.value = passwordError;
      SnackBarComp.show(
        passwordError,
        title: 'Validation Error',
        status: SnackBarCompStatus.warning,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final userController = Get.find<UserController>();
    final ok = await userController.loginFunction(userName, password);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (ok) {
      Get.offAllNamed(RouteStrings.root);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _ = _themeController.isDarkMode.value;
      final Color primary = Theme.of(context).colorScheme.primary;
      final Color scaffoldBg = const Color(0xFF0D0F14);
      final Color textColor = Colors.white;
      final Color subTextColor = Colors.white.withValues(alpha: 0.65);
      final Color hintColor = Colors.grey.shade500;

      return Scaffold(
        backgroundColor: scaffoldBg,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0B1220), Color(0xFF0F1B2E)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -120,
                      right: -70,
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primary.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -140,
                      left: -80,
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primary.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 350),
                      tween: Tween<double>(begin: 0, end: 1),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 14 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(18, 48, 18, 24),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight - 72),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 460),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Welcome back',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: textColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'Sign in to continue to your trading dashboard.',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(color: subTextColor),
                                  ),
                                  const SizedBox(height: 26),
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      inputDecorationTheme: InputDecorationTheme(
                                        filled: true,
                                        fillColor: const Color(0xFF162235),
                                        hintStyle: TextStyle(color: hintColor),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: Colors.white.withValues(alpha: 0.08),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(color: primary),
                                        ),
                                      ),
                                      iconTheme: IconThemeData(
                                        color: Colors.white.withValues(alpha: 0.82),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Obx(() {
                                          return TextBoxField(
                                            placeHolder: 'Username',
                                            objectName: _userNameController,
                                            preFixIcon: const Icon(Icons.person_outline_rounded),
                                            sufixIcon: _kTextBoxEmptySuffix,
                                            errorText:
                                                _userNameErrorMessage.value.isNotEmpty
                                                    ? _userNameErrorMessage.value
                                                    : null,
                                          );
                                        }),
                                        const SizedBox(height: 16),
                                        Obx(() {
                                          return TextBoxField(
                                            placeHolder: 'Password',
                                            objectName: _passwordController,
                                            isisSenstive: true,
                                            preFixIcon: const Icon(Icons.lock_outline_rounded),
                                            errorText:
                                                _passwordErrorMessage.value.isNotEmpty
                                                    ? _passwordErrorMessage.value
                                                    : null,
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  GestureDetector(
                                    onTapDown: (_) => setState(() => _isButtonPressed = true),
                                    onTapCancel: () => setState(() => _isButtonPressed = false),
                                    onTapUp: (_) => setState(() => _isButtonPressed = false),
                                    child: AnimatedScale(
                                      scale: _isButtonPressed ? 0.98 : 1.0,
                                      duration: const Duration(milliseconds: 120),
                                      curve: Curves.easeOut,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: primary.withValues(alpha: 0.18),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: Button(
                                            purpose: ButtonPurpose.primary,
                                            isLoading: _isLoading,
                                            label: 'Log In',
                                            onPress: _onLogin,
                                            backGroundColor: primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Don't have an account? ",
                                        style: TextStyle(
                                          color: subTextColor,
                                          fontSize: 13,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => Get.offNamed(RouteStrings.signUp),
                                        child: Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            color: primary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    });
  }
}
