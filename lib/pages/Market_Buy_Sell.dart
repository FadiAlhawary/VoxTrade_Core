import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/Components/ModelDto/InstrumentDTO.dart';
import 'package:voxtrade_core/Models/LiveCandle.dart';
import 'package:voxtrade_core/Components/common/TextField/TextBoxField.dart';
import 'package:voxtrade_core/Components/common/Buttons/Button.dart';
import 'package:voxtrade_core/assembler/Controller/Instrument_Controller.dart';
import 'package:voxtrade_core/assembler/Controller/MarketController.dart';
import 'package:voxtrade_core/assembler/Controller/OrderHistory.dart';
import 'package:voxtrade_core/assembler/Controller/PortfolioController.dart';
import 'package:voxtrade_core/assembler/Controller/ThemeController.dart';
import 'package:voxtrade_core/assembler/Controller/TradeHistoryController.dart';
import 'package:voxtrade_core/assembler/Controller/Wallet_Controller.dart';
import 'package:voxtrade_core/assembler/Controller/market_chart_controller.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';
import 'package:voxtrade_core/utils/Helper.dart';

class MarketBuySell extends StatelessWidget {
  final int instrumentId;
  final bool initialIsBuy;
  MarketBuySell({
    super.key,
    required this.instrumentId,
    this.initialIsBuy = true,
  }) : _isBuySelected = initialIsBuy.obs;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _limitPriceController = TextEditingController();
  final RxBool _isBuySelected;
  final Rx<_OrderType> _orderType = _OrderType.market.obs;
  final RxBool _isSubmittingOrder = false.obs;
  final RxnString _amountError = RxnString();
  final RxnString _limitPriceError = RxnString();

  final InstrumentController _instrumentController =
      Get.find<InstrumentController>();
  final MarketController _marketController = Get.find<MarketController>();
  final ThemeController _themeController = Get.find<ThemeController>();
  final WalletController _walletController = Get.find<WalletController>();
  final TradeHistoryController _tradeController =
      Get.find<TradeHistoryController>();
  final OrderHistoryController _orderController =
      Get.find<OrderHistoryController>();
  final PortfolioController _portfolioController =
      Get.find<PortfolioController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final instrument = _instrumentController.getInstrumentById(instrumentId);
      final instruments = _instrumentsForDropdown(
        _instrumentController.instruments.toList(growable: false),
      );
      final symbol = instrument.symbol;
      if (!Get.isRegistered<MarketChartController>(tag: symbol)) {
        Get.put(MarketChartController(symbol), tag: symbol);
      }
      final chartController = Get.find<MarketChartController>(tag: symbol);
      final scheme = Theme.of(context).colorScheme;
      final isDark = _themeController.isDarkMode.value;
      final currentPrice =
          chartController.lastPrice.value > 0
              ? chartController.lastPrice.value
              : (chartController.candles.isNotEmpty
                  ? chartController.candles.last.close
                  : 0.0);
      final highPrice =
          chartController.candles.isNotEmpty
              ? chartController.candles
                  .map((c) => c.high)
                  .reduce((a, b) => a > b ? a : b)
              : 0.0;
      final lowPrice =
          chartController.candles.isNotEmpty
              ? chartController.candles
                  .map((c) => c.low)
                  .reduce((a, b) => a < b ? a : b)
              : 0.0;
      final candles = chartController.candles.toList(growable: false);

      final baseCurrency = _extractBaseSymbol(instrument.symbol);
      final quoteCurrency = _extractQuoteSymbol(instrument.symbol);
      final position = _portfolioController.portfolio.firstWhereOrNull(
        (p) => p.instrumentId == instrumentId,
      );
      final availableToSell = position?.availableQuantity ?? 0.0;
      final availableQuoteBalance =
          _walletController.wallet.value.availableBalance;
      final maxAffordableQty =
          currentPrice > 0 ? (availableQuoteBalance / currentPrice) : 0.0;
      final amount = double.tryParse(_amountController.text.trim()) ?? 0;
      final selectedExecutionPrice =
          _orderType.value == _OrderType.limit
              ? (double.tryParse(_limitPriceController.text.trim()) ?? 0)
              : currentPrice;
      final estimatedTotal = amount * selectedExecutionPrice;
      final canSubmit =
          _amountError.value == null &&
          _limitPriceError.value == null &&
          amount > 0 &&
          !_isSubmittingOrder.value;

      return Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: instrument.id,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(12),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    selectedItemBuilder:
                        (_) =>
                            instruments
                                .map(
                                  (item) => Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '${displayMarketName(item.symbol).trim()} Trade',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                    items:
                        instruments
                            .map(
                              (item) => DropdownMenuItem<int>(
                                value: item.id,
                                child: Text(displayMarketName(item.symbol)),
                              ),
                            )
                            .toList(),
                    onChanged: (selectedId) {
                      if (selectedId == null || selectedId == instrument.id) {
                        return;
                      }
                      Get.off(
                        () => MarketBuySell(
                          instrumentId: selectedId,
                          initialIsBuy: _isBuySelected.value,
                        ),
                        preventDuplicates: false,
                        transition: Transition.fadeIn,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          centerTitle: false,
          elevation: 0,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 960;
              final chartPanel = _buildChartPanel(
                symbol: instrument.symbol,
                currentPrice: currentPrice,
                highPrice: highPrice,
                lowPrice: lowPrice,
                candles: candles,
                quoteCurrency: quoteCurrency,
                scheme: scheme,
                isDark: isDark,
              );
              final ticketPanel = _buildTicketPanel(
                scheme: scheme,
                isDark: isDark,
                isFormLocked: _isSubmittingOrder.value,
                baseCurrency: baseCurrency,
                quoteCurrency: quoteCurrency,
                availableToSell: availableToSell,
                availableQuoteBalance: availableQuoteBalance,
                maxAffordableQty: maxAffordableQty,
                estimatedTotal: estimatedTotal,
                currentPrice: currentPrice,
                canSubmit: canSubmit,
                selectedExecutionPrice: selectedExecutionPrice,
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child:
                    isWide
                        ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: chartPanel),
                            const SizedBox(width: 14),
                            Expanded(flex: 2, child: ticketPanel),
                          ],
                        )
                        : Column(
                          children: [
                            chartPanel,
                            const SizedBox(height: 14),
                            ticketPanel,
                          ],
                        ),
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildChartPanel({
    required String symbol,
    required double currentPrice,
    required double highPrice,
    required double lowPrice,
    required List<LiveCandle> candles,
    required String quoteCurrency,
    required ColorScheme scheme,
    required bool isDark,
  }) {
    final cardColor =
        isDark
            ? scheme.surfaceContainerHighest.withValues(alpha: 0.45)
            : scheme.surfaceContainerLow;
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _priceStat(
                      'Mark Price',
                      '${currentPrice.toStringAsFixed(4)} $quoteCurrency',
                      scheme,
                    ),
                    _priceStat(
                      '24h High',
                      '${highPrice.toStringAsFixed(4)} $quoteCurrency',
                      scheme,
                    ),
                    _priceStat(
                      '24h Low',
                      '${lowPrice.toStringAsFixed(4)} $quoteCurrency',
                      scheme,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 320,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(18),
              ),
              child: _TrendChart(
                candles: candles,
                isDark: isDark,
                positiveColor: const Color(0xFF14B86E),
                negativeColor: const Color(0xFFEF4444),
                chartType: _ChartDisplayType.area,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketPanel({
    required ColorScheme scheme,
    required bool isDark,
    required bool isFormLocked,
    required String baseCurrency,
    required String quoteCurrency,
    required double availableToSell,
    required double availableQuoteBalance,
    required double maxAffordableQty,
    required double estimatedTotal,
    required double currentPrice,
    required bool canSubmit,
    required double selectedExecutionPrice,
  }) {
    final cardColor =
        isDark
            ? scheme.surfaceContainerHighest.withValues(alpha: 0.45)
            : scheme.surfaceContainerLow;
    final actionColor =
        _isBuySelected.value
            ? const Color(0xFF14B86E)
            : const Color(0xFFEF4444);

    return Stack(
      children: [
        AbsorbPointer(
          absorbing: isFormLocked,
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: isDark ? 0.5 : 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _sideButton(
                          isSelected: _isBuySelected.value,
                          title: 'Buy',
                          selectedColor: const Color(0xFF14B86E),
                          onTap:
                              isFormLocked
                                  ? null
                                  : () {
                                    _isBuySelected.value = true;
                                    _validateAmount();
                                  },
                        ),
                      ),
                      Expanded(
                        child: _sideButton(
                          isSelected: !_isBuySelected.value,
                          title: 'Sell',
                          selectedColor: const Color(0xFFEF4444),
                          onTap:
                              isFormLocked
                                  ? null
                                  : () {
                                    _isBuySelected.value = false;
                                    _validateAmount();
                                  },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Order type',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: isDark ? 0.5 : 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _sideButton(
                          isSelected: _orderType.value == _OrderType.market,
                          title: 'Market',
                          selectedColor: scheme.primary,
                          onTap:
                              isFormLocked
                                  ? null
                                  : () {
                                    _orderType.value = _OrderType.market;
                                    _limitPriceController.clear();
                                    _validateAmount();
                                  },
                        ),
                      ),
                      Expanded(
                        child: _sideButton(
                          isSelected: _orderType.value == _OrderType.limit,
                          title: 'Limit',
                          selectedColor: scheme.tertiary,
                          onTap:
                              isFormLocked
                                  ? null
                                  : () {
                                    _orderType.value = _OrderType.limit;
                                    if (_limitPriceController.text
                                            .trim()
                                            .isEmpty &&
                                        currentPrice > 0) {
                                      _limitPriceController.text = currentPrice
                                          .toStringAsFixed(4);
                                    }
                                    _validateAmount();
                                  },
                        ),
                      ),
                    ],
                  ),
                ),
                if (_orderType.value == _OrderType.limit) ...[
                  const SizedBox(height: 10),
                  TextBoxField(
                    objectName: _limitPriceController,
                    placeHolder: 'Enter limit price',
                    errorText: _limitPriceError.value,
                    isDisabled: isFormLocked,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    suffixText: quoteCurrency,
                    horizontalPadding: 0,
                    onChange: (_) => _validateAmount(),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  'Trade amount ($baseCurrency)',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextBoxField(
                  objectName: _amountController,
                  placeHolder: '0.00',
                  errorText: _amountError.value,
                  isDisabled: isFormLocked,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  suffixText: baseCurrency,
                  horizontalPadding: 0,
                  onChange: (_) => _validateAmount(),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      [25, 50, 75, 100].map((pct) {
                        final isLockedOnBuy = _isBuySelected.value;
                        return ActionChip(
                          avatar:
                              isLockedOnBuy
                                  ? Icon(
                                    Icons.lock_outline_rounded,
                                    size: 14,
                                    color: scheme.onSurfaceVariant,
                                  )
                                  : null,
                          label: Text('$pct%'),
                          onPressed:
                              isLockedOnBuy || isFormLocked
                                  ? null
                                  : () {
                                    final maxQty =
                                        _isBuySelected.value
                                            ? maxAffordableQty
                                            : availableToSell;
                                    final qty = maxQty * (pct / 100);
                                    _amountController.text =
                                        qty > 0 ? qty.toStringAsFixed(6) : '';
                                    _amountController
                                        .selection = TextSelection.fromPosition(
                                      TextPosition(
                                        offset: _amountController.text.length,
                                      ),
                                    );
                                  },
                        );
                      }).toList(),
                ),
                if (_isBuySelected.value) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Percentage shortcuts are locked on Buy mode.',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                _kvLine(
                  'Available to buy',
                  '${maxAffordableQty.toStringAsFixed(6)} $baseCurrency',
                  scheme,
                ),
                const SizedBox(height: 8),
                _kvLine(
                  'Available to sell',
                  '${availableToSell.toStringAsFixed(6)} $baseCurrency',
                  scheme,
                ),
                const SizedBox(height: 8),
                _kvLine(
                  'Quote balance',
                  '${availableQuoteBalance.toStringAsFixed(2)} $quoteCurrency',
                  scheme,
                ),
                const SizedBox(height: 8),
                _kvLine(
                  'Estimated total',
                  '${estimatedTotal.toStringAsFixed(2)} $quoteCurrency',
                  scheme,
                  valueColor: actionColor,
                ),
                const SizedBox(height: 8),
                _kvLine(
                  'Execution',
                  _orderType.value == _OrderType.market
                      ? 'Market @ live'
                      : 'Limit @ ${selectedExecutionPrice.toStringAsFixed(4)} $quoteCurrency',
                  scheme,
                ),
                const SizedBox(height: 16),
                Button(
                  purpose:
                      _isBuySelected.value
                          ? ButtonPurpose.primary
                          : ButtonPurpose.danger,
                  isLoading: _isSubmittingOrder.value,
                  label:
                      _isBuySelected.value
                          ? 'Buy $baseCurrency'
                          : 'Sell $baseCurrency',
                  onPress: () async {
                    if (!canSubmit) {
                      _validateAmount();
                      final parsedAmount =
                          double.tryParse(_amountController.text.trim()) ?? 0;
                      final reason =
                          _limitPriceError.value ??
                          _amountError.value ??
                          (parsedAmount <= 0
                              ? 'Enter an amount greater than 0'
                              : (_isSubmittingOrder.value
                                  ? 'Order is already submitting'
                                  : 'Please complete all required fields'));
                      SnackBarComp.show(
                        reason,
                        title: 'Cannot submit order',
                        status: SnackBarCompStatus.warning,
                      );
                      return;
                    }
                    await _submitOrder();
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  _isBuySelected.value
                      ? (_orderType.value == _OrderType.market
                          ? 'Executes instantly at the best available market price.'
                          : 'Limit buy executes only when market reaches your price.')
                      : 'Sell amount is capped by your available position quantity.',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                if (currentPrice <= 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Waiting for live market feed...',
                    style: TextStyle(
                      color: scheme.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: isFormLocked ? 1 : 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sideButton({
    required bool isSelected,
    required String title,
    required Color selectedColor,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color:
              isSelected
                  ? selectedColor.withValues(alpha: 0.18)
                  : Colors.transparent,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isSelected ? selectedColor : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _priceStat(String title, String value, ColorScheme scheme) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _kvLine(
    String key,
    String value,
    ColorScheme scheme, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          key,
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? scheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Future<void> _submitOrder() async {
    if (_isSubmittingOrder.value) return;
    _validateAmount();
    if (_amountError.value != null) {
      return;
    }

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) return;

    _isSubmittingOrder.value = true;
    try {
      await _marketController.callPlaceOrder(
        instrumentId,
        _isBuySelected.value ? 'buy' : 'sell',
        _orderType.value.name,
        amount,
        _orderType.value == _OrderType.limit
            ? double.tryParse(_limitPriceController.text.trim())
            : null,
        null,
        'manual',
      );

      _amountController.clear();
      _amountError.value = null;
      _limitPriceError.value = null;
      await _walletController.fetchWallet(withHistory: true);
      await _tradeController.fetchTrades();
      await _orderController.fetchOrders();
      await _portfolioController.fetchPortfolio();
    } catch (_) {
    } finally {
      _isSubmittingOrder.value = false;
    }
  }

  void _validateAmount() {
    final instrument = _instrumentController.getInstrumentById(instrumentId);
    final amount = double.tryParse(_amountController.text.trim());
    final position = _portfolioController.portfolio.firstWhereOrNull(
      (p) => p.instrumentId == instrumentId,
    );

    final availableToSell = position?.availableQuantity ?? 0.0;
    final chartController = Get.find<MarketChartController>(
      tag: instrument.symbol,
    );
    final currentPrice =
        chartController.lastPrice.value > 0
            ? chartController.lastPrice.value
            : (chartController.candles.isNotEmpty
                ? chartController.candles.last.close
                : 0.0);
    final selectedExecutionPrice =
        _orderType.value == _OrderType.limit
            ? (double.tryParse(_limitPriceController.text.trim()) ?? 0.0)
            : currentPrice;
    final maxAffordableQty =
        selectedExecutionPrice > 0
            ? _walletController.wallet.value.availableBalance /
                selectedExecutionPrice
            : 0.0;

    if (_amountController.text.trim().isEmpty) {
      _amountError.value = null;
      return;
    }
    if (amount == null) {
      _amountError.value = 'Enter a valid number';
      return;
    }
    if (amount <= 0) {
      _amountError.value = 'Amount must be greater than 0';
      return;
    }
    if (instrument.minQuantity != null && amount < instrument.minQuantity!) {
      _amountError.value = 'Minimum amount is ${instrument.minQuantity}';
      return;
    }
    if (_isBuySelected.value && amount > maxAffordableQty) {
      _amountError.value = 'Insufficient quote balance for this buy amount';
      return;
    }
    if (!_isBuySelected.value && amount > availableToSell) {
      _amountError.value =
          'Cannot sell more than ${availableToSell.toStringAsFixed(6)}';
      return;
    }
    if (_orderType.value == _OrderType.limit) {
      final limitPrice = double.tryParse(_limitPriceController.text.trim());
      if (limitPrice == null) {
        _limitPriceError.value = 'Enter a valid limit price';
        return;
      }
      if (limitPrice <= 0) {
        _limitPriceError.value = 'Limit price must be greater than 0';
        return;
      }
      _limitPriceError.value = null;
    } else {
      _limitPriceError.value = null;
    }
    _amountError.value = null;
  }

  String _extractBaseSymbol(String symbol) {
    final normalized = symbol.contains(':') ? symbol.split(':').last : symbol;
    if (normalized.contains('_')) {
      return normalized.split('_').first.toUpperCase();
    }
    if (normalized.endsWith('USDT')) {
      return normalized.substring(0, normalized.length - 4).toUpperCase();
    }
    if (normalized.endsWith('USD')) {
      return normalized.substring(0, normalized.length - 3).toUpperCase();
    }
    return normalized.toUpperCase();
  }

  String _extractQuoteSymbol(String symbol) {
    final normalized = symbol.contains(':') ? symbol.split(':').last : symbol;
    if (normalized.contains('_')) {
      return normalized.split('_').last.toUpperCase();
    }
    if (normalized.endsWith('USDT')) return 'USDT';
    if (normalized.endsWith('USD')) return 'USD';
    return 'USD';
  }
}

class _TrendChart extends StatelessWidget {
  final List<LiveCandle> candles;
  final bool isDark;
  final Color positiveColor;
  final Color negativeColor;
  final _ChartDisplayType chartType;

  const _TrendChart({
    required this.candles,
    required this.isDark,
    required this.positiveColor,
    required this.negativeColor,
    required this.chartType,
  });

  @override
  Widget build(BuildContext context) {
    final prices = candles.map((c) => c.close).toList(growable: false);
    final isUp = prices.length > 1 ? prices.last >= prices.first : true;
    final stroke = isUp ? positiveColor : negativeColor;
    final bg = isDark ? const Color(0xFF101722) : const Color(0xFFF6F8FC);

    return Container(
      color: bg,
      padding: const EdgeInsets.all(16),
      child:
          prices.length < 2
              ? Center(
                child: Text(
                  'Waiting for live market feed...',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              )
              : CustomPaint(
                painter: _TrendPainter(
                  values: prices,
                  strokeColor: stroke,
                  chartType: chartType,
                ),
                child: const SizedBox.expand(),
              ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<double> values;
  final Color strokeColor;
  final _ChartDisplayType chartType;

  const _TrendPainter({
    required this.values,
    required this.strokeColor,
    required this.chartType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final span = (maxValue - minValue).abs();

    final linePaint =
        Paint()
          ..color = strokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.3
          ..strokeCap = StrokeCap.round;

    final fillPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              strokeColor.withValues(alpha: 0.22),
              strokeColor.withValues(alpha: 0.01),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;
      final normalized =
          span <= 0.0000001 ? 0.5 : (values[i] - minValue) / span;
      final y =
          size.height - (normalized * size.height * 0.9 + size.height * 0.05);
      points.add(Offset(x, y));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    if (chartType == _ChartDisplayType.area) {
      final areaPath =
          Path.from(path)
            ..lineTo(size.width, size.height)
            ..lineTo(0, size.height)
            ..close();
      canvas.drawPath(areaPath, fillPaint);
      canvas.drawPath(path, linePaint);
      return;
    }

    if (chartType == _ChartDisplayType.line) {
      canvas.drawPath(path, linePaint);
      return;
    }

    if (chartType == _ChartDisplayType.bar) {
      final barPaint =
          Paint()
            ..color = strokeColor.withValues(alpha: 0.8)
            ..style = PaintingStyle.fill;
      final step = size.width / (values.length - 1);
      final barWidth = step.clamp(2, 12).toDouble();
      for (final point in points) {
        final rect = Rect.fromLTWH(
          point.dx - (barWidth / 2),
          point.dy,
          barWidth,
          size.height - point.dy,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(2)),
          barPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.chartType != chartType;
  }
}

enum _OrderType { market, limit }

enum _ChartDisplayType { area, line, bar }

List<InstrumentDTO> _instrumentsForDropdown(List<InstrumentDTO> all) {
  if (all.length <= 1) return all;
  final btcIndex = all.indexWhere(InstrumentController.matchesBitcoinInstrument);
  if (btcIndex <= 0) return all;
  final out = List<InstrumentDTO>.from(all);
  final btc = out.removeAt(btcIndex);
  return <InstrumentDTO>[btc, ...out];
}
