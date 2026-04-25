import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/Market/MarketViewrCard.dart';
import 'package:voxtrade_core/assembler/Controller/Instrument_Controller.dart';

class Markets extends StatelessWidget {
  const Markets({super.key});

  @override
  Widget build(BuildContext context) {
    final instrumentController = Get.find<InstrumentController>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SizedBox(
        width: double.infinity,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: instrumentController.instruments.length,
          separatorBuilder: (_, __) => const MarketListDivider(),
          itemBuilder: (_, index) {
            return MarketChartTile(
              instrument: instrumentController.instruments[index],
              index: index,
            );
          },
        ),
      ),
    );
  }
}
