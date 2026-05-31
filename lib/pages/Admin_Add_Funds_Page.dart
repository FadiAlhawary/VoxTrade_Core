import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/ModelDto/UserSearchResultDto.dart';
import 'package:voxtrade_core/assembler/Controller/Admin_Wallet_Controller.dart';
import 'package:voxtrade_core/assembler/Controller/ThemeController.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';
import 'package:voxtrade_core/assembler/common/wallet_guards.dart';
import 'package:voxtrade_core/Components/shimer/page_loading_shimmers.dart';
import 'package:voxtrade_core/Components/Wallet/FrozenWalletBanner.dart';

class AdminAddFundsPage extends StatefulWidget {
  const AdminAddFundsPage({super.key});

  @override
  State<AdminAddFundsPage> createState() => _AdminAddFundsPageState();
}

class _AdminAddFundsPageState extends State<AdminAddFundsPage> {
  final _searchController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountFocus = FocusNode();
  late final AdminWalletController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(AdminWalletController());
    _controller.selectedUser.listen((user) {
      if (user != null && _searchController.text != user.label) {
        _searchController.text = user.label;
      }
    });
    _amountController.addListener(_onFormChanged);
    _searchController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _amountFocus.dispose();
    if (Get.isRegistered<AdminWalletController>()) {
      Get.delete<AdminWalletController>();
    }
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;

    final result = await _controller.submitAddFunds(
      amount: amount,
      description: _descriptionController.text.trim(),
    );
    if (result?.success == true && mounted) {
      _amountController.clear();
      _descriptionController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      themeController.isDarkMode.value;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final palette = _AdminFundsPalette.of(context, isDark);

      return Scaffold(
        backgroundColor: palette.pageBackground,
        appBar: AppBar(
          title: const Text(
            'Add funds',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: palette.cardBackground,
          foregroundColor: palette.primaryText,
          surfaceTintColor: Colors.transparent,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          children: [
            _StepHeader(
              step: 1,
              title: 'Recipient',
              subtitle: 'Name or username',
              palette: palette,
            ),
            const SizedBox(height: 8),
                  _GlassCard(
                    palette: palette,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _searchController,
                          style: TextStyle(
                            color: palette.primaryText,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: _inputDecoration(
                            palette: palette,
                            hint: 'e.g. John or @trader_jane',
                            prefix: Icon(
                              Icons.person_search_rounded,
                              color: palette.accent,
                            ),
                            suffix: Obx(() {
                              if (_controller.selectedUser.value != null) {
                                return IconButton(
                                  tooltip: 'Clear',
                                  onPressed: () {
                                    _searchController.clear();
                                    _controller.clearSelection();
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
                          final results = _controller.searchResults;
                          if (results.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            children: [
                              const SizedBox(height: 8),
                              Divider(height: 1, color: palette.border),
                              const SizedBox(height: 2),
                              ...results.map(
                                (user) => _SearchResultTile(
                                  user: user,
                                  palette: palette,
                                  onTap: () => _controller.selectUser(user),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                  Obx(() {
                    final selected = _controller.selectedUser.value;
                    if (selected == null) {
                      return const SizedBox(height: 4);
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SelectedUserCard(
                            user: selected,
                            palette: palette,
                            onClear: () {
                              _searchController.clear();
                              _controller.clearSelection();
                            },
                          ),
                          if (_controller.targetWalletFrozen.value) ...[
                            const SizedBox(height: 8),
                            const FrozenWalletBanner(
                              message: walletFrozenTargetMessage,
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  _StepHeader(
                    step: 2,
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
                                focusNode: _amountFocus,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
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
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [50, 100, 250, 500].map((preset) {
                            return ActionChip(
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              label: Text('+\$$preset'),
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: palette.accent,
                                fontSize: 11,
                              ),
                              backgroundColor: palette.chipBackground,
                              side: BorderSide(color: palette.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              onPressed: () {
                                _amountController.text = preset.toString();
                                HapticFeedback.selectionClick();
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        Divider(height: 1, color: palette.border),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _descriptionController,
                          maxLines: 1,
                          style: TextStyle(color: palette.primaryText),
                          decoration: _inputDecoration(
                            palette: palette,
                            hint: 'Optional note for audit trail',
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
                  Obx(() {
                    final loading = _controller.isSubmitting.value;
                    final hasUser =
                        _controller.selectedUser.value != null;
                    final amount =
                        double.tryParse(_amountController.text.trim()) ?? 0;
                    final frozen = _controller.targetWalletFrozen.value;
                    final canSubmit =
                        !loading && hasUser && amount > 0 && !frozen;

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
                          onTap: canSubmit ? _onSubmit : null,
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
                                    Icons.bolt_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                const SizedBox(width: 8),
                                Text(
                                  loading
                                      ? 'Processing…'
                                      : frozen
                                      ? 'Wallet frozen'
                                      : hasUser
                                      ? 'Credit wallet'
                                      : 'Select recipient',
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
                  }),
          ],
        ),
      );
    });
  }

  InputDecoration _inputDecoration({
    required _AdminFundsPalette palette,
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

class _AdminFundsPalette {
  const _AdminFundsPalette({
    required this.pageBackground,
    required this.heroGradient,
    required this.cardBackground,
    required this.inputFill,
    required this.primaryText,
    required this.mutedText,
    required this.border,
    required this.accent,
    required this.chipBackground,
    required this.ctaGradient,
    required this.successSurface,
  });

  final Color pageBackground;
  final List<Color> heroGradient;
  final Color cardBackground;
  final Color inputFill;
  final Color primaryText;
  final Color mutedText;
  final Color border;
  final Color accent;
  final Color chipBackground;
  final List<Color> ctaGradient;
  final Color successSurface;

  static _AdminFundsPalette of(BuildContext context, bool isDark) {
    final scheme = Theme.of(context).colorScheme;
    if (isDark) {
      return _AdminFundsPalette(
        pageBackground: const Color(0xFF060B14),
        heroGradient: const [
          Color(0xFF0F2847),
          Color(0xFF1A4D7A),
          Color(0xFF2D6BA3),
        ],
        cardBackground: const Color(0xFF0E1624),
        inputFill: const Color(0xFF121C2C),
        primaryText: Colors.white,
        mutedText: const Color(0xFF94A3B8),
        border: const Color(0xFF243044),
        accent: const Color(0xFF6CB4FF),
        chipBackground: const Color(0xFF152033),
        ctaGradient: const [Color(0xFF3B82F6), Color(0xFF06B6D4)],
        successSurface: const Color(0xFF0D2818),
      );
    }
    return _AdminFundsPalette(
      pageBackground: const Color(0xFFF4F8FC),
      heroGradient: [
        primaryColor,
        Color.lerp(primaryColor, const Color(0xFF06B6D4), 0.45)!,
        const Color(0xFF38BDF8),
      ],
      cardBackground: Colors.white,
      inputFill: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      primaryText: scheme.onSurface,
      mutedText: scheme.onSurfaceVariant,
      border: scheme.outlineVariant.withValues(alpha: 0.55),
      accent: primaryColor,
      chipBackground: primaryColor.withValues(alpha: 0.08),
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
  final _AdminFundsPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        Expanded(
          child: Row(
            children: [
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
          ),
        ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.palette, required this.child});

  final _AdminFundsPalette palette;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? 0.28
                  : 0.05,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
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
  final _AdminFundsPalette palette;
  final VoidCallback onTap;

  String get _initials {
    final parts =
        user.displayName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) {
      return user.username.isNotEmpty
          ? user.username[0].toUpperCase()
          : '?';
    }
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.elementAt(1)[0]}'.toUpperCase();
  }

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
                  _initials,
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
                      style: TextStyle(
                        fontSize: 11,
                        color: palette.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.add_circle_outline_rounded,
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

class _SelectedUserCard extends StatelessWidget {
  const _SelectedUserCard({
    required this.user,
    required this.palette,
    required this.onClear,
  });

  final UserSearchResultDto user;
  final _AdminFundsPalette palette;
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
              user.label,
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
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.close_rounded, size: 18, color: palette.mutedText),
            ),
          ),
        ],
      ),
    );
  }
}
