import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:voxtrade_core/pages/Wallet_History_Page.dart';

/// Fintech-style canvas (Revolut / Stripe adjacent).
const Color _kPageBackground = Color(0xFFF5F7FA);
const Color _kCardWhite = Color(0xFFFFFFFF);
const Color _kBorderSubtle = Color(0xFFE2E8F0);
const Color _kLabelMuted = Color(0xFF64748B);

/// Hero gradient — blue tones (works in light mode; independent of theme primary).
const List<Color> _kHeroGradientColors = [
  Color(0xFF1E3A8A),
  Color(0xFF2563EB),
  Color(0xFF3B82F6),
];

// —————————————————————————————————————————————————————————————————————
// Wallet activity (preview)
// —————————————————————————————————————————————————————————————————————

enum WalletActivityKind { deposit, withdrawal, transfer }

extension WalletActivityKindX on WalletActivityKind {
  String get title => switch (this) {
        WalletActivityKind.deposit => 'Deposit',
        WalletActivityKind.withdrawal => 'Withdrawal',
        WalletActivityKind.transfer => 'Transfer',
      };

  IconData get icon => switch (this) {
        WalletActivityKind.deposit => Icons.south_west_rounded,
        WalletActivityKind.withdrawal => Icons.north_east_rounded,
        WalletActivityKind.transfer => Icons.swap_horiz_rounded,
      };
}

class WalletActivityTransaction {
  const WalletActivityTransaction({
    required this.kind,
    required this.occurredAt,
    required this.signedAmount,
  });

  final WalletActivityKind kind;
  final DateTime occurredAt;
  /// Positive = money in, negative = money out.
  final double signedAmount;

  String get displayTitle => kind.title;
}

String _formatWalletActivityDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}

class WalletController extends GetxController {
  var totalBalance = 14250.75.obs;
  var availableToTrade = 13800.00.obs;
  var reservedInOrders = 450.75.obs;

  final recentWalletActivity = <WalletActivityTransaction>[].obs;

  @override
  void onInit() {
    super.onInit();
    recentWalletActivity.assignAll(_demoWalletActivity);
  }

  /// Set to an empty list to show the empty state in the UI.
  static final _demoWalletActivity = <WalletActivityTransaction>[
    WalletActivityTransaction(
      kind: WalletActivityKind.deposit,
      occurredAt: DateTime.now().subtract(const Duration(hours: 5)),
      signedAmount: 500.00,
    ),
    WalletActivityTransaction(
      kind: WalletActivityKind.withdrawal,
      occurredAt: DateTime.now().subtract(const Duration(days: 1)),
      signedAmount: -120.00,
    ),
    WalletActivityTransaction(
      kind: WalletActivityKind.transfer,
      occurredAt: DateTime.now().subtract(const Duration(days: 2)),
      signedAmount: -75.50,
    ),
    WalletActivityTransaction(
      kind: WalletActivityKind.deposit,
      occurredAt: DateTime.now().subtract(const Duration(days: 4)),
      signedAmount: 2500.00,
    ),
    WalletActivityTransaction(
      kind: WalletActivityKind.transfer,
      occurredAt: DateTime.now().subtract(const Duration(days: 6)),
      signedAmount: 200.00,
    ),
  ];

  void openFullWalletHistory() {
    Get.to(() => const WalletHistoryPage());
  }

  Future<void> addPaymentMethod() async {
    Get.snackbar(
      'Add Payment Method',
      'Payment method flow will open here.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> viewOrderHistory() async {
    Get.snackbar(
      'Orders History',
      'Orders history screen will open here.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> viewTradeHistory() async {
    Get.snackbar(
      'Trade History',
      'Trade history screen will open here.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}

class WalletPage extends StatelessWidget {
  WalletPage({super.key});

  final WalletController controller = Get.put(WalletController());

  static const double _sectionGap = 28;
  static const double _radiusCard = 20;
  static const double _radiusMetric = 18;
  static const double _radiusPill = 30;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: _kPageBackground,
      appBar: AppBar(
        title: Text(
          'Wallet',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
        backgroundColor: _kPageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionTitle(
                text: 'Overview',
                textTheme: textTheme,
              ),
              const SizedBox(height: 16),
              _BalanceHeroCard(
                balance: controller.totalBalance,
              ),
              const SizedBox(height: _sectionGap),
              Obx(
                () => IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _MetricTile(
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                        icon: Icons.account_balance_outlined,
                        label: 'Available',
                        value:
                            '\$${controller.availableToTrade.value.toStringAsFixed(2)}',
                        radius: _radiusMetric,
                      ),
                      const SizedBox(width: 14),
                      _MetricTile(
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                        icon: Icons.pending_actions_outlined,
                        label: 'In orders',
                        value:
                            '\$${controller.reservedInOrders.value.toStringAsFixed(2)}',
                        radius: _radiusMetric,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: _sectionGap),
              _SectionTitle(
                text: 'Funding',
                textTheme: textTheme,
              ),
              const SizedBox(height: 16),
              _WhiteElevatedCard(
                radius: _radiusCard,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _IconBadge(
                            colorScheme: colorScheme,
                            icon: Icons.account_balance_wallet_outlined,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Payment methods',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Link a bank account or card to move money in and out.',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: _kLabelMuted,
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
                        onPressed: () => controller.addPaymentMethod(),
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
                textTheme: textTheme,
              ),
              const SizedBox(height: 16),
              Obx(
                () => _RecentActivityCard(
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  cardRadius: _radiusCard,
                  transactions: controller.recentWalletActivity.take(5).toList(),
                  onSeeAll: controller.openFullWalletHistory,
                ),
              ),
              const SizedBox(height: _sectionGap),
              _SectionTitle(
                text: 'History',
                textTheme: textTheme,
              ),
              const SizedBox(height: 16),
              _WhiteElevatedCard(
                radius: _radiusCard,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statements & activity',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Review orders and fills across your accounts.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: _kLabelMuted,
                          height: 1.45,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _OutlinePillButton(
                              height: 52,
                              radius: _radiusPill,
                              colorScheme: colorScheme,
                              onPressed: () => controller.viewOrderHistory(),
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
                              onPressed: () => controller.viewTradeHistory(),
                              icon: Icons.candlestick_chart_rounded,
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
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  thickness: 1,
                  indent: 52,
                  endIndent: 0,
                  color: _kBorderSubtle.withValues(alpha: 0.7),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 44,
            color: _kLabelMuted.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 14),
          Text(
            'No transactions yet',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: _kLabelMuted,
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
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatWalletActivityDate(transaction.occurredAt),
                  style: textTheme.bodySmall?.copyWith(
                    color: _kLabelMuted,
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
    required this.textTheme,
  });

  final String text;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: _kLabelMuted,
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
  const _BalanceHeroCard({
    required this.balance,
  });

  final Rx<double> balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: _kHeroGradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 14),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Obx(
        () => Column(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
              '\$${balance.value.toStringAsFixed(2)}',
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
      color: const Color(0xFF0F172A),
      fontSize: 20,
      height: 1.15,
      letterSpacing: -0.3,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _kCardWhite,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: _kBorderSubtle,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.045),
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
              child: Icon(
                icon,
                color: colorScheme.primary,
                size: 22,
              ),
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
                      color: _kLabelMuted,
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
  const _WhiteElevatedCard({
    required this.radius,
    required this.child,
  });

  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _kCardWhite,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: _kBorderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
  const _IconBadge({
    required this.colorScheme,
    required this.icon,
  });

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
      child: Icon(
        icon,
        color: colorScheme.primary,
        size: 24,
      ),
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
              colors: [
                Color(0xFF3B82F6),
                Color(0xFF2563EB),
                Color(0xFF1D4ED8),
              ],
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
      color: _kCardWhite,
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
