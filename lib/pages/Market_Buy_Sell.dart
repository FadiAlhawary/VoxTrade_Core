import 'package:flutter/material.dart';
import 'package:voxtrade_core/Components/Market/Chart.dart';
import 'package:voxtrade_core/Components/common/Buttons/Button.dart';
import 'package:voxtrade_core/assembler/Controller/Instrument_Controller.dart';
import 'package:voxtrade_core/assembler/Controller/MarketController.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';
import 'package:get/get.dart';

class MarketBuySell extends StatelessWidget {
  final int instrumentId;
  const MarketBuySell({super.key, required this.instrumentId});

  @override
  Widget build(BuildContext context) {
    final instrumentController = Get.find<InstrumentController>();
    final marketController = Get.find<MarketController>();
    final instrument = instrumentController.getInstrumentById(instrumentId);
    return Scaffold(
      body: Column(
        children: [
          Expanded(flex: 3, child: LiveMarketChart(symbol: instrument.symbol)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Button(
                    purpose: ButtonPurpose.danger,
                    isLoading: false,
                    label: 'SELL',
                    onPress: () async {
                      marketController.callPlaceOrder(
                        instrumentId,
                        'sell',
                        'market',
                        1,
                        0,
                        null,
                        'manual',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Button(
                    purpose: ButtonPurpose.primary,
                    isLoading: false,
                    label: 'BUY',
                    onPress: () async {
                      marketController.callPlaceOrder(
                        instrumentId,
                        'buy',
                        'market',
                        1,
                        0,
                        null,
                        'manual',
                      );
                    },
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
