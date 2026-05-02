import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/assembler/Controller/Instrument_Controller.dart';
import 'package:voxtrade_core/assembler/Controller/ThemeController.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';
import 'package:voxtrade_core/pages/DashBoard_page.dart';
import 'package:voxtrade_core/pages/Home_page.dart';
import 'package:voxtrade_core/pages/Market_Buy_Sell.dart';
import 'package:voxtrade_core/pages/Wallet.dart';
import 'package:voxtrade_core/pages/Portfolio_Page.dart';
import 'package:voxtrade_core/pages/User_Info_Page.dart';
import 'package:voxtrade_core/pages/Voice_Trading_Page.dart';

import '../../assembler/Controller/NavBarController.dart';
import '../../pages/Markets.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final conroller = Get.put(NavBarController());
    final themeController = Get.find<ThemeController>();
    final drawerRoutes = <_DrawerRouteItem>[
      _DrawerRouteItem(
        title: 'DashBoard',
        subtitle: 'Dashboard',
        icon: Icons.dashboard_customize_rounded,
        pageBuilder: () => const DashBoardPage(),
      ),
      _DrawerRouteItem(
        title: 'User Info',
        subtitle: 'Profile and account details',
        icon: Icons.person_rounded,
        pageBuilder: () => const UserInfoPage(),
      ),
      _DrawerRouteItem(
        title: 'Home',
        subtitle: 'Back to dashboard',
        icon: Icons.home_rounded,
        pageBuilder: () => HomePage(),
      ),
      _DrawerRouteItem(
        title: 'Markets',
        subtitle: 'View live market moves',
        icon: Icons.auto_graph_rounded,
        pageBuilder: () => Markets(),
      ),
      _DrawerRouteItem(
        title: 'Trade',
        subtitle: 'Advanced ticket with market selector',
        icon: Icons.candlestick_chart_rounded,
        onTap: () async {
          final instrumentController = Get.find<InstrumentController>();
          if (instrumentController.instruments.isEmpty) {
            await instrumentController.fetchInstruments();
          }

          if (instrumentController.instruments.isEmpty) {
            SnackBarComp.show('No markets available right now');
            return;
          }

          final defaultId =
              instrumentController.resolveDefaultTradeInstrumentId();
          Get.to(
            () => MarketBuySell(instrumentId: defaultId),
            preventDuplicates: false,
            transition: Transition.rightToLeft,
          );
        },
      ),
      _DrawerRouteItem(
        title: 'Wallet',
        subtitle: 'Manage your balance',
        icon: Icons.account_balance_wallet_rounded,
        pageBuilder: () => WalletPage(),
      ),
      _DrawerRouteItem(
        title: 'More pages soon',
        subtitle: 'You can plug new ideas here',
        icon: Icons.lightbulb_outline_rounded,
        onTap: () => SnackBarComp.show('Add your next page in drawerRoutes'),
      ),
    ];

    return GetBuilder<NavBarController>(
      builder: (_) {
        return Obx(() {
          final isDarkMode = themeController.isDarkMode.value;
          final scheme = Theme.of(context).colorScheme;
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
                        ? Icons.light_mode
                        : Icons.dark_mode,
                  ),
                ),
              ],
            ),
            drawer: Drawer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors:
                        isDarkMode
                            ? const [Color(0xFF071526), Color(0xFF10243A)]
                            : const [Color(0xFFF6FAFF), Color(0xFFEAF2FF)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                        decoration: BoxDecoration(
                          color:
                              isDarkMode
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.white.withValues(alpha: 0.85),
                          border: Border(
                            bottom: BorderSide(
                              color: primaryColor.withValues(alpha: 0.18),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.dashboard_customize_rounded,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Navigation',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          isDarkMode
                                              ? Colors.white
                                              : scheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    'Your pages at ease',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          isDarkMode
                                              ? Colors.white70
                                              : scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                          itemCount: drawerRoutes.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, index) {
                            final item = drawerRoutes[index];
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Get.back();
                                  if (item.onTap != null) {
                                    item.onTap!.call();
                                    return;
                                  }
                                  if (item.pageBuilder != null) {
                                    Get.to(item.pageBuilder!);
                                  }
                                },
                                child: Ink(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color:
                                        isDarkMode
                                            ? Colors.white.withValues(
                                              alpha: 0.08,
                                            )
                                            : Colors.white.withValues(
                                              alpha: 0.88,
                                            ),
                                    border: Border.all(
                                      color: primaryColor.withValues(
                                        alpha: 0.14,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: primaryColor.withValues(
                                            alpha: 0.14,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          item.icon,
                                          color: primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.title,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    isDarkMode
                                                        ? Colors.white
                                                        : scheme.onSurface,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              item.subtitle,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    isDarkMode
                                                        ? Colors.white70
                                                        : scheme
                                                            .onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 15,
                                        color:
                                            isDarkMode
                                                ? Colors.white70
                                                : scheme.onSurfaceVariant,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            body: IndexedStack(
              index: conroller.tabIndex,
              children: [
                PortfolioPage(),

                Markets(),
                const SizedBox(),
                HomePage(),
                WalletPage(),
              ],
            ),
            bottomNavigationBar: _BottomTradeNav(
              currentIndex: conroller.tabIndex,
              isDarkMode: isDarkMode,
              onTabTap: conroller.changeTabIndex,
              onCenterTap: () {
                Get.to(
                  () => const VoiceTradingPage(),
                  preventDuplicates: false,
                  transition: Transition.downToUp,
                );
              },
            ),
          );
        });
      },
    );
  }
}

class _DrawerRouteItem {
  const _DrawerRouteItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.pageBuilder,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget Function()? pageBuilder;
  final FutureOr<void> Function()? onTap;
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
                      icon: Icons.folder_rounded,
                      label: 'Portfolio',
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
                      icon: Icons.home_outlined,
                      label: 'Home',
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
