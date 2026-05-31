import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/ModelDto/PortfolioPositionDto.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/Components/cards/order_card.dart';
import 'package:voxtrade_core/Components/cards/trade_card.dart';
import 'package:voxtrade_core/assembler/Controller/Instrument_Controller.dart';
import 'package:voxtrade_core/assembler/Controller/NavBarController.dart';
import 'package:voxtrade_core/assembler/Controller/PortfolioController.dart';
import 'package:voxtrade_core/assembler/Controller/OrderHistory.dart';
import 'package:voxtrade_core/assembler/Controller/ThemeController.dart';
import 'package:voxtrade_core/assembler/Controller/TradeHistoryController.dart';
import 'package:voxtrade_core/assembler/Controller/market_chart_controller.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';
import 'package:voxtrade_core/Components/shimer/themed_shimmer.dart';
import 'package:voxtrade_core/pages/Market_Buy_Sell.dart';
import 'package:voxtrade_core/utils/responsive_layout.dart';
import 'package:voxtrade_core/utils/shimmer_theme.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage>
    with SingleTickerProviderStateMixin {
  static const _shimmerDuration = Duration(milliseconds: 950);
  static const int _portfolioNavTabIndex = 0;
  late final AnimationController _shimmerAnimCtrl;

  late final PortfolioController _portfolioController;
  late final OrderHistoryController _orderHistoryController;
  late final TradeHistoryController _tradeHistoryController;
  late final ThemeController _themeController;
  final Map<String, MarketChartController> _symbolControllers = {};
  final Set<String> _ownedControllers = <String>{};
  int _selectedTabIndex = 0;
  static const int _assetScopeAll = -1;
  static const int _historyInitialCount = 8;
  int _visibleOrdersCount = _historyInitialCount;
  int _visibleTradesCount = _historyInitialCount;
  String _selectedAccount = 'Primary';
  String _selectedPortfolio = 'Growth';
  int _assetScope = 5;
  bool _assetScopeInitialized = false;
  bool _wasPortfolioTabVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_assetScopeInitialized) {
      final info = responsiveInfoOf(context);
      _assetScope = info.isTablet ? 10 : 5;
      _assetScopeInitialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _shimmerAnimCtrl = AnimationController(
      vsync: this,
      duration: _shimmerDuration,
    )..repeat();
    _portfolioController =
        Get.isRegistered<PortfolioController>()
            ? Get.find<PortfolioController>()
            : Get.put(PortfolioController());
    _orderHistoryController =
        Get.isRegistered<OrderHistoryController>()
            ? Get.find<OrderHistoryController>()
            : Get.put(OrderHistoryController());
    _tradeHistoryController =
        Get.isRegistered<TradeHistoryController>()
            ? Get.find<TradeHistoryController>()
            : Get.put(TradeHistoryController());
    _themeController = Get.find<ThemeController>();
  }

  @override
  void dispose() {
    for (final symbol in _ownedControllers) {
      if (Get.isRegistered<MarketChartController>(tag: symbol)) {
        Get.delete<MarketChartController>(tag: symbol, force: true);
      }
    }
    _symbolControllers.clear();
    _ownedControllers.clear();
    _shimmerAnimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<NavBarController>();
    return GetBuilder<NavBarController>(
      builder: (_) {
        final isPortfolioVisible =
            navController.tabIndex == _portfolioNavTabIndex;
        if (isPortfolioVisible && !_wasPortfolioTabVisible) {
          _wasPortfolioTabVisible = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _refreshCurrentTabData();
          });
        } else if (!isPortfolioVisible) {
          _wasPortfolioTabVisible = false;
        }

        return Obx(() {
          final isDarkMode = _themeController.isDarkMode.value;
          final cs = Theme.of(context).colorScheme;
          final positions = _portfolioController.portfolio;
          final isLoading = _portfolioController.isLoading.value;
          _syncLivePriceControllers(positions);
          final refreshHandler =
              _selectedTabIndex == 0
                  ? _portfolioController.fetchPortfolio
                  : _selectedTabIndex == 1
                  ? () => _orderHistoryController.fetchOrders()
                  : _tradeHistoryController.fetchTrades;

          return Scaffold(
            backgroundColor: cs.surface,
            // appBar: AppBar(
            //   title: Text(
            //     'Portfolio',
            //     style: textTheme.titleLarge?.copyWith(
            //       fontWeight: FontWeight.w700,
            //       letterSpacing: -0.3,
            //       color: cs.onSurface,
            //     ),
            //   ),
            //   backgroundColor: cs.surface,
            //   foregroundColor: cs.onSurface,
            //   elevation: 0,
            //   surfaceTintColor: Colors.transparent,
            //   actions: [
            //     IconButton(
            //       icon: const Icon(Icons.notifications_none_rounded),
            //       onPressed: () {},
            //     ),
            //   ],
            // ),
            body: RefreshIndicator(
              onRefresh: refreshHandler,
              color: cs.primary,
              child: _buildTabBody(
                context: context,
                isDarkMode: isDarkMode,
                positions: positions,
                isLoading: isLoading,
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> _refreshCurrentTabData() async {
    if (_selectedTabIndex == 0) {
      await _portfolioController.fetchPortfolio();
      return;
    }
    if (_selectedTabIndex == 1) {
      await _orderHistoryController.fetchOrders();
      return;
    }
    await _tradeHistoryController.fetchTrades();
  }

  void _onPortfolioSectionSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
      if (index == 1) {
        _visibleOrdersCount = _historyInitialCount;
      } else if (index == 2) {
        _visibleTradesCount = _historyInitialCount;
      }
    });
    if (index == 1) {
      unawaited(_orderHistoryController.ensureLoaded());
    } else if (index == 2) {
      unawaited(_tradeHistoryController.ensureLoaded());
    }
  }

  Widget _buildTabBody({
    required BuildContext context,
    required bool isDarkMode,
    required List<PortfolioPositionDto> positions,
    required bool isLoading,
  }) {
    if (_selectedTabIndex == 0) {
      if (isLoading && positions.isEmpty) {
        return _buildLoadingState(context);
      }
      return _buildPositionsContent(
        context: context,
        positions: positions,
        isDarkMode: isDarkMode,
      );
    }

    if (_selectedTabIndex == 1) {
      return _buildOrdersTab(context);
    }

    return _buildHistoryTab(context);
  }

  Widget _buildPositionsContent({
    required BuildContext context,
    required List<PortfolioPositionDto> positions,
    required bool isDarkMode,
  }) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isWide = responsiveInfoOf(context).isDesktop;
    final scopedPositions = _scopedPositions(positions);

    if (positions.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        children: [
          // _buildSetupSection(context),
          // const SizedBox(height: 18),
          _buildSectionTabs(context, positions.length),
          const SizedBox(height: 14),
          _buildAssetScopeTabs(context),
          const SizedBox(height: 14),
          _buildAssetsTableCard(context, const []),
          const SizedBox(height: 34),
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 54,
            color: cs.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          // const SizedBox(height: 12),
          // Text(
          //   'No positions available',
          //   textAlign: TextAlign.center,
          //   style: textTheme.titleMedium?.copyWith(
          //     fontWeight: FontWeight.w600,
          //     color: cs.onSurface,
          //   ),
          // ),
          const SizedBox(height: 6),
          Text(
            'Your open instruments will appear here.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
      children: [
        // _buildSetupSection(context),
        // const SizedBox(height: 16),
        _buildSectionTabs(context, positions.length),
        const SizedBox(height: 12),
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    _buildAssetScopeTabs(context),
                    const SizedBox(height: 12),
                    _buildAssetsTableCard(
                      context,
                      scopedPositions,
                      totalCount: positions.length,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 5,
                child: _buildAnalyticsPanel(context, scopedPositions),
              ),
            ],
          )
        else ...[
          _buildAssetScopeTabs(context),
          const SizedBox(height: 12),
          _buildAssetsTableCard(
            context,
            scopedPositions,
            totalCount: positions.length,
          ),
          const SizedBox(height: 14),
          _buildAnalyticsPanel(context, scopedPositions),
        ],
      ],
    );
  }

  Widget _buildSetupSection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Setup',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _setupDropdown(
                  context: context,
                  label: 'Choose Account',
                  value: _selectedAccount,
                  options: const ['Primary', 'Trading', 'Savings'],
                  onChanged:
                      (value) => setState(() => _selectedAccount = value),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _setupDropdown(
                  context: context,
                  label: 'Choose Portfolio',
                  value: _selectedPortfolio,
                  options: const ['Growth', 'Balanced', 'Income'],
                  onChanged:
                      (value) => setState(() => _selectedPortfolio = value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _setupDropdown({
    required BuildContext context,
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withValues(alpha: 0.22)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(10),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w600,
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          hint: Text(label),
          items:
              options
                  .map(
                    (option) => DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    ),
                  )
                  .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }

  Widget _buildAssetScopeTabs(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _scopeTab(
              context: context,
              title: 'Top 5',
              selected: _assetScope == 5,
              onTap: () => setState(() => _assetScope = 5),
            ),
          ),
          Expanded(
            child: _scopeTab(
              context: context,
              title: 'Top 10',
              selected: _assetScope == 10,
              onTap: () => setState(() => _assetScope = 10),
            ),
          ),
          Expanded(
            child: _scopeTab(
              context: context,
              title: 'All',
              selected: _assetScope == _assetScopeAll,
              onTap: () => setState(() => _assetScope = _assetScopeAll),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scopeTab({
    required BuildContext context,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildAssetsTableCard(
    BuildContext context,
    List<PortfolioPositionDto> positions, {
    int? totalCount,
  }) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Assets',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              if (totalCount != null && totalCount > positions.length) ...[
                const SizedBox(width: 8),
                Text(
                  '(${positions.length} of $totalCount)',
                  style: textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const Spacer(),
              FilledButton.icon(
                onPressed: _openBuySellAddInstrument,
                style: FilledButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  textStyle: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Asset'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _headerCell(context, 'Assets', flex: 2),
              _headerCell(context, 'Volume', flex: 3),
              _headerCell(context, 'Risk', flex: 3, alignEnd: true),
              _headerCell(context, 'myRisk', flex: 3, alignEnd: true),
            ],
          ),
          const SizedBox(height: 8),
          ...positions.map(
            (item) => Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _openBuySellSellPosition(item.instrumentId),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.short_name.isNotEmpty
                              ? item.short_name
                              : item.symbol,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: textTheme.bodyMedium?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _moneyCell(
                        flex: 3,
                        value: _money(_liveMarketValue(item)),
                        style: textTheme.bodyMedium!.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      _moneyCell(
                        flex: 3,
                        value: _money(
                          (item.quantity * _effectivePrice(item) * 0.32).abs(),
                        ),
                        textAlign: TextAlign.end,
                        style: textTheme.bodyMedium!.copyWith(
                          color: cs.onSurface,
                        ),
                      ),
                      _moneyCell(
                        flex: 3,
                        value: _money(_liveUnrealizedPnl(item).abs()),
                        textAlign: TextAlign.end,
                        style: textTheme.bodyMedium!.copyWith(
                          color: _pnlColor(_liveUnrealizedPnl(item)),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(
    BuildContext context,
    String label, {
    required int flex,
    bool alignEnd = false,
  }) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: alignEnd ? TextAlign.end : TextAlign.start,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: muted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _moneyCell({
    required int flex,
    required String value,
    required TextStyle style,
    TextAlign textAlign = TextAlign.start,
  }) {
    final alignment =
        textAlign == TextAlign.end
            ? Alignment.centerRight
            : Alignment.centerLeft;
    return Expanded(
      flex: flex,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: alignment,
        child: Text(
          value,
          textAlign: textAlign,
          maxLines: 1,
          softWrap: false,
          style: style,
        ),
      ),
    );
  }

  Widget _buildAnalyticsPanel(
    BuildContext context,
    List<PortfolioPositionDto> positions,
  ) {
    return Column(
      children: [
        _buildAllocationCard(context, positions),
        const SizedBox(height: 12),
        _buildRiskCards(context, positions),
      ],
    );
  }

  Widget _buildAllocationCard(
    BuildContext context,
    List<PortfolioPositionDto> positions,
  ) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final total = positions.fold<double>(
      0,
      (sum, item) => sum + _liveMarketValue(item),
    );
    final chartItems =
        positions.take(_assetScope == _assetScopeAll ? 10 : 5).toList();
    final allocationTitle =
        _assetScope == _assetScopeAll
            ? 'Dollar Allocations (All ${positions.length})'
            : 'Dollar Allocations In Top ${chartItems.length}';
    final palette = const [
      Color(0xFF4F6BFF),
      Color(0xFFFF905D),
      Color(0xFF32D0A0),
      Color(0xFF4AB7FF),
      Color(0xFF8A7DFF),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            allocationTitle,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: CustomPaint(
                  painter: _RingChartPainter(
                    values: chartItems.map((e) => _liveMarketValue(e)).toList(),
                    colors: palette,
                    trackColor:
                        isDark
                            ? cs.outlineVariant.withValues(alpha: 0.35)
                            : const Color(0xFFE8ECF5),
                  ),
                  child: Center(
                    child: Text(
                      _money(total),
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  children: List.generate(chartItems.length, (index) {
                    final item = chartItems[index];
                    final share =
                        total <= 0 ? 0 : (_liveMarketValue(item) / total) * 100;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: palette[index % palette.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.short_name.isNotEmpty
                                  ? item.short_name
                                  : item.symbol,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Text(
                            '${share.toStringAsFixed(0)}%',
                            style: textTheme.bodySmall?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskCards(
    BuildContext context,
    List<PortfolioPositionDto> positions,
  ) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final total = positions.fold<double>(
      0,
      (sum, item) => sum + _liveMarketValue(item),
    );
    final riskPercent =
        total <= 0
            ? 0
            : (positions.fold<double>(
                      0,
                      (sum, item) => sum + _liveUnrealizedPnl(item).abs(),
                    ) /
                    total) *
                100;
    final riskiest =
        positions.isEmpty
            ? null
            : positions.reduce(
              (a, b) =>
                  _liveUnrealizedPnl(a).abs() > _liveUnrealizedPnl(b).abs()
                      ? a
                      : b,
            );
    final largest =
        positions.isEmpty
            ? null
            : positions.reduce(
              (a, b) => _liveMarketValue(a) > _liveMarketValue(b) ? a : b,
            );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio Risk Benchmark',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _riskCard(
                  context,
                  title: 'Dollar',
                  value: _money(
                    positions.fold<double>(
                      0,
                      (sum, item) => sum + _liveUnrealizedPnl(item).abs(),
                    ),
                  ),
                  highlighted: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _riskCard(
                  context,
                  title: 'Percentage',
                  value: '%${riskPercent.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _riskCard(
                  context,
                  title: 'Portfolio Value',
                  value: _money(total),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _riskCard(
                  context,
                  title: 'Riskiest Asset',
                  value:
                      riskiest == null
                          ? '-'
                          : (riskiest.short_name.isNotEmpty
                              ? riskiest.short_name
                              : riskiest.symbol),
                ),
              ),
            ],
          ),
          if (largest != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.primary.withValues(alpha: 0.22)),
              ),
              child: Text(
                'Largest Investment: ${largest.short_name.isNotEmpty ? largest.short_name : largest.symbol} (${_money(_liveMarketValue(largest))})',
                style: textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _riskCard(
    BuildContext context, {
    required String title,
    required String value,
    bool highlighted = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color:
            highlighted
                ? cs.primary.withValues(alpha: 0.12)
                : cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              highlighted
                  ? cs.primary.withValues(alpha: 0.28)
                  : cs.outline.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  List<PortfolioPositionDto> _scopedPositions(
    List<PortfolioPositionDto> positions,
  ) {
    final sorted = [...positions]
      ..sort((a, b) => _liveMarketValue(b).compareTo(_liveMarketValue(a)));
    if (_assetScope == _assetScopeAll) {
      return sorted;
    }
    final limit = math.min(_assetScope, sorted.length);
    return sorted.take(limit).toList();
  }

  Widget _buildOrdersTab(BuildContext context) {
    return Obx(() {
      final cs = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;
      if (_orderHistoryController.isLoading.value &&
          _orderHistoryController.orders.isEmpty) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
          children: [
            _buildSectionTabs(context, _portfolioController.portfolio.length),
            const SizedBox(height: 14),
            _buildHistoryHeader(
              context,
              title: 'Orders',
              subtitle: 'Latest order activity',
            ),
            const SizedBox(height: 12),
            ...List.generate(5, (_) => _historyShimmerCard(context)),
          ],
        );
      }

      if (_orderHistoryController.errorMessage.value != null &&
          _orderHistoryController.orders.isEmpty) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
          children: [
            _buildSectionTabs(context, _portfolioController.portfolio.length),
            const SizedBox(height: 14),
            _buildHistoryHeader(
              context,
              title: 'Orders',
              subtitle: 'Latest order activity',
            ),
            const SizedBox(height: 24),
            Icon(
              Icons.cloud_off_outlined,
              size: 52,
              color: cs.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 10),
            Text(
              _orderHistoryController.errorMessage.value ??
                  'Failed to load orders',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        );
      }

      if (_orderHistoryController.orders.isEmpty) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
          children: [
            _buildSectionTabs(context, _portfolioController.portfolio.length),
            const SizedBox(height: 14),
            _buildHistoryHeader(
              context,
              title: 'Orders',
              subtitle: 'Latest order activity',
            ),
            const SizedBox(height: 24),
            Icon(
              Icons.receipt_long_outlined,
              size: 52,
              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 10),
            Text(
              'No orders yet',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        );
      }

      final orders = _orderHistoryController.orders;
      final visibleCount = math.min(_visibleOrdersCount, orders.length);
      final visibleOrders = orders.take(visibleCount).toList();
      final hasMore = orders.length > visibleCount;

      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
        children: [
          _buildSectionTabs(context, _portfolioController.portfolio.length),
          const SizedBox(height: 14),
          _buildHistoryHeader(
            context,
            title: 'Orders',
            subtitle: 'Most recent first',
          ),
          const SizedBox(height: 10),
          OrderHistoryTable(
            orders: visibleOrders,
            onCancelPending: (o) => _orderHistoryController.cancelOrder(o),
            isCancelling:
                (id) => _orderHistoryController.cancellingOrderId.value == id,
          ),
          if (hasMore) ...[
            const SizedBox(height: 12),
            Center(
              child: FilledButton.tonalIcon(
                onPressed: () {
                  setState(() {
                    _visibleOrdersCount = math.min(
                      _visibleOrdersCount + _historyInitialCount,
                      orders.length,
                    );
                  });
                },
                icon: const Icon(Icons.expand_more_rounded),
                label: const Text('Show More Orders'),
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildHistoryTab(BuildContext context) {
    return Obx(() {
      final cs = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;
      if (_tradeHistoryController.isLoading.value &&
          _tradeHistoryController.trades.isEmpty) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
          children: [
            _buildSectionTabs(context, _portfolioController.portfolio.length),
            const SizedBox(height: 14),
            _buildHistoryHeader(
              context,
              title: 'Trades',
              subtitle: 'Execution and performance history',
            ),
            const SizedBox(height: 12),
            ...List.generate(5, (_) => _historyShimmerCard(context)),
          ],
        );
      }

      if (_tradeHistoryController.errorMessage.value != null &&
          _tradeHistoryController.trades.isEmpty) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
          children: [
            _buildSectionTabs(context, _portfolioController.portfolio.length),
            const SizedBox(height: 14),
            _buildHistoryHeader(
              context,
              title: 'Trades',
              subtitle: 'Execution and performance history',
            ),
            const SizedBox(height: 24),
            Icon(
              Icons.cloud_off_outlined,
              size: 52,
              color: cs.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 10),
            Text(
              _tradeHistoryController.errorMessage.value ??
                  'Failed to load trade history',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        );
      }

      if (_tradeHistoryController.trades.isEmpty) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
          children: [
            _buildSectionTabs(context, _portfolioController.portfolio.length),
            const SizedBox(height: 14),
            _buildHistoryHeader(
              context,
              title: 'Trades',
              subtitle: 'Execution and performance history',
            ),
            const SizedBox(height: 24),
            Icon(
              Icons.swap_horiz_rounded,
              size: 52,
              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 10),
            Text(
              'No trade history yet',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        );
      }

      final trades = _tradeHistoryController.trades;
      final visibleCount = math.min(_visibleTradesCount, trades.length);
      final visibleTrades = trades.take(visibleCount).toList();
      final hasMore = trades.length > visibleCount;

      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
        children: [
          _buildSectionTabs(context, _portfolioController.portfolio.length),
          const SizedBox(height: 14),
          _buildHistoryHeader(
            context,
            title: 'Trades',
            subtitle: 'Most recent first',
          ),
          const SizedBox(height: 10),
          TradeHistoryTable(trades: visibleTrades),
          if (hasMore) ...[
            const SizedBox(height: 12),
            Center(
              child: FilledButton.tonalIcon(
                onPressed: () {
                  setState(() {
                    _visibleTradesCount = math.min(
                      _visibleTradesCount + _historyInitialCount,
                      trades.length,
                    );
                  });
                },
                icon: const Icon(Icons.expand_more_rounded),
                label: const Text('Show More Trades'),
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildHistoryHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.history_rounded, color: cs.primary, size: 18),
        ],
      ),
    );
  }

  Widget _historyShimmerCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _shimmer(
        context,
        child: Container(
          height: 106,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: shimmerBaseColor(context),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTabs(BuildContext context, int positionsCount) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _tabText(
              context,
              'Assets ($positionsCount)',
              isSelected: _selectedTabIndex == 0,
              onTap: () => _onPortfolioSectionSelected(0),
            ),
          ),
          Expanded(
            child: _tabText(
              context,
              'Orders',
              isSelected: _selectedTabIndex == 1,
              onTap: () => _onPortfolioSectionSelected(1),
            ),
          ),
          Expanded(
            child: _tabText(
              context,
              'History',
              isSelected: _selectedTabIndex == 2,
              onTap: () => _onPortfolioSectionSelected(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabText(
    BuildContext context,
    String text, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: textTheme.titleSmall?.copyWith(
            color: isSelected ? Colors.white : cs.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _syncLivePriceControllers(List<PortfolioPositionDto> positions) {
    final activeSymbols =
        positions
            .map((p) => _normalizeSymbol(p.symbol))
            .where((s) => s.isNotEmpty)
            .toSet();

    for (final symbol in activeSymbols) {
      if (_symbolControllers.containsKey(symbol)) continue;

      MarketChartController controller;
      if (Get.isRegistered<MarketChartController>(tag: symbol)) {
        controller = Get.find<MarketChartController>(tag: symbol);
      } else {
        controller = Get.put(MarketChartController(symbol), tag: symbol);
        _ownedControllers.add(symbol);
      }
      _symbolControllers[symbol] = controller;
    }

    final staleSymbols =
        _symbolControllers.keys
            .where((s) => !activeSymbols.contains(s))
            .toList();
    for (final symbol in staleSymbols) {
      _symbolControllers.remove(symbol);
      if (_ownedControllers.remove(symbol) &&
          Get.isRegistered<MarketChartController>(tag: symbol)) {
        Get.delete<MarketChartController>(tag: symbol, force: true);
      }
    }
  }

  String _normalizeSymbol(String rawSymbol) {
    return rawSymbol.trim().toUpperCase();
  }

  double _effectivePrice(PortfolioPositionDto item) {
    final symbol = _normalizeSymbol(item.symbol);
    final livePrice = _symbolControllers[symbol]?.lastPrice.value ?? 0;
    if (livePrice > 0) return livePrice;
    return item.currentPrice;
  }

  double _liveMarketValue(PortfolioPositionDto item) {
    return item.quantity * _effectivePrice(item);
  }

  double _liveUnrealizedPnl(PortfolioPositionDto item) {
    return (_effectivePrice(item) - item.averageCost) * item.quantity;
  }

  Widget _buildLoadingState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
      children: [
        _shimmer(
          context,
          child: Container(
            height: 195,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: shimmerBaseColor(context),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: List.generate(3, (i) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == 2 ? 0 : 10),
                child: _shimmer(
                  context,
                  child: Container(
                    height: 22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: shimmerBaseColor(context),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 14),
        ...List.generate(6, (_) => _positionShimmerCard(context)),
      ],
    );
  }

  Widget _positionShimmerCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _shimmer(
        context,
        child: Container(
          height: 78,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: shimmerBaseColor(context),
          ),
        ),
      ),
    );
  }

  Widget _shimmer(BuildContext context, {required Widget child}) {
    return ThemedShimmer(animation: _shimmerAnimCtrl, child: child);
  }

  String _money(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  Color _pnlColor(double pnl) {
    return pnl >= 0 ? const Color(0xFF00C16A) : const Color(0xFFE2525C);
  }

  Future<void> _openBuySellAddInstrument() async {
    final InstrumentController instrumentController =
        Get.find<InstrumentController>();
    if (instrumentController.instruments.isEmpty) {
      await instrumentController.fetchInstruments();
    }
    if (instrumentController.instruments.isEmpty) {
      SnackBarComp.show(
        'No markets available right now.',
        title: 'Markets',
        status: SnackBarCompStatus.warning,
      );
      return;
    }
    final int id = instrumentController.resolveDefaultTradeInstrumentId();
    Get.to(
      () => MarketBuySell(instrumentId: id, initialIsBuy: true),
      preventDuplicates: false,
      transition: Transition.rightToLeft,
    );
  }

  void _openBuySellSellPosition(int instrumentId) {
    Get.to(
      () => MarketBuySell(instrumentId: instrumentId, initialIsBuy: false),
      preventDuplicates: false,
      transition: Transition.rightToLeft,
    );
  }
}

class _RingChartPainter extends CustomPainter {
  _RingChartPainter({
    required this.values,
    required this.colors,
    required this.trackColor,
  });

  final List<double> values;
  final List<Color> colors;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (sum, item) => sum + item);
    final stroke = size.width * 0.12;
    final rect = Offset.zero & size;
    final basePaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = trackColor;
    canvas.drawArc(
      rect.deflate(stroke / 2),
      -math.pi / 2,
      math.pi * 2,
      false,
      basePaint,
    );

    if (total <= 0) return;

    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * math.pi * 2;
      final paint =
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = stroke
            ..color = colors[i % colors.length];
      canvas.drawArc(rect.deflate(stroke / 2), start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _RingChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.colors != colors ||
        oldDelegate.trackColor != trackColor;
  }
}
