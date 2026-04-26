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
      final Color primary = Theme.of(context).colorScheme.primary;
      final bool isDark = _themeController.isDarkMode.value;
      final Color scaffoldBg = isDark ? const Color(0xFF071325) : const Color(0xFFEAF4FF);
      final Color cardBg = isDark ? const Color(0xFF162741) : const Color(0xFFFDFEFF);
      final Color fieldBg = isDark ? const Color(0xFF213858) : const Color(0xFFF3F8FF);
      final Color textColor = isDark ? Colors.white : const Color(0xFF142D4D);
      final Color subTextColor = isDark ? Colors.white70 : const Color(0xFF5A779A);
      final Color borderColor = isDark ? Colors.white10 : const Color(0xFFD5E4F8);

      return Scaffold(
        backgroundColor: scaffoldBg,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool compact = constraints.maxWidth < 390;
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.alphaBlend(primary.withValues(alpha: 0.28), scaffoldBg),
                      scaffoldBg,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -60,
                      right: -30,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primary.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 80,
                      left: -40,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: isDark ? 0.06 : 0.22),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 650),
                          tween: Tween<double>(begin: 0, end: 1),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, (1 - value) * -22),
                                child: child,
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              compact ? 18 : 26,
                              compact ? 18 : 26,
                              compact ? 18 : 26,
                              18,
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 64,
                                  width: 64,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.65),
                                  ),
                                  child: Icon(
                                    Icons.account_balance_wallet_rounded,
                                    color: primary,
                                    size: 34,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Hello,\nWelcome Back!',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: textColor,
                                    height: 1.12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Please enter your username and password details to access your account.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: subTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 800),
                            tween: Tween<double>(begin: 0, end: 1),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, (1 - value) * 26),
                                  child: child,
                                ),
                              );
                            },
                            child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(
                          compact ? 12 : 16,
                          18,
                          compact ? 12 : 16,
                          20,
                        ),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.08),
                              blurRadius: 16,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: fieldBg,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => Get.offNamed(RouteStrings.signUp),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Sign Up',
                                            style: TextStyle(
                                              color: subTextColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Color.alphaBlend(
                                            primary.withValues(alpha: 0.35),
                                            fieldBg,
                                          ),
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                        child: Text(
                                          'Login',
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Theme(
                                data: Theme.of(context).copyWith(
                                  inputDecorationTheme: InputDecorationTheme(
                                    filled: true,
                                    fillColor: fieldBg,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: borderColor),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: primary),
                                    ),
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
                                    const SizedBox(height: 12),
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
                              const SizedBox(height: 6),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: subTextColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: Button(
                                  purpose: ButtonPurpose.primary,
                                  isLoading: _isLoading,
                                  label: 'Log In',
                                  onPress: _onLogin,
                                  backGroundColor: primary,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildMiniFeature(
                                    icon: Icons.shield_outlined,
                                    label: 'Secure',
                                    color: subTextColor,
                                  ),
                                  _buildMiniFeature(
                                    icon: Icons.flash_on_outlined,
                                    label: 'Fast',
                                    color: subTextColor,
                                  ),
                                  _buildMiniFeature(
                                    icon: Icons.auto_graph_outlined,
                                    label: 'Smart',
                                    color: subTextColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildMiniFeature({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
