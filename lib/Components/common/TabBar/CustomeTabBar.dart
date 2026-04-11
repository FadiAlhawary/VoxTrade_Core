import 'package:flutter/material.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({super.key, required this.tabs});
  final List<Tab> tabs;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        dividerColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        labelColor: primaryColor,
        unselectedLabelColor: Colors.grey,

        tabs: tabs,
      ),
    );
  }
}
