import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/Market/Chart.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/Components/common/Buttons/Button.dart';
import 'package:voxtrade_core/assembler/Controller/Instrument_Controller.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';
import 'package:voxtrade_core/pages/Market_Buy_Sell.dart';

class MarketBuySellEntryPage extends StatelessWidget {
  final int instrumentId;
  const MarketBuySellEntryPage({super.key, required this.instrumentId});

  @override
  Widget build(BuildContext context) {
    final instrumentController = Get.find<InstrumentController>();
    final instrument = instrumentController.getInstrumentById(instrumentId);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: LiveMarketChart(symbol: instrument.symbol),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Choose action to open advanced ticket',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Button(
                          purpose: ButtonPurpose.danger,
                          isLoading: false,
                          label: 'SELL',
                          onPress: () async {
                            try {
                              Get.to(
                                () => MarketBuySell(
                                  instrumentId: instrumentId,
                                  initialIsBuy: false,
                                ),
                                preventDuplicates: false,
                                transition: Transition.rightToLeft,
                              );
                            } catch (e) {
                              SnackBarComp.show(
                                e.toString(),
                                title: 'Navigation error',
                                status: SnackBarCompStatus.danger,
                              );
                            }
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
                            try {
                              Get.to(
                                () => MarketBuySell(
                                  instrumentId: instrumentId,
                                  initialIsBuy: true,
                                ),
                                preventDuplicates: false,
                                transition: Transition.rightToLeft,
                              );
                            } catch (e) {
                              SnackBarComp.show(
                                e.toString(),
                                title: 'Navigation error',
                                status: SnackBarCompStatus.danger,
                              );
                            }
                          },
                        ),
                      ),
                    ],
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
