import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/common/Buttons/Button.dart';
import 'package:voxtrade_core/Components/common/TextField/TextBoxField.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
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
  bool _isLoading = false;
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
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.candlestick_chart_rounded, size: 62),
                  const SizedBox(height: 14),
                  Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue trading with VoxTrade.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
                  ),
                  const SizedBox(height: 28),
                  Obx(() {
                    return TextBoxField(
                      placeHolder: 'UserName',
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
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: Button(
                      purpose: ButtonPurpose.primary,
                      isLoading: _isLoading,
                      label: 'Sign In',
                      onPress: _onLogin,
                      backGroundColor: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ", style: TextStyle()),
                      GestureDetector(
                        onTap: () => Get.toNamed(RouteStrings.signUp),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: colors.secondary,
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
    );
  }
}
