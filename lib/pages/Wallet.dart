import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Models/wallet_activity_models.dart';
import 'package:voxtrade_core/Components/ModelDto/PaymentMethodDtos.dart';
import 'package:voxtrade_core/assembler/Controller/Payment_Method_Controller.dart';
import 'package:voxtrade_core/assembler/Controller/NavBarController.dart';
import 'package:voxtrade_core/assembler/Controller/ThemeController.dart';
import 'package:voxtrade_core/assembler/Controller/Wallet_Controller.dart';
import 'package:voxtrade_core/assembler/common/wallet_guards.dart';
import 'package:voxtrade_core/Components/Wallet/FrozenWalletBanner.dart';
import 'package:voxtrade_core/Components/shimer/themed_shimmer.dart';
import 'package:voxtrade_core/utils/shimmer_theme.dart';
import 'package:voxtrade_core/utils/wallet_page_theme.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage>
    with SingleTickerProviderStateMixin {
  static const int _walletTabIndex = 4;
  late final AnimationController _shimmerAnimCtrl;
  bool _wasWalletTabVisible = false;

  static const double _sectionGap = 24;

  @override
  void initState() {
    super.initState();
    _shimmerAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerAnimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletController = Get.find<WalletController>();
    final paymentController = Get.find<PaymentMethodController>();
    final themeController = Get.find<ThemeController>();
    final navController = Get.find<NavBarController>();

    return GetBuilder<NavBarController>(
      builder: (_) {
        final isWalletVisible = navController.tabIndex == _walletTabIndex;
        if (isWalletVisible && !_wasWalletTabVisible) {
          _wasWalletTabVisible = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            walletController.refreshWalletData();
          });
        } else if (!isWalletVisible) {
          _wasWalletTabVisible = false;
        }

        return Obx(() {
          themeController.isDarkMode.value;
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          final textTheme = theme.textTheme;
          final palette = WalletPagePalette.of(context);
          final isLoading = walletController.isLoading.value;
          final wallet = walletController.wallet.value;
          final walletFrozen = wallet.isFrozen;
          final paymentMethods = paymentController.userPaymentMethods;

          return Scaffold(
            backgroundColor: palette.pageBackground,
            extendBodyBehindAppBar: false,
            appBar: AppBar(
              title: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    color: colorScheme.primary,
                    size: 26,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Wallet',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: palette.primaryText,
                      letterSpacing: -0.4,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              centerTitle: false,
              backgroundColor: palette.pageBackground,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              foregroundColor: palette.primaryText,
              actions: [
                IconButton(
                  tooltip: 'Refresh',
                  onPressed:
                      isLoading
                          ? null
                          : () => walletController.refreshWalletData(),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                  ),
                  icon:
                      isLoading
                          ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          )
                          : Icon(Icons.refresh_rounded, color: colorScheme.primary),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    palette.pageBackground,
                    Color.lerp(
                      palette.pageBackground,
                      colorScheme.primary,
                      theme.brightness == Brightness.dark ? 0.06 : 0.04,
                    )!,
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child:
                    isLoading
                        ? _buildWalletShimmer(context)
                        : RefreshIndicator(
                          onRefresh: () => walletController.refreshWalletData(),
                          color: colorScheme.primary,
                          edgeOffset: 12,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (walletFrozen) ...[
                                  const FrozenWalletBanner(
                                    message: walletFrozenUserMessage,
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                _BalanceHeroCard(
                                  palette: palette,
                                  balance: wallet.balance,
                                  available: wallet.availableBalance,
                                  reserved: wallet.reservedBalance,
                                ),
                                const SizedBox(height: 18),
                                _QuickActionsRow(
                                  palette: palette,
                                  colorScheme: colorScheme,
                                  walletFrozen: walletFrozen,
                                  onTransfer:
                                      walletController.openTransferMoney,
                                  onAddMethod: walletController.addPaymentMethod,
                                  onManageMethods:
                                      walletController.openPaymentMethods,
                                ),
                                const SizedBox(height: _sectionGap),
                                _SectionHeader(
                                  title: 'Payment methods',
                                  subtitle:
                                      paymentMethods.isEmpty
                                          ? 'No methods linked yet'
                                          : '${paymentMethods.length} saved',
                                  palette: palette,
                                ),
                                const SizedBox(height: 12),
                                _PaymentMethodsPanel(
                                  palette: palette,
                                  colorScheme: colorScheme,
                                  paymentMethods: paymentMethods,
                                  paymentController: paymentController,
                                  walletFrozen: walletFrozen,
                                  onManage: walletController.openPaymentMethods,
                                  onAdd: walletController.addPaymentMethod,
                                ),
                                const SizedBox(height: _sectionGap),
                                _SectionHeader(
                                  title: 'Recent activity',
                                  subtitle: 'Latest wallet movements',
                                  palette: palette,
                                  trailing: TextButton(
                                    onPressed:
                                        walletController.openFullWalletHistory,
                                    style: TextButton.styleFrom(
                                      foregroundColor: colorScheme.primary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'See all',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _RecentActivityCard(
                                  palette: palette,
                                  colorScheme: colorScheme,
                                  transactions:
                                      walletController.recentWalletActivity
                                          .take(5)
                                          .toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildWalletShimmer(BuildContext context) {
    final base = shimmerBaseColor(context);

    Widget block(double h, {double radius = 14, EdgeInsets? margin}) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: ThemedShimmer(
          animation: _shimmerAnimCtrl,
          child: Container(
            height: h,
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        ),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        block(196, radius: 28),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: block(88, radius: 18)),
            const SizedBox(width: 12),
            Expanded(child: block(88, radius: 18)),
            const SizedBox(width: 12),
            Expanded(child: block(88, radius: 18)),
          ],
        ),
        const SizedBox(height: 24),
        block(14, radius: 6),
        const SizedBox(height: 12),
        block(140, radius: 22),
        const SizedBox(height: 24),
        block(14, radius: 6),
        const SizedBox(height: 12),
        ...List.generate(
          3,
          (_) => block(72, radius: 16, margin: const EdgeInsets.only(bottom: 10)),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.palette,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final WalletPagePalette palette;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 4,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: palette.ctaGradient,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: palette.primaryText,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.mutedText,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _BalanceHeroCard extends StatelessWidget {
  const _BalanceHeroCard({
    required this.palette,
    required this.balance,
    required this.available,
    required this.reserved,
  });

  final WalletPagePalette palette;
  final double balance;
  final double available;
  final double reserved;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent =
        palette.heroGradient.isNotEmpty
            ? palette.heroGradient.last
            : Theme.of(context).colorScheme.primary;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: palette.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.28 : 0.32),
            blurRadius: 32,
            offset: const Offset(0, 16),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -36,
            right: -24,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -48,
            left: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Total balance',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'USD',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  '\$${balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.2,
                    height: 1,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Updated just now',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 22),
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _HeroStat(
                              label: 'Available',
                              value: '\$${available.toStringAsFixed(2)}',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 36,
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                          Expanded(
                            child: _HeroStat(
                              label: 'In orders',
                              value: '\$${reserved.toStringAsFixed(2)}',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({
    required this.palette,
    required this.colorScheme,
    required this.walletFrozen,
    required this.onTransfer,
    required this.onAddMethod,
    required this.onManageMethods,
  });

  final WalletPagePalette palette;
  final ColorScheme colorScheme;
  final bool walletFrozen;
  final VoidCallback onTransfer;
  final VoidCallback onAddMethod;
  final VoidCallback onManageMethods;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionTile(
            palette: palette,
            colorScheme: colorScheme,
            icon: Icons.send_rounded,
            label: 'Transfer',
            enabled: !walletFrozen,
            onTap: onTransfer,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionTile(
            palette: palette,
            colorScheme: colorScheme,
            icon: Icons.add_card_rounded,
            label: 'Add method',
            enabled: !walletFrozen,
            onTap: onAddMethod,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionTile(
            palette: palette,
            colorScheme: colorScheme,
            icon: Icons.settings_outlined,
            label: 'Manage',
            enabled: true,
            onTap: onManageMethods,
            outlined: true,
          ),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.palette,
    required this.colorScheme,
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.outlined = false,
  });

  final WalletPagePalette palette;
  final ColorScheme colorScheme;
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: outlined ? palette.cardBackground : null,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 88,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient:
                outlined || !enabled
                    ? null
                    : LinearGradient(
                      colors: palette.ctaGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
            color:
                outlined
                    ? palette.cardBackground
                    : enabled
                    ? null
                    : palette.inputFill,
            border: Border.all(
              color:
                  outlined
                      ? colorScheme.primary.withValues(alpha: 0.28)
                      : palette.border.withValues(alpha: 0.2),
            ),
            boxShadow:
                outlined || !enabled
                    ? null
                    : [
                      BoxShadow(
                        color: palette.accent.withValues(alpha: 0.22),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color:
                    outlined
                        ? colorScheme.primary
                        : enabled
                        ? Colors.white
                        : palette.mutedText,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color:
                      outlined
                          ? colorScheme.primary
                          : enabled
                          ? Colors.white
                          : palette.mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodsPanel extends StatelessWidget {
  const _PaymentMethodsPanel({
    required this.palette,
    required this.colorScheme,
    required this.paymentMethods,
    required this.paymentController,
    required this.walletFrozen,
    required this.onManage,
    required this.onAdd,
  });

  final WalletPagePalette palette;
  final ColorScheme colorScheme;
  final List<UserPaymentMethodDto> paymentMethods;
  final PaymentMethodController paymentController;
  final bool walletFrozen;
  final VoidCallback onManage;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return WalletSurfaceCard(
      palette: palette,
      radius: 22,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (paymentMethods.isEmpty)
            _EmptyPaymentMethods(
              palette: palette,
              colorScheme: colorScheme,
              onAdd: walletFrozen ? null : onAdd,
            )
          else ...[
            ...paymentMethods.take(3).map(
              (method) => _PaymentMethodRow(
                method: method,
                palette: palette,
                colorScheme: colorScheme,
                paymentController: paymentController,
              ),
            ),
            if (paymentMethods.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Text(
                  '+ ${paymentMethods.length - 3} more saved',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: WalletOutlineButton(
                    palette: palette,
                    onPressed: onManage,
                    icon: Icons.tune_rounded,
                    label: 'Manage all',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: WalletGradientButton(
                    palette: palette,
                    height: 48,
                    onPressed: walletFrozen ? null : onAdd,
                    icon: Icons.add_rounded,
                    label: 'Add new',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyPaymentMethods extends StatelessWidget {
  const _EmptyPaymentMethods({
    required this.palette,
    required this.colorScheme,
    required this.onAdd,
  });

  final WalletPagePalette palette;
  final ColorScheme colorScheme;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.account_balance_outlined,
            size: 28,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Link a bank account or card',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: palette.primaryText,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Move money in and out of your wallet securely.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: palette.mutedText,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 16),
        WalletGradientButton(
          palette: palette,
          height: 48,
          onPressed: onAdd,
          icon: Icons.add_card_rounded,
          label: 'Add payment method',
        ),
      ],
    );
  }
}

class _PaymentMethodRow extends StatelessWidget {
  const _PaymentMethodRow({
    required this.method,
    required this.palette,
    required this.colorScheme,
    required this.paymentController,
  });

  final UserPaymentMethodDto method;
  final WalletPagePalette palette;
  final ColorScheme colorScheme;
  final PaymentMethodController paymentController;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: palette.inputFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: palette.ctaGradient),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              paymentController.iconForMethodType(method.methodType),
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method.methodName,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: palette.primaryText,
                  ),
                ),
                Text(
                  method.displayLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.verified_rounded,
            size: 18,
            color: colorScheme.primary.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({
    required this.palette,
    required this.colorScheme,
    required this.transactions,
  });

  final WalletPagePalette palette;
  final ColorScheme colorScheme;
  final List<WalletActivityTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    return WalletSurfaceCard(
      palette: palette,
      radius: 22,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child:
          transactions.isEmpty
              ? const _RecentActivityEmpty()
              : Column(
                children: [
                  for (var i = 0; i < transactions.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        indent: 62,
                        color: palette.border.withValues(alpha: 0.8),
                      ),
                    WalletTransactionItem(
                      transaction: transactions[i],
                      colorScheme: colorScheme,
                      palette: palette,
                    ),
                  ],
                ],
              ),
    );
  }
}

class _RecentActivityEmpty extends StatelessWidget {
  const _RecentActivityEmpty();

  @override
  Widget build(BuildContext context) {
    final palette = WalletPagePalette.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 40,
            color: palette.mutedText.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 12),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: palette.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Transfers and wallet activity will show up here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: palette.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

/// Single row in the wallet activity list (reusable on full history later).
class WalletTransactionItem extends StatelessWidget {
  const WalletTransactionItem({
    super.key,
    required this.transaction,
    required this.colorScheme,
    this.palette,
  });

  final WalletActivityTransaction transaction;
  final ColorScheme colorScheme;
  final WalletPagePalette? palette;

  static const Color _positiveGreen = Color(0xFF16A34A);
  static const Color _negativeRed = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final resolvedPalette = palette ?? WalletPagePalette.of(context);
    final isPositive = transaction.signedAmount >= 0;
    final amountColor = isPositive ? _positiveGreen : _negativeRed;
    final prefix = isPositive ? '+' : '-';
    final amountText =
        '$prefix\$${transaction.signedAmount.abs().toStringAsFixed(2)}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              transaction.kind.icon,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.displayTitle,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: resolvedPalette.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatWalletActivityDate(transaction.occurredAt),
                  style: textTheme.bodySmall?.copyWith(
                    color: resolvedPalette.mutedText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: amountColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              amountText,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: amountColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
