import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/AppSell/AppShell.dart';
import 'package:voxtrade_core/Components/common/Buttons/Button.dart';
import 'package:voxtrade_core/Components/common/TextField/TextBoxField.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/pages/Sign_Up_page.dart';
import 'package:voxtrade_core/utils/auth_credentials_validation.dart';

import '../assembler/common/enum.dart';

/// Invisible placeholder — [TextBoxField] requires a non-null [sufixIcon] when the field is not sensitive.
const Icon _kTextBoxEmptySuffix =
    Icon(Icons.circle, size: 0, color: Colors.transparent);

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    final String? emailError = validateAuthEmail(email);
    if (emailError != null) {
      SnackBarComp.show(
        emailError,
        title: 'Validation Error',
        status: SnackBarCompStatus.warning,
      );
      return;
    }

    final String? passwordError = validateAuthPassword(password);
    if (passwordError != null) {
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

    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    Get.offAll(() => const AppShell());
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
                  Icon(
                    Icons.candlestick_chart_rounded,
                    size: 62,
                    color: colors.secondary,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue trading with VoxTrade.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextBoxField(
                    placeHolder: 'Email',
                    objectName: _emailController,
                    preFixIcon: const Icon(
                      Icons.email_outlined,
                      color: Colors.white70,
                    ),
                    sufixIcon: _kTextBoxEmptySuffix,
                  ),
                  const SizedBox(height: 16),
                  TextBoxField(
                    placeHolder: 'Password',
                    objectName: _passwordController,
                    isisSenstive: true,
                    preFixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: Colors.white70,
                    ),
                  ),
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
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.white70),
                      ),
                      GestureDetector(
                        onTap: () => Get.to(() => const SignUpPage()),
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
