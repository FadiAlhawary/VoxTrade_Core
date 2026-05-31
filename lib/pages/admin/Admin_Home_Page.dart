import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/pages/Admin_Add_Funds_Page.dart';
import 'package:voxtrade_core/pages/admin/Admin_Audit_Logs_Page.dart';
import 'package:voxtrade_core/pages/admin/Admin_Dashboard_Page.dart';
import 'package:voxtrade_core/pages/admin/Admin_Orders_Page.dart';
import 'package:voxtrade_core/pages/admin/Admin_Users_Page.dart';
import 'package:voxtrade_core/pages/admin/Admin_Wallets_Page.dart';
import 'package:voxtrade_core/pages/admin/admin_page_scaffold.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_AdminNavItem>[
      _AdminNavItem(
        title: 'Dashboard',
        subtitle: 'Platform KPIs',
        icon: Icons.dashboard_outlined,
        page: const AdminDashboardPage(),
      ),
      _AdminNavItem(
        title: 'Users',
        subtitle: 'Lock, unlock, restore',
        icon: Icons.people_outline,
        page: const AdminUsersPage(),
      ),
      _AdminNavItem(
        title: 'Wallets',
        subtitle: 'Balances and freeze',
        icon: Icons.account_balance_wallet_outlined,
        page: const AdminWalletsPage(),
      ),
      _AdminNavItem(
        title: 'Add funds',
        subtitle: 'Credit user wallet',
        icon: Icons.add_card_outlined,
        page: const AdminAddFundsPage(),
      ),
      _AdminNavItem(
        title: 'Orders',
        subtitle: 'Monitor and cancel',
        icon: Icons.receipt_long_outlined,
        page: const AdminOrdersPage(),
      ),
      _AdminNavItem(
        title: 'Audit logs',
        subtitle: 'Latest admin activity',
        icon: Icons.history,
        page: const AdminAuditLogsPage(),
      ),
    ];

    return AdminPageScaffold(
      title: 'Admin',
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            elevation: 0,
            child: ListTile(
              leading: Icon(item.icon),
              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(item.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.to(() => item.page),
            ),
          );
        },
      ),
    );
  }
}

class _AdminNavItem {
  const _AdminNavItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.page,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget page;
}
