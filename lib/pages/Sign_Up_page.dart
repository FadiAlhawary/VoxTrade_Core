import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/common/Buttons/Button.dart';
import 'package:voxtrade_core/Components/common/TextField/TextBoxField.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/pages/Sign_In_page.dart';
import 'package:voxtrade_core/utils/auth_credentials_validation.dart';

import '../assembler/common/enum.dart';

/// Invisible placeholder — [TextBoxField] requires a non-null [sufixIcon] when the field is not sensitive.
const Icon _kTextBoxEmptySuffix =
    Icon(Icons.circle, size: 0, color: Colors.transparent);

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onCreateAccount() async {
    final String fullName = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (fullName.isEmpty) {
      SnackBarComp.show(
        'Full name is required.',
        title: 'Validation Error',
        status: SnackBarCompStatus.warning,
      );
      return;
    }

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

    SnackBarComp.show(
      'Account created. Please sign in.',
      title: 'Success',
      status: SnackBarCompStatus.success,
    );
    Get.off(() => const SignInPage());
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
                    Icons.account_balance_wallet_rounded,
                    size: 62,
                    color: colors.secondary,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Set up your trading profile in seconds.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextBoxField(
                    placeHolder: 'Full Name',
                    objectName: _nameController,
                    preFixIcon: const Icon(
                      Icons.person_outline_rounded,
                      color: Colors.white70,
                    ),
                    sufixIcon: _kTextBoxEmptySuffix,
                  ),
                  const SizedBox(height: 16),
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
                      label: 'Create Account',
                      onPress: _onCreateAccount,
                      backGroundColor: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.white70),
                      ),
                      GestureDetector(
                        onTap: () => Get.off(() => const SignInPage()),
                        child: Text(
                          'Sign In',
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
