import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';
import 'package:voxtrade_core/pages/Home_page.dart';

import '../../assembler/Controller/NavBarController.dart';
import '../../pages/Markets.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final conroller = Get.put(NavBarController());

    return GetBuilder<NavBarController>(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(title: const Text('VoxTrade'), centerTitle: true),

          body: IndexedStack(
            index: conroller.tabIndex,
            children: [HomePage(), Markets()],
          ),
          bottomNavigationBar: BottomNavigationBar(
            selectedFontSize: 15,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            selectedItemColor: primaryColor,
            unselectedItemColor: Colors.grey.shade300,
            currentIndex: conroller.tabIndex,
            onTap: context.changeTabIndex,
            items: [
              _bottomNavItem(Icons.home, 'HOME'),
              _bottomNavItem(Icons.auto_graph, 'Markets'),
              _bottomNavItem(Icons.mic, 'Voice'),
              _bottomNavItem(Icons.account_balance, 'Trade'),
              _bottomNavItem(Icons.wallet, 'Assets'),
            ],
          ),
        );
      },
    );
  }
}

_bottomNavItem(IconData icon, String label) {
  return BottomNavigationBarItem(icon: Icon(icon), label: label);
}
