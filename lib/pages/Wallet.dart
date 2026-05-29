import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Models/wallet_activity_models.dart';
import 'package:voxtrade_core/assembler/Controller/NavBarController.dart';
import 'package:voxtrade_core/assembler/Controller/ThemeController.dart';
import 'package:voxtrade_core/assembler/Controller/Wallet_Controller.dart';
import 'package:voxtrade_core/Components/shimer/themed_shimmer.dart';
import 'package:voxtrade_core/utils/shimmer_theme.dart';

/// Hero gradient — blue tones; [Brightness.dark] uses deeper blues on dark surfaces.
List<Color> _walletHeroGradientColors(Brightness brightness) {
  if (brightness == Brightness.dark) {
    return const [Color(0xFF0C1222), Color(0xFF1E3A8A), Color(0xFF1D4ED8)];
  }
  return const [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)];
}

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

  static const double _sectionGap = 28;
  static const double _radiusCard = 20;
  static const double _radiusMetric = 18;
  static const double _radiusPill = 30;

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
    final themeController = Get.find<ThemeController>();
    final navController = Get.find<NavBarController>();

    return GetBuilder<NavBarController>(
      builder: (_) {
        final isWalletVisible = navController.tabIndex == _walletTabIndex;
        if (isWalletVisible && !_wasWalletTabVisible) {
          _wasWalletTabVisible = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            walletController.fetchWallet();
          });
        } else if (!isWalletVisible) {
          _wasWalletTabVisible = false;
        }

        return Obx(() {
          themeController.isDarkMode.value;
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          final textTheme = theme.textTheme;
          final heroColors = _walletHeroGradientColors(theme.brightness);
          final isLoading = walletController.isLoading.value;

          return Scaffold(
            backgroundColor: colorScheme.surface,
            appBar: AppBar(
              title: Text(
                'Wallet',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              centerTitle: false,
              backgroundColor: colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              foregroundColor: colorScheme.onSurface,
              actions: [
                IconButton(
                  onPressed:
                      isLoading ? null : () => walletController.fetchWallet(),
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
                          : const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            body: SafeArea(
              child:
                  isLoading
                      ? _buildWalletShimmer(context, theme)
                      : RefreshIndicator(
                        onRefresh: () => walletController.fetchWallet(),
                        color: colorScheme.primary,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SectionTitle(
                                text: 'Overview',
                                colorScheme: colorScheme,
                                textTheme: textTheme,
                              ),
                              const SizedBox(height: 16),
                              _BalanceHeroCard(
                                balance: walletController.wallet.value.balance,
                                gradientColors: heroColors,
                              ),
                              const SizedBox(height: _sectionGap),
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _MetricTile(
                                      colorScheme: colorScheme,
                                      textTheme: textTheme,
                                      icon: Icons.account_balance_outlined,
                                      label: 'Available',
                                      value:
                                          '\$${walletController.wallet.value.availableBalance.toStringAsFixed(2)}',
                                      radius: _radiusMetric,
                                    ),
                                    const SizedBox(width: 14),
                                    _MetricTile(
                                      colorScheme: colorScheme,
                                      textTheme: textTheme,
                                      icon: Icons.pending_actions_outlined,
                                      label: 'In orders',
                                      value:
                                          '\$${walletController.wallet.value.reservedBalance.toStringAsFixed(2)}',
                                      radius: _radiusMetric,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: _sectionGap),
                              _SectionTitle(
                                text: 'Funding',
                                colorScheme: colorScheme,
                                textTheme: textTheme,
                              ),
                              const SizedBox(height: 16),
                              _WhiteElevatedCard(
                                radius: _radiusCard,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _IconBadge(
                                            colorScheme: colorScheme,
                                            icon:
                                                Icons
                                                    .account_balance_wallet_outlined,
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Payment methods',
                                                  style: textTheme.titleMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            colorScheme
                                                                .onSurface,
                                                        letterSpacing: -0.2,
                                                      ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Link a bank account or card to move money in and out.',
                                                  style: textTheme.bodyMedium
                                                      ?.copyWith(
                                                        color:
                                                            colorScheme
                                                                .onSurfaceVariant,
                                                        height: 1.45,
                                                        fontSize: 14,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      _GradientPillButton(
                                        height: 54,
                                        radius: _radiusPill,
                                        onPressed:
                                            walletController.addPaymentMethod,
                                        icon: Icons.add_card_rounded,
                                        label: 'Add payment method',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: _sectionGap),
                              _SectionTitle(
                                text: 'Recent activity',
                                colorScheme: colorScheme,
                                textTheme: textTheme,
                              ),
                              const SizedBox(height: 16),
                              _RecentActivityCard(
                                colorScheme: colorScheme,
                                textTheme: textTheme,
                                cardRadius: _radiusCard,
                                transactions:
                                    walletController.recentWalletActivity
                                        .take(5)
                                        .toList(),
                                onSeeAll:
                                    walletController.openFullWalletHistory,
                              ),
                              const SizedBox(height: _sectionGap),
                              _SectionTitle(
                                text: 'History',
                                colorScheme: colorScheme,
                                textTheme: textTheme,
                              ),
                              const SizedBox(height: 16),
                              _WhiteElevatedCard(
                                radius: _radiusCard,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Statements & activity',
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: colorScheme.onSurface,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Review orders and fills across your accounts.',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                          height: 1.45,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: _OutlinePillButton(
                                              height: 52,
                                              radius: _radiusPill,
                                              colorScheme: colorScheme,
                                              onPressed:
                                                  walletController
                                                      .viewOrderHistory,
                                              icon: Icons.receipt_long_rounded,
                                              label: 'Orders history',
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: _OutlinePillButton(
                                              height: 52,
                                              radius: _radiusPill,
                                              colorScheme: colorScheme,
                                              onPressed:
                                                  walletController
                                                      .viewTradeHistory,
                                              icon:
                                                  Icons
                                                      .candlestick_chart_rounded,
                                              label: 'Trade history',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
            ),
          );
        });
      },
    );
  }

  Widget _buildWalletShimmer(BuildContext context, ThemeData theme) {
    final base = shimmerBaseColor(context);

    Widget block(double h, {double radius = 14}) {
      return ThemedShimmer(
        animation: _shimmerAnimCtrl,
        child: Container(
          height: h,
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        block(14, radius: 8),
        const SizedBox(height: 14),
        block(184, radius: 24),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(child: block(102, radius: 18)),
            const SizedBox(width: 14),
            Expanded(child: block(102, radius: 18)),
          ],
        ),
        const SizedBox(height: 24),
        block(14, radius: 8),
        const SizedBox(height: 14),
        block(176, radius: 20),
        const SizedBox(height: 24),
        block(14, radius: 8),
        const SizedBox(height: 14),
        ...List.generate(
          4,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: block(74, radius: 14),
          ),
        ),
      ],
    );
  }

}

// —————————————————————————————————————————————————————————————————————
// Recent activity (wallet transactions preview)
// —————————————————————————————————————————————————————————————————————

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({
    required this.colorScheme,
    required this.textTheme,
    required this.cardRadius,
    required this.transactions,
    required this.onSeeAll,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final double cardRadius;
  final List<WalletActivityTransaction> transactions;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return _WhiteElevatedCard(
      radius: cardRadius,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (transactions.isEmpty)
              const _RecentActivityEmpty()
            else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder:
                    (_, __) => Divider(
                      height: 1,
                      thickness: 1,
                      indent: 52,
                      endIndent: 0,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                    ),
                itemBuilder: (context, index) {
                  return WalletTransactionItem(
                    transaction: transactions[index],
                    colorScheme: colorScheme,
                  );
                },
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onSeeAll,
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                  child: Text(
                    'See all',
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecentActivityEmpty extends StatelessWidget {
  const _RecentActivityEmpty();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 44,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 14),
          Text(
            'No transactions yet',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
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
  });

  final WalletActivityTransaction transaction;
  final ColorScheme colorScheme;

  static const Color _positiveGreen = Color(0xFF16A34A);
  static const Color _negativeRed = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isPositive = transaction.signedAmount >= 0;
    final amountColor = isPositive ? _positiveGreen : _negativeRed;
    final prefix = isPositive ? '+' : '-';
    final amountText =
        '$prefix\$${transaction.signedAmount.abs().toStringAsFixed(2)}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              transaction.kind.icon,
              color: colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.displayTitle,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatWalletActivityDate(transaction.occurredAt),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amountText,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: amountColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// —————————————————————————————————————————————————————————————————————
// Section title
// —————————————————————————————————————————————————————————————————————

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.text,
    required this.colorScheme,
    required this.textTheme,
  });

  final String text;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: colorScheme.onSurfaceVariant,
        letterSpacing: 1.0,
        fontSize: 12,
      ),
    );
  }
}

// —————————————————————————————————————————————————————————————————————
// Hero balance
// —————————————————————————————————————————————————————————————————————

class _BalanceHeroCard extends StatelessWidget {
  const _BalanceHeroCard({required this.balance, required this.gradientColors});

  final double balance;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF2563EB,
            ).withValues(alpha: isDark ? 0.22 : 0.35),
            blurRadius: 28,
            offset: const Offset(0, 14),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Total balance',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'USD',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '\$${balance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.9,
              height: 1.05,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Cash and positions · Est. now',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// —————————————————————————————————————————————————————————————————————
// Metric tiles
// —————————————————————————————————————————————————————————————————————

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.colorScheme,
    required this.textTheme,
    required this.icon,
    required this.label,
    required this.value,
    required this.radius,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final IconData icon;
  final String label;
  final String value;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final amountStyle = textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w800,
      color: colorScheme.onSurface,
      fontSize: 20,
      height: 1.15,
      letterSpacing: -0.3,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: colorScheme.outlineVariant, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha:
                    Theme.of(context).brightness == Brightness.dark
                        ? 0.35
                        : 0.045,
              ),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 0.2,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: amountStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// —————————————————————————————————————————————————————————————————————
// White card shell
// —————————————————————————————————————————————————————————————————————

class _WhiteElevatedCard extends StatelessWidget {
  const _WhiteElevatedCard({required this.radius, required this.child});

  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.colorScheme, required this.icon});

  final ColorScheme colorScheme;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: colorScheme.primary, size: 24),
    );
  }
}

// —————————————————————————————————————————————————————————————————————
// Buttons
// —————————————————————————————————————————————————————————————————————

class _GradientPillButton extends StatelessWidget {
  const _GradientPillButton({
    required this.height,
    required this.radius,
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  final double height;
  final double radius;
  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF2563EB), Color(0xFF1D4ED8)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlinePillButton extends StatelessWidget {
  const _OutlinePillButton({
    required this.height,
    required this.radius,
    required this.colorScheme,
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  final double height;
  final double radius;
  final ColorScheme colorScheme;
  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorScheme.surfaceContainerHighest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
