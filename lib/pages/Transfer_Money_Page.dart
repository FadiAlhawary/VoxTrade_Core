import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/ModelDto/UserSearchResultDto.dart';
import 'package:voxtrade_core/Components/Wallet/FrozenWalletBanner.dart';
import 'package:voxtrade_core/assembler/Controller/ThemeController.dart';
import 'package:voxtrade_core/assembler/Controller/Wallet_Transfer_Controller.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';
import 'package:voxtrade_core/Components/shimer/page_loading_shimmers.dart';
import 'package:voxtrade_core/assembler/common/wallet_guards.dart';

class TransferMoneyPage extends StatefulWidget {
  const TransferMoneyPage({super.key});

  @override
  State<TransferMoneyPage> createState() => _TransferMoneyPageState();
}

class _TransferMoneyPageState extends State<TransferMoneyPage> {
  final _recipientSearchController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  late final WalletTransferController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(WalletTransferController());
    _amountController.addListener(_onFormChanged);
    _recipientSearchController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _recipientSearchController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    if (Get.isRegistered<WalletTransferController>()) {
      Get.delete<WalletTransferController>();
    }
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;

    final result = await _controller.submitTransfer(
      amount: amount,
      description: _descriptionController.text.trim(),
    );
    if (result?.success == true && mounted) {
      _amountController.clear();
      _descriptionController.clear();
      _recipientSearchController.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      themeController.isDarkMode.value;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final palette = _TransferPalette.of(context, isDark);

      final sender = _controller.currentSender;
      final recipient = _controller.selectedRecipient.value;
      final amount = double.tryParse(_amountController.text.trim()) ?? 0;
      final loading = _controller.isSubmitting.value;
      final senderFrozen = _controller.senderWalletFrozen.value;
      final hasSender = sender != null;
      final hasRecipient = recipient != null;
      final insufficient = amount > _controller.senderAvailableBalance.value;
      final canSubmit =
          !loading &&
          hasSender &&
          hasRecipient &&
          amount > 0 &&
          !senderFrozen &&
          !insufficient;

      return Scaffold(
        backgroundColor: palette.pageBackground,
        appBar: AppBar(
          title: const Text(
            'Transfer funds',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: palette.cardBackground,
          foregroundColor: palette.primaryText,
          surfaceTintColor: Colors.transparent,
        ),
        body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            children: [
              if (sender != null) ...[
                _StepHeader(
                  step: 1,
                  title: 'From',
                  subtitle: 'Your wallet',
                  palette: palette,
                ),
                const SizedBox(height: 8),
                _UserSummaryCard(
                  user: sender,
                  palette: palette,
                  trailing: Obx(() {
                    if (_controller.isLoadingSenderWallet.value) {
                      return const InlineShimmerPill(width: 88, height: 14);
                    }
                    return Text(
                      '\$${_controller.senderAvailableBalance.value.toStringAsFixed(2)} avail.',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: palette.accent,
                      ),
                    );
                  }),
                ),
                if (senderFrozen) ...[
                  const SizedBox(height: 8),
                  const FrozenWalletBanner(message: walletFrozenUserMessage),
                ],
                const SizedBox(height: 16),
              ],
              _StepHeader(
                step: 2,
                title: 'Recipient',
                subtitle: 'Search any VoxTrade user',
                palette: palette,
              ),
              const SizedBox(height: 8),
              _GlassCard(
                palette: palette,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _recipientSearchController,
                      style: TextStyle(
                        color: palette.primaryText,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: _inputDecoration(
                        palette: palette,
                        hint: 'Name or username',
                        prefix: Icon(
                          Icons.person_search_rounded,
                          color: palette.accent,
                        ),
                        suffix: Obx(() {
                          if (recipient != null) {
                            return IconButton(
                              tooltip: 'Clear',
                              onPressed: () {
                                _recipientSearchController.clear();
                                _controller.clearRecipient();
                              },
                              icon: Icon(
                                Icons.cancel_rounded,
                                color: palette.mutedText,
                              ),
                            );
                          }
                          if (_controller.isSearching.value) {
                            return const Padding(
                              padding: EdgeInsets.all(10),
                              child: InlineShimmerPill(width: 16, height: 16),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                      ),
                      onChanged: _controller.onSearchChanged,
                    ),
                    Obx(() {
                      if (_controller.searchResults.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        children: [
                          const SizedBox(height: 8),
                          Divider(height: 1, color: palette.border),
                          const SizedBox(height: 2),
                          ..._controller.searchResults.map(
                            (user) => _SearchResultTile(
                              user: user,
                              palette: palette,
                              onTap: () {
                                _controller.selectRecipient(user);
                                _recipientSearchController.text = user.label;
                              },
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              if (recipient != null) ...[
                const SizedBox(height: 8),
                _SelectedChip(
                  label: recipient.label,
                  palette: palette,
                  onClear: () {
                    _recipientSearchController.clear();
                    _controller.clearRecipient();
                  },
                ),
              ],
              const SizedBox(height: 16),
              _StepHeader(
                step: 3,
                title: 'Amount',
                subtitle: 'Optional note below',
                palette: palette,
              ),
              const SizedBox(height: 8),
              _GlassCard(
                palette: palette,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'AMOUNT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: palette.mutedText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '\$',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            color: palette.accent,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ),
                            ],
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: palette.primaryText,
                              letterSpacing: -0.5,
                              height: 1.1,
                            ),
                            decoration: InputDecoration(
                              hintText: '0.00',
                              hintStyle: TextStyle(
                                color: palette.mutedText.withValues(
                                  alpha: 0.45,
                                ),
                                fontWeight: FontWeight.w700,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Obx(() {
                      final available =
                          _controller.senderAvailableBalance.value;
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Available: \$${available.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                insufficient && amount > 0
                                    ? Colors.redAccent
                                    : palette.mutedText,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                    Divider(height: 1, color: palette.border),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 1,
                      style: TextStyle(color: palette.primaryText),
                      decoration: _inputDecoration(
                        palette: palette,
                        hint: 'Optional note',
                        prefix: Icon(
                          Icons.sticky_note_2_outlined,
                          color: palette.mutedText,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SubmitButton(
                palette: palette,
                isDark: isDark,
                loading: loading,
                canSubmit: canSubmit,
                label:
                    senderFrozen
                        ? 'Wallet frozen'
                        : insufficient && amount > 0
                        ? 'Insufficient balance'
                        : !hasRecipient
                        ? 'Select recipient'
                        : 'Transfer funds',
                onSubmit: _onSubmit,
              ),
            ],
          ),
        );
    });
  }

  InputDecoration _inputDecoration({
    required _TransferPalette palette,
    required String hint,
    required Widget prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: palette.mutedText, fontSize: 14),
      prefixIcon: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: palette.inputFill,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: palette.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: palette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: palette.accent, width: 1.5),
      ),
    );
  }
}

class _TransferPalette {
  const _TransferPalette({
    required this.pageBackground,
    required this.cardBackground,
    required this.inputFill,
    required this.primaryText,
    required this.mutedText,
    required this.border,
    required this.accent,
    required this.ctaGradient,
    required this.successSurface,
  });

  final Color pageBackground;
  final Color cardBackground;
  final Color inputFill;
  final Color primaryText;
  final Color mutedText;
  final Color border;
  final Color accent;
  final List<Color> ctaGradient;
  final Color successSurface;

  static _TransferPalette of(BuildContext context, bool isDark) {
    final scheme = Theme.of(context).colorScheme;
    if (isDark) {
      return _TransferPalette(
        pageBackground: const Color(0xFF060B14),
        cardBackground: const Color(0xFF0E1624),
        inputFill: const Color(0xFF121C2C),
        primaryText: Colors.white,
        mutedText: const Color(0xFF94A3B8),
        border: const Color(0xFF243044),
        accent: const Color(0xFF6CB4FF),
        ctaGradient: const [Color(0xFF3B82F6), Color(0xFF06B6D4)],
        successSurface: const Color(0xFF0D2818),
      );
    }
    return _TransferPalette(
      pageBackground: const Color(0xFFF4F8FC),
      cardBackground: Colors.white,
      inputFill: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      primaryText: scheme.onSurface,
      mutedText: scheme.onSurfaceVariant,
      border: scheme.outlineVariant.withValues(alpha: 0.55),
      accent: primaryColor,
      ctaGradient: [primaryColor, const Color(0xFF0EA5E9)],
      successSurface: const Color(0xFFECFDF5),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.palette,
  });

  final int step;
  final String title;
  final String subtitle;
  final _TransferPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: palette.ctaGradient),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            '$step',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: palette.primaryText,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: palette.mutedText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.palette, required this.child});

  final _TransferPalette palette;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: child,
    );
  }
}

class _UserSummaryCard extends StatelessWidget {
  const _UserSummaryCard({
    required this.user,
    required this.palette,
    required this.trailing,
  });

  final UserSearchResultDto user;
  final _TransferPalette palette;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: palette.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: palette.accent.withValues(alpha: 0.15),
            child: Icon(Icons.person_outline, color: palette.accent, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              user.label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: palette.primaryText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _SelectedChip extends StatelessWidget {
  const _SelectedChip({
    required this.label,
    required this.palette,
    required this.onClear,
  });

  final String label;
  final _TransferPalette palette;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: palette.successSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF10B981),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: palette.primaryText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: onClear,
            child: Icon(
              Icons.close_rounded,
              size: 18,
              color: palette.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.user,
    required this.palette,
    required this.onTap,
  });

  final UserSearchResultDto user;
  final _TransferPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name =
        user.displayName.trim().isEmpty ? user.username : user.displayName;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: palette.accent.withValues(alpha: 0.18),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: palette.accent,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: palette.primaryText,
                      ),
                    ),
                    Text(
                      '@${user.username}',
                      style: TextStyle(fontSize: 11, color: palette.mutedText),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: palette.accent,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.palette,
    required this.isDark,
    required this.loading,
    required this.canSubmit,
    required this.label,
    required this.onSubmit,
  });

  final _TransferPalette palette;
  final bool isDark;
  final bool loading;
  final bool canSubmit;
  final String label;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors:
              canSubmit
                  ? palette.ctaGradient
                  : [
                    palette.mutedText.withValues(alpha: 0.35),
                    palette.mutedText.withValues(alpha: 0.25),
                  ],
        ),
        boxShadow:
            canSubmit
                ? [
                  BoxShadow(
                    color: palette.accent.withValues(
                      alpha: isDark ? 0.35 : 0.28,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: canSubmit ? onSubmit : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                else
                  const Icon(
                    Icons.swap_horiz_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                const SizedBox(width: 8),
                Text(
                  loading ? 'Processing…' : label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
