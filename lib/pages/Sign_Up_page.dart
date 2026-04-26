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
      final Color primary = Theme.of(context).colorScheme.primary;
      final bool isDark = _themeController.isDarkMode.value;
      final Color scaffoldBg =
          isDark ? const Color(0xFF071325) : const Color(0xFFEAF4FF);
      final Color cardBg =
          isDark ? const Color(0xFF162741) : const Color(0xFFFDFEFF);
      final Color fieldBg =
          isDark ? const Color(0xFF213858) : const Color(0xFFF3F8FF);
      final Color textColor = isDark ? Colors.white : const Color(0xFF142D4D);
      final Color subTextColor =
          isDark ? Colors.white70 : const Color(0xFF5A779A);
      final Color borderColor =
          isDark ? Colors.white10 : const Color(0xFFD5E4F8);

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
                      Color.alphaBlend(
                        primary.withValues(alpha: 0.28),
                        scaffoldBg,
                      ),
                      scaffoldBg,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -70,
                      right: -40,
                      child: Container(
                        width: 190,
                        height: 190,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primary.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 90,
                      left: -35,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(
                            alpha: isDark ? 0.06 : 0.22,
                          ),
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
                                    color: Colors.white.withValues(
                                      alpha: isDark ? 0.12 : 0.65,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.person_add_alt_1_rounded,
                                    color: primary,
                                    size: 34,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Let's Create\nAccount!",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium?.copyWith(
                                    color: textColor,
                                    height: 1.12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Welcome! Let\'s get started by creating your fresh account.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: subTextColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 850),
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
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(34),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: isDark ? 0.32 : 0.08,
                                    ),
                                    blurRadius: 16,
                                    offset: const Offset(0, -2),
                                  ),
                                ],
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
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
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                  ),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: Color.alphaBlend(
                                                  primary.withValues(
                                                    alpha: 0.35,
                                                  ),
                                                  fieldBg,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                              child: Text(
                                                'Sign Up',
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap:
                                                  () => Get.offNamed(
                                                    RouteStrings.signIn,
                                                  ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                    ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  'Login',
                                                  style: TextStyle(
                                                    color: subTextColor,
                                                    fontWeight: FontWeight.w500,
                                                  ),
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
                                        inputDecorationTheme:
                                            InputDecorationTheme(
                                              filled: true,
                                              fillColor: fieldBg,
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide(
                                                  color: borderColor,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide(
                                                  color: primary,
                                                ),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: const BorderSide(
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                            ),
                                      ),
                                      child: Column(
                                        children: [
                                          TextBoxField(
                                            placeHolder: 'First Name',
                                            objectName: _firstNameController,
                                            preFixIcon: const Icon(
                                              Icons.person_outline,
                                            ),
                                            sufixIcon: _kTextBoxEmptySuffix,
                                            errorText: _firstNameError,
                                            onChange: (_) {
                                              if (_firstNameError != null) {
                                                setState(
                                                  () => _firstNameError = null,
                                                );
                                              }
                                            },
                                          ),
                                          const SizedBox(height: 10),
                                          TextBoxField(
                                            placeHolder: 'Last Name',
                                            objectName: _lastNameController,
                                            preFixIcon: const Icon(
                                              Icons.person_outline,
                                            ),
                                            sufixIcon: _kTextBoxEmptySuffix,
                                            errorText: _lastNameError,
                                            onChange: (_) {
                                              if (_lastNameError != null) {
                                                setState(
                                                  () => _lastNameError = null,
                                                );
                                              }
                                            },
                                          ),
                                          const SizedBox(height: 10),
                                          TextBoxField(
                                            placeHolder: 'Username',
                                            objectName: _userNameController,
                                            preFixIcon: const Icon(
                                              Icons.alternate_email_rounded,
                                            ),
                                            sufixIcon: _kTextBoxEmptySuffix,
                                            errorText: _userNameError,
                                            onChange: (_) {
                                              if (_userNameError != null) {
                                                setState(
                                                  () => _userNameError = null,
                                                );
                                              }
                                            },
                                          ),
                                          const SizedBox(height: 10),
                                          TextBoxField(
                                            placeHolder: 'Email Address',
                                            objectName: _emailController,
                                            preFixIcon: const Icon(
                                              Icons.email_outlined,
                                            ),
                                            sufixIcon: _kTextBoxEmptySuffix,
                                            errorText: _emailError,
                                            onChange: (_) {
                                              if (_emailError != null) {
                                                setState(
                                                  () => _emailError = null,
                                                );
                                              }
                                            },
                                          ),
                                          const SizedBox(height: 10),
                                          TextBoxField(
                                            placeHolder: 'Create Password',
                                            objectName: _passwordController,
                                            preFixIcon: const Icon(
                                              Icons.lock_outline,
                                            ),
                                            isisSenstive: true,
                                            errorText: _passwordError,
                                            onChange: (_) {
                                              if (_passwordError != null) {
                                                setState(
                                                  () => _passwordError = null,
                                                );
                                              }
                                            },
                                          ),
                                          const SizedBox(height: 10),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                            ),
                                            child: TextField(
                                              controller:
                                                  _dateOfBirthController,
                                              readOnly: true,
                                              cursorColor:
                                                  isDark
                                                      ? Colors.white
                                                      : Colors.black,
                                              onTap: _pickDateOfBirth,
                                              decoration: InputDecoration(
                                                prefixIcon: const Icon(
                                                  Icons.calendar_month_outlined,
                                                ),
                                                hintText: 'Date of Birth',
                                                errorText: _dateOfBirthError,
                                                filled: true,
                                                fillColor: fieldBg,
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: borderColor,
                                                      ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: primary,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                            ),
                                            child: TextField(
                                              controller: _phoneController,
                                              keyboardType:
                                                  const TextInputType.numberWithOptions(
                                                    signed: true,
                                                    decimal: false,
                                                  ),
                                              inputFormatters: <
                                                TextInputFormatter
                                              >[
                                                FilteringTextInputFormatter.allow(
                                                  RegExp(r'[0-9+\s\-\(\)]'),
                                                ),
                                              ],
                                              onChanged: (_) {
                                                if (_phoneError != null) {
                                                  setState(
                                                    () => _phoneError = null,
                                                  );
                                                }
                                              },
                                              decoration: InputDecoration(
                                                prefixIcon: const Icon(
                                                  Icons.phone_outlined,
                                                ),
                                                hintText: 'Mobile Number',
                                                errorText: _phoneError,
                                                filled: true,
                                                fillColor: fieldBg,
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: borderColor,
                                                      ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: primary,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primary.withValues(
                                          alpha: isDark ? 0.15 : 0.08,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            size: 16,
                                            color: primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Use your real details to secure your account.',
                                              style: TextStyle(
                                                color: subTextColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Transform.scale(
                                            scale: 0.95,
                                            child: Checkbox(
                                              value: _agreedToTerms,
                                              activeColor: primary,
                                              onChanged: (value) {
                                                setState(() {
                                                  _agreedToTerms =
                                                      value ?? false;
                                                });
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                top: 12,
                                              ),
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
                                    const SizedBox(height: 4),
                                    SizedBox(
                                      width: double.infinity,
                                      child: Button(
                                        purpose: ButtonPurpose.primary,
                                        isLoading: _isLoading,
                                        label: 'Sign Up',
                                        onPress: _onCreateAccount,
                                        backGroundColor: primary,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildMiniFeature(
                                          icon: Icons.verified_user_outlined,
                                          label: 'Secure',
                                          color: subTextColor,
                                        ),
                                        _buildMiniFeature(
                                          icon: Icons.bolt_outlined,
                                          label: 'Fast Setup',
                                          color: subTextColor,
                                        ),
                                        _buildMiniFeature(
                                          icon: Icons.favorite_border_rounded,
                                          label: 'Friendly',
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
