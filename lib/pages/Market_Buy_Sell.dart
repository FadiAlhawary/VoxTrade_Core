import 'package:flutter/material.dart';
import 'package:voxtrade_core/Components/Market/Chart.dart';
import 'package:voxtrade_core/Components/common/Buttons/Button.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';

class MarketBuySell extends StatelessWidget {
  final String symbol;
  const MarketBuySell({super.key, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(flex: 3, child: LiveMarketChart(symbol: symbol)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Button(
                    purpose: ButtonPurpose.danger,
                    isLoading: false,
                    label: 'SELL',
                    onPress: () async {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Button(
                    purpose: ButtonPurpose.primary,
                    isLoading: false,
                    label: 'BUY',
                    onPress: () async {},
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
