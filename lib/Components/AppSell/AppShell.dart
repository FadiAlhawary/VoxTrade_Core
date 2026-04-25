import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/assembler/Controller/ThemeController.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';
import 'package:voxtrade_core/pages/Home_page.dart';
import 'package:voxtrade_core/pages/Wallet.dart';
import 'package:voxtrade_core/pages/Trade_Page.dart';

import '../../assembler/Controller/NavBarController.dart';
import '../../pages/Markets.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final conroller = Get.put(NavBarController());
    final themeController = Get.find<ThemeController>();

    return GetBuilder<NavBarController>(
      builder: (context) {
        return Obx(() {
          return Scaffold(
            appBar: AppBar(
              title: const Text('VoxTrade'),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () {
                    themeController.changeTheme(
                      !themeController.isDarkMode.value,
                    );
                  },
                  icon: Icon(
                    themeController.isDarkMode.value
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                ),
              ],
            ),
            drawer: Drawer(
              child: Column(children: [SizedBox(height: 40), Text('Theme')]),
            ),

            body: IndexedStack(
              index: conroller.tabIndex,
              children: [
                HomePage(),
                Markets(),
                const SizedBox(),
                TradePage(),
                WalletPage(),
              ],
            ),
            bottomNavigationBar: _BottomTradeNav(
              currentIndex: conroller.tabIndex,
              isDarkMode: themeController.isDarkMode.value,
              onTabTap: conroller.changeTabIndex,
              onCenterTap: () {
                SnackBarComp.show('Voice action tapped');
              },
            ),
          );
        });
      },
    );
  }
}

class _BottomTradeNav extends StatelessWidget {
  const _BottomTradeNav({
    required this.currentIndex,
    required this.isDarkMode,
    required this.onTabTap,
    required this.onCenterTap,
  });

  final int currentIndex;
  final bool isDarkMode;
  final ValueChanged<int> onTabTap;
  final VoidCallback onCenterTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = isDarkMode ? const Color(0xFF061527) : Colors.white;
    final inactive =
        isDarkMode ? const Color(0xFF9AA5B5) : const Color(0xFF7C8797);
    final selected = primaryColor;
    final centerLabelColor = isDarkMode ? Colors.white : scheme.onSurface;
    final shadowColor =
        isDarkMode
            ? Colors.black.withValues(alpha: 0.22)
            : Colors.black.withValues(alpha: 0.08);

    return SafeArea(
      top: false,
      child: SizedBox(
        height: 84,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: bg,
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _NavItem(
                      icon: Icons.home_outlined,
                      label: 'Home',
                      isSelected: currentIndex == 0,
                      selectedColor: selected,
                      unselectedColor: inactive,
                      onTap: () => onTabTap(0),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.auto_graph_rounded,
                      label: 'Markets',
                      isSelected: currentIndex == 1,
                      selectedColor: selected,
                      unselectedColor: inactive,
                      onTap: () => onTabTap(1),
                    ),
                  ),
                  const SizedBox(width: 72),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Trade',
                      isSelected: currentIndex == 3,
                      selectedColor: selected,
                      unselectedColor: inactive,
                      onTap: () => onTabTap(3),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Assets',
                      isSelected: currentIndex == 4,
                      selectedColor: selected,
                      unselectedColor: inactive,
                      onTap: () => onTabTap(4),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -2,
              child: GestureDetector(
                onTap: onCenterTap,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected,
                        boxShadow: [
                          BoxShadow(
                            color: selected.withValues(alpha: 0.55),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Voice',
                      style: TextStyle(
                        color: centerLabelColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? selectedColor : unselectedColor;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 21, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
