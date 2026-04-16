import 'package:flutter/material.dart';
import 'package:voxtrade_core/Components/Market/MarketViewrCard.dart';

class Markets extends StatelessWidget {
  const Markets({super.key});

  @override
  Widget build(BuildContext context) {
    // final symbols = [
    //   "BINANCE:BTCUSDT",
    //   "BINANCE:ETHUSDT",
    //   "BINANCE:SOLUSDT",
    //   "BINANCE:XRPUSDT",
    //   'AAPL',
    //   'MSFT',
    //   "BINANCE:XRPUSDT",
    //   "BINANCE:ADAUSDT",
    //   "OANDA:EUR_USD",
    //   "OANDA:GBP_USD",
    //   "OANDA:USD_JPY",
    //   "OANDA:XAU_USD",
    // ];
    final symbols = [
      "BINANCE:BTCUSDT",
      "BINANCE:ETHUSDT",
      "BINANCE:SOLUSDT",
      "BINANCE:XRPUSDT",
      'AAPL',
      'MSFT',
      "BINANCE:XRPUSDT",
      "BINANCE:ADAUSDT",
      "OANDA:EUR_USD",
      "OANDA:GBP_USD",
      "OANDA:USD_JPY",
      "OANDA:XAU_USD",
    ];
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SizedBox(
        width: double.infinity,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: symbols.length,
          separatorBuilder: (_, __) => const MarketListDivider(),
          itemBuilder: (_, index) {
            return MarketChartTile(symbol: symbols[index], index: index);
          },
        ),
      ),
    );
  }
}
