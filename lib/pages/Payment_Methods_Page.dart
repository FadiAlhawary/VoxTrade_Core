import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/ModelDto/PaymentMethodDtos.dart';
import 'package:voxtrade_core/assembler/Controller/Payment_Method_Controller.dart';
import 'package:voxtrade_core/assembler/Controller/ThemeController.dart';
import 'package:voxtrade_core/pages/Add_Payment_Method_Page.dart';
import 'package:voxtrade_core/Components/shimer/page_loading_shimmers.dart';
import 'package:voxtrade_core/utils/wallet_page_theme.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  late final PaymentMethodController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<PaymentMethodController>();
    _controller.fetchUserPaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      themeController.isDarkMode.value;
      final palette = WalletPagePalette.of(context);
      final scheme = Theme.of(context).colorScheme;
      final isLoading = _controller.isLoadingMethods.value;
      final methods = _controller.userPaymentMethods;
      _controller.deletingMethodId.value;

      return Scaffold(
        backgroundColor: palette.pageBackground,
        appBar: AppBar(
          title: const Text(
            'Payment methods',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: palette.cardBackground,
          foregroundColor: palette.primaryText,
          surfaceTintColor: Colors.transparent,
          actions: [
            IconButton(
              onPressed:
                  isLoading ? null : () => _controller.fetchUserPaymentMethods(),
              icon:
                  isLoading
                      ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.primary,
                        ),
                      )
                      : const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body:
            isLoading && methods.isEmpty
                ? const ListCardsPageShimmer(
                  cardHeight: 72,
                  borderRadius: 16,
                )
                : RefreshIndicator(
                  color: scheme.primary,
                  onRefresh: _controller.fetchUserPaymentMethods,
                  child:
                      methods.isEmpty
                          ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(20),
                            children: [
                              _EmptyPaymentMethods(palette: palette),
                            ],
                          )
                          : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(
                              16,
                              16,
                              16,
                              24,
                            ),
                            itemCount: methods.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final method = methods[index];
                              return _PaymentMethodTile(
                                method: method,
                                palette: palette,
                                controller: _controller,
                              );
                            },
                          ),
                ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Get.to(() => const AddPaymentMethodPage()),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          icon: const Icon(Icons.add_card_rounded),
          label: const Text(
            'Add method',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      );
    });
  }
}

class _EmptyPaymentMethods extends StatelessWidget {
  const _EmptyPaymentMethods({required this.palette});

  final WalletPagePalette palette;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: palette.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 40,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'No payment methods yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: palette.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Link a bank account or card to move money in and out of your wallet.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: palette.mutedText,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.method,
    required this.palette,
    required this.controller,
  });

  final UserPaymentMethodDto method;
  final WalletPagePalette palette;
  final PaymentMethodController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDeleting = controller.deletingMethodId.value == method.id;

    return Material(
      color: palette.cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: palette.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                controller.iconForMethodType(method.methodType),
                color: scheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.methodName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: palette.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method.displayLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: palette.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (method.displaySubtitle != method.displayLabel) ...[
                    const SizedBox(height: 2),
                    Text(
                      method.displaySubtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.mutedText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            isDeleting
                ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.error,
                    ),
                  ),
                )
                : IconButton(
                  onPressed:
                      () => controller.confirmAndRemovePaymentMethod(method),
                  icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
                  tooltip: 'Remove',
                ),
          ],
        ),
      ),
    );
  }
}
