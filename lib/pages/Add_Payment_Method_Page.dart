import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/Components/ModelDto/PaymentMethodDtos.dart';
import 'package:voxtrade_core/assembler/Controller/Payment_Method_Controller.dart';
import 'package:voxtrade_core/assembler/Controller/ThemeController.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';
import 'package:voxtrade_core/Components/shimer/page_loading_shimmers.dart';
import 'package:voxtrade_core/utils/wallet_page_theme.dart';

class AddPaymentMethodPage extends StatefulWidget {
  const AddPaymentMethodPage({super.key});

  @override
  State<AddPaymentMethodPage> createState() => _AddPaymentMethodPageState();
}

class _AddPaymentMethodPageState extends State<AddPaymentMethodPage> {
  late final PaymentMethodController _controller;
  final _primaryDetailController = TextEditingController();
  final _secondaryDetailController = TextEditingController();
  PaymentMethodTypeDto? _selectedType;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<PaymentMethodController>();
    _controller.fetchPaymentMethodTypes(force: true);
  }

  @override
  void dispose() {
    _primaryDetailController.dispose();
    _secondaryDetailController.dispose();
    super.dispose();
  }

  String get _primaryHint {
    final type = _selectedType?.methodType.toLowerCase() ?? '';
    if (type.contains('card')) return 'Card number or email on file';
    if (type.contains('bank')) return 'Account number or IBAN';
    if (type.contains('paypal')) return 'PayPal email';
    return 'Primary account detail';
  }

  String get _secondaryHint {
    final type = _selectedType?.methodType.toLowerCase() ?? '';
    if (type.contains('card')) return 'Nickname or last 4 digits (optional)';
    if (type.contains('bank')) return 'Bank name or nickname (optional)';
    return 'Optional label or nickname';
  }

  Future<void> _submit() async {
    final type = _selectedType;
    if (type == null) {
      SnackBarComp.show(
        'Choose a payment method type first.',
        title: 'Select a type',
        status: SnackBarCompStatus.warning,
      );
      return;
    }

    final success = await _controller.addPaymentMethod(
      paymentMethodId: type.id,
      attributeValue1: _primaryDetailController.text,
      attributeValue2: _secondaryDetailController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      themeController.isDarkMode.value;
      final palette = WalletPagePalette.of(context);
      final scheme = Theme.of(context).colorScheme;
      final types = _controller.paymentMethodTypes;
      final loadingTypes = _controller.isLoadingTypes.value;
      final submitting = _controller.isSubmitting.value;
      final canSubmit =
          !submitting && _selectedType != null &&
          _primaryDetailController.text.trim().isNotEmpty;

      return Scaffold(
        backgroundColor: palette.pageBackground,
        appBar: AppBar(
          title: const Text(
            'Add payment method',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: palette.cardBackground,
          foregroundColor: palette.primaryText,
          surfaceTintColor: Colors.transparent,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text(
              'Choose a method type and enter your account details.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: palette.mutedText,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'METHOD TYPE',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: palette.mutedText,
                letterSpacing: 0.8,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 10),
            if (loadingTypes && types.isEmpty)
              const FormFieldsPageShimmer(fieldCount: 3)
            else if (types.isEmpty)
              _InfoCard(
                palette: palette,
                message:
                    'No payment types are configured on the server yet. Ask an admin to seed the payment_method catalog.',
              )
            else
              ...types.map((type) {
                final selected = _selectedType?.id == type.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color:
                        selected
                            ? scheme.primary.withValues(alpha: 0.12)
                            : palette.cardBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color:
                            selected
                                ? scheme.primary.withValues(alpha: 0.55)
                                : palette.border,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setState(() => _selectedType = type),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: scheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _controller.iconForMethodType(type.methodType),
                                color: scheme.primary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    type.methodName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: palette.primaryText,
                                        ),
                                  ),
                                  Text(
                                    type.methodType,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: palette.mutedText),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              selected
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color:
                                  selected
                                      ? scheme.primary
                                      : palette.mutedText,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 12),
            Text(
              'DETAILS',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: palette.mutedText,
                letterSpacing: 0.8,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 10),
            _WalletTextField(
              controller: _primaryDetailController,
              palette: palette,
              label: 'Primary detail',
              hint: _primaryHint,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            _WalletTextField(
              controller: _secondaryDetailController,
              palette: palette,
              label: 'Secondary detail',
              hint: _secondaryHint,
            ),
            const SizedBox(height: 24),
            WalletGradientButton(
              palette: palette,
              enabled: canSubmit,
              loading: submitting,
              icon: Icons.check_rounded,
              label: 'Save payment method',
              onPressed: canSubmit ? _submit : null,
            ),
          ],
        ),
      );
    });
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.palette, required this.message});

  final WalletPagePalette palette;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: palette.mutedText,
          height: 1.45,
        ),
      ),
    );
  }
}

class _WalletTextField extends StatelessWidget {
  const _WalletTextField({
    required this.controller,
    required this.palette,
    required this.label,
    required this.hint,
    this.onChanged,
  });

  final TextEditingController controller;
  final WalletPagePalette palette;
  final String label;
  final String hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: palette.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          style: TextStyle(color: palette.primaryText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: palette.mutedText),
            filled: true,
            fillColor: palette.inputFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: palette.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: palette.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: scheme.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
