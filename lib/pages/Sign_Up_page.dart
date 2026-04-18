import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _dateOfBirthController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = DateTime(
      now.year - 18,
      now.month,
      now.day,
    );
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

    _dateOfBirthController.text = formattedDate;
  }

  Future<void> _onCreateAccount() async {
    final String fullName = _fullNameController.text.trim();
    final String dateOfBirth = _dateOfBirthController.text.trim();
    final String phoneNumber = _phoneController.text.trim();
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

    final List<String> nameParts = fullName
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (nameParts.length < 2) {
      SnackBarComp.show(
        'Enter first and last name separated by a space (e.g. Jane Doe).',
        title: 'Validation Error',
        status: SnackBarCompStatus.warning,
      );
      return;
    }

    final String firstName = nameParts.first;
    final String lastName = nameParts.sublist(1).join(' ');

    if (dateOfBirth.isEmpty) {
      SnackBarComp.show(
        'Date of birth is required.',
        title: 'Validation Error',
        status: SnackBarCompStatus.warning,
      );
      return;
    }

    if (DateTime.tryParse(dateOfBirth) == null) {
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
    final String phoneDigits = normalizedPhoneNumber.substring(1).replaceAll(
      RegExp(r'\D'),
      '',
    );
    normalizedPhoneNumber = '+$phoneDigits';
    final bool isValidPhone = RegExp(r'^[1-9]\d{6,14}$').hasMatch(phoneDigits);
    if (!isValidPhone) {
      SnackBarComp.show(
        'Enter a valid number with country code (e.g. +961 3 123 456).',
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

    final Map<String, String> signUpPayload = {
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'phoneNumber': normalizedPhoneNumber,
      'email': email,
      'password': password,
    };
    debugPrint('Sign-up payload: $signUpPayload');

    SnackBarComp.show(
      'Account created. Please sign in.',
      title: 'Success',
      status: SnackBarCompStatus.success,
    );
    Get.offNamed(RouteStrings.signIn);
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
                    objectName: _fullNameController,
                    preFixIcon: const Icon(
                      Icons.person_outline_rounded,
                      color: Colors.white70,
                    ),
                    sufixIcon: _kTextBoxEmptySuffix,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _dateOfBirthController,
                      readOnly: true,
                      cursorColor: Colors.white,
                      onTap: _pickDateOfBirth,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.white70,
                        ),
                        suffixIcon: _kTextBoxEmptySuffix,
                        hintText: 'Date of Birth (YYYY-MM-DD)',
                        filled: true,
                        fillColor: Colors.grey.shade900,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade900,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade900,
                            width: 2,
                          ),
                        ),
                      ),
                      onTapOutside: (event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _phoneController,
                      cursorColor: Colors.white,
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: false,
                      ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9+\s\-\(\)]'),
                        ),
                      ],
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.phone_outlined,
                          color: Colors.white70,
                        ),
                        suffixIcon: _kTextBoxEmptySuffix,
                        hintText: 'e.g. +961 3 123 456',
                        filled: true,
                        fillColor: Colors.grey.shade900,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade900,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade900,
                            width: 2,
                          ),
                        ),
                      ),
                      onTapOutside: (event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                    ),
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
                        onTap: () => Get.offNamed(RouteStrings.signIn),
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
