import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:voxtrade_core/Components/common/News/SymbolSearchField.dart';
import 'package:voxtrade_core/assembler/Services/FinnHub_Services.dart';

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    RxString selectedValue = 'AAPL'.obs;
    RxString selectedSymbol = 'AAPL'.obs;

    return Obx(() {
      return Column(
        children: [
          Text(selectedValue.value),
          DropdownButtonFormField<String>(
            value: selectedValue.value,
            items: const [
              DropdownMenuItem(value: 'AAPL', child: Text('AAPL')),
              DropdownMenuItem(value: 'TSLA', child: Text('TSLA')),
              DropdownMenuItem(value: 'MSFT', child: Text('MSFT')),
            ],
            onChanged: (value) {
              if (value != null) {
                selectedValue.value = value;
              }
            },
            decoration: const InputDecoration(
              labelText: 'Symbol',
              border: OutlineInputBorder(),
            ),
          ),
          SymbolSearchField(
            fetchSymbols: (query) async {
              final results = await getSymbols(exchange: query);
              return results.map((e) => e.symbol).toList();
            },
            onSelected: (value) {
              selectedSymbol.value = value;
            },
          ),
        ],
      );
    });
  }
}
