import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/ModelDto/RegisterDTO.dart';
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

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ThemeController _themeController = Get.find<ThemeController>();
  final _userController = Get.find<UserController>();
  String? _firstNameError;
  String? _lastNameError;
  String? _userNameError;
  String? _dateOfBirthError;
  String? _phoneError;
  String? _emailError;
  String? _passwordError;
  bool _agreedToTerms = false;
  bool _isLoading = false;
  bool _isButtonPressed = false;

  void _resetErrors() {
    _firstNameError = null;
    _lastNameError = null;
    _userNameError = null;
    _dateOfBirthError = null;
    _phoneError = null;
    _emailError = null;
    _passwordError = null;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _userNameController.dispose();
    _dateOfBirthController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = DateTime(now.year - 18, now.month, now.day);
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (selectedDate == null) return;
    final String formattedDate =
        '${selectedDate.year.toString().padLeft(4, '0')}-'
        '${selectedDate.month.toString().padLeft(2, '0')}-'
        '${selectedDate.day.toString().padLeft(2, '0')}';

    setState(() {
      _dateOfBirthController.text = formattedDate;
      _dateOfBirthError = null;
    });
  }

  Future<void> _onCreateAccount() async {
    setState(_resetErrors);

    final String firstName = _firstNameController.text.trim();
    final String lastName = _lastNameController.text.trim();
    final String userName = _userNameController.text.trim();
    final String dateOfBirth = _dateOfBirthController.text.trim();
    final String phoneNumber = _phoneController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (firstName.isEmpty) {
      setState(() => _firstNameError = 'First name is required.');
      SnackBarComp.show(
        'First name is required.',
        title: 'Validation Error',
        status: SnackBarCompStatus.warning,
      );
      return;
    }

    if (lastName.isEmpty) {
      setState(() => _lastNameError = 'Last name is required.');
      SnackBarComp.show(
        'Last name is required.',
        title: 'Validation Error',
        status: SnackBarCompStatus.warning,
      );
      return;
    }

    final String? userNameError = validateAuthUsername(userName);
    if (userNameError != null) {
      setState(() => _userNameError = userNameError);
      SnackBarComp.show(
        userNameError,
        title: 'Validation Error',
        status: SnackBarCompStatus.warning,
      );
      return;
    }

    if (dateOfBirth.isEmpty) {
      setState(() => _dateOfBirthError = 'Date of birth is required.');
      SnackBarComp.show(
        'Date of birth is required.',
        title: 'Validation Error',
        status: SnackBarCompStatus.warning,
      );
      return;
    }

    if (DateTime.tryParse(dateOfBirth) == null) {
      setState(() => _dateOfBirthError = 'Date of birth must be a valid date.');
      SnackBarComp.show(
        'Date of birth must be a valid date.',
        title: 'Validation Error',
        status: SnackBarCompStatus.warning,
      );
      return;
    }

    String normalizedPhoneNumber = phoneNumber.replaceAll(
      RegExp(r'[\s\-\(\)]'),
      '',
    );
    if (normalizedPhoneNumber.isEmpty) {
      setState(() => _phoneError = 'Phone number is required.');
      SnackBarComp.show(
        'Phone number is required.',
        title: 'Validation Error',
        status: SnackBarCompStatus.warning,
      );
      return;
    }
    if (!normalizedPhoneNumber.startsWith('+')) {
      normalizedPhoneNumber = '+$normalizedPhoneNumber';
    }
    final String phoneDigits = normalizedPhoneNumber
        .substring(1)
        .replaceAll(RegExp(r'\D'), '');
    normalizedPhoneNumber = '+$phoneDigits';
    final bool isValidPhone = RegExp(r'^[1-9]\d{6,14}$').hasMatch(phoneDigits);
    if (!isValidPhone) {
      setState(
        () =>
            _phoneError =
                'Enter a valid number with country code (e.g. +961 3 123 456).',
      );
      SnackBarComp.show(
        'Enter a valid number with country code (e.g. +961 3 123 456).',
        title: 'Validation Error',
        status: SnackBarCompStatus.warning,
      );
      return;
    }

    final String? emailError = validateAuthEmail(email);
    if (emailError != null) {
      setState(() => _emailError = emailError);
      SnackBarComp.show(
        emailError,
        title: 'Validation Error',
        status: SnackBarCompStatus.warning,
      );
      return;
    }

    final String? passwordError = validateAuthPassword(password);
    if (passwordError != null) {
      setState(() => _passwordError = passwordError);
      SnackBarComp.show(
        passwordError,
        title: 'Validation Error',
        status: SnackBarCompStatus.warning,
      );
      return;
    }

    if (!_agreedToTerms) {
      SnackBarComp.show(
        'Please agree to the terms and privacy policy.',
        title: 'Validation Error',
        status: SnackBarCompStatus.warning,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final DateTime parsedDateOfBirth = DateTime.parse(dateOfBirth);
    final RegisterDTO registerDTO = RegisterDTO(
      phoneNumber: normalizedPhoneNumber,
      email: email,
      password: password,
      firstNameEn: firstName,
      lastNameEn: lastName,
      username: userName,
      dob: parsedDateOfBirth,
    );
    final bool isRegistered = await _userController.registerFunction(registerDTO);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    debugPrint('Sign-up payload: ${registerDTO.toJson()}');
    if (isRegistered) {
      Get.offAllNamed(RouteStrings.root);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = _themeController.isDarkMode.value;
      final scheme = Theme.of(context).colorScheme;
      final Color primary = scheme.primary;
      final Color scaffoldBg = isDark ? const Color(0xFF0D0F14) : scheme.surface;
      final Color textColor = isDark ? Colors.white : scheme.onSurface;
      final Color subTextColor =
          isDark
              ? Colors.white.withValues(alpha: 0.65)
              : scheme.onSurfaceVariant;
      final Color hintColor =
          isDark ? Colors.grey.shade500 : scheme.onSurfaceVariant;
      final Color inputFill =
          isDark ? const Color(0xFF162235) : scheme.surfaceContainerHighest;
      final Color inputBorder =
          isDark
              ? Colors.white.withValues(alpha: 0.08)
              : scheme.outlineVariant.withValues(alpha: 0.6);

      return Scaffold(
        backgroundColor: scaffoldBg,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors:
                        isDark
                            ? const [Color(0xFF0B1220), Color(0xFF0F1B2E)]
                            : [
                              scheme.surfaceContainerLow,
                              scheme.surface,
                            ],
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
                                    'Create account',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: textColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'Set up your profile to start trading.',
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
                                        fillColor: inputFill,
                                        hintStyle: TextStyle(color: hintColor),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(color: inputBorder),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(color: primary),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: const BorderSide(color: Colors.redAccent),
                                        ),
                                      ),
                                      iconTheme: IconThemeData(
                                        color:
                                            isDark
                                                ? Colors.white.withValues(alpha: 0.82)
                                                : scheme.onSurfaceVariant,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        TextBoxField(
                                          placeHolder: 'First Name',
                                          objectName: _firstNameController,
                                          preFixIcon: const Icon(Icons.person_outline),
                                          sufixIcon: _kTextBoxEmptySuffix,
                                          errorText: _firstNameError,
                                          onChange: (_) {
                                            if (_firstNameError != null) {
                                              setState(() => _firstNameError = null);
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        TextBoxField(
                                          placeHolder: 'Last Name',
                                          objectName: _lastNameController,
                                          preFixIcon: const Icon(Icons.person_outline),
                                          sufixIcon: _kTextBoxEmptySuffix,
                                          errorText: _lastNameError,
                                          onChange: (_) {
                                            if (_lastNameError != null) {
                                              setState(() => _lastNameError = null);
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        TextBoxField(
                                          placeHolder: 'Username',
                                          objectName: _userNameController,
                                          preFixIcon: const Icon(Icons.alternate_email_rounded),
                                          sufixIcon: _kTextBoxEmptySuffix,
                                          errorText: _userNameError,
                                          onChange: (_) {
                                            if (_userNameError != null) {
                                              setState(() => _userNameError = null);
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        TextBoxField(
                                          placeHolder: 'Email Address',
                                          objectName: _emailController,
                                          preFixIcon: const Icon(Icons.email_outlined),
                                          sufixIcon: _kTextBoxEmptySuffix,
                                          errorText: _emailError,
                                          onChange: (_) {
                                            if (_emailError != null) {
                                              setState(() => _emailError = null);
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        TextBoxField(
                                          placeHolder: 'Create Password',
                                          objectName: _passwordController,
                                          preFixIcon: const Icon(Icons.lock_outline),
                                          isisSenstive: true,
                                          errorText: _passwordError,
                                          onChange: (_) {
                                            if (_passwordError != null) {
                                              setState(() => _passwordError = null);
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                          child: TextField(
                                            controller: _dateOfBirthController,
                                            readOnly: true,
                                            cursorColor: textColor,
                                            style: TextStyle(color: textColor),
                                            onTap: _pickDateOfBirth,
                                            decoration: InputDecoration(
                                              prefixIcon: const Icon(Icons.calendar_month_outlined),
                                              hintText: 'Date of Birth',
                                              hintStyle: TextStyle(color: hintColor),
                                              errorText: _dateOfBirthError,
                                              filled: true,
                                              fillColor: inputFill,
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(14),
                                                borderSide: BorderSide(color: inputBorder),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(14),
                                                borderSide: BorderSide(color: primary),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                          child: TextField(
                                            controller: _phoneController,
                                            keyboardType: const TextInputType.numberWithOptions(
                                              signed: true,
                                              decimal: false,
                                            ),
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9+\s\-\(\)]'),
                                              ),
                                            ],
                                            style: TextStyle(color: textColor),
                                            onChanged: (_) {
                                              if (_phoneError != null) {
                                                setState(() => _phoneError = null);
                                              }
                                            },
                                            decoration: InputDecoration(
                                              prefixIcon: const Icon(Icons.phone_outlined),
                                              hintText: 'Mobile Number',
                                              hintStyle: TextStyle(color: hintColor),
                                              errorText: _phoneError,
                                              filled: true,
                                              fillColor: inputFill,
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(14),
                                                borderSide: BorderSide(color: inputBorder),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(14),
                                                borderSide: BorderSide(color: primary),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Transform.scale(
                                          scale: 0.95,
                                          child: Checkbox(
                                            value: _agreedToTerms,
                                            activeColor: primary,
                                            onChanged: (value) {
                                              setState(() {
                                                _agreedToTerms = value ?? false;
                                              });
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 12),
                                            child: Text(
                                              'I certify that I am 18 years old and agree to the terms and privacy policy.',
                                              style: TextStyle(
                                                color: subTextColor,
                                                fontSize: 12,
                                                height: 1.35,
                                              ),
                                            ),
                                          ),
                                        ),
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
                                            label: 'Sign Up',
                                            onPress: _onCreateAccount,
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
                                        'Already have an account? ',
                                        style: TextStyle(
                                          color: subTextColor,
                                          fontSize: 13,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => Get.offNamed(RouteStrings.signIn),
                                        child: Text(
                                          'Log In',
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
