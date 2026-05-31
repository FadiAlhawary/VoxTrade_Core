import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/assembler/Controller/Admin_Controller.dart';
import 'package:voxtrade_core/Components/shimer/page_loading_shimmers.dart';
import 'package:voxtrade_core/pages/admin/admin_page_scaffold.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  late final AdminController _admin;

  @override
  void initState() {
    super.initState();
    _admin = Get.isRegistered<AdminController>()
        ? Get.find<AdminController>()
        : Get.put(AdminController());
    _admin.loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageScaffold(
      title: 'Orders',
      body: Obx(() {
        if (_admin.isLoadingOrders.value && _admin.orders.isEmpty) {
          return const ListCardsPageShimmer();
        }
        return RefreshIndicator(
          onRefresh: _admin.loadOrders,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _admin.orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final o = _admin.orders[index];
              final canCancel = o.status.toLowerCase() == 'pending';
              return Card(
                elevation: 0,
                child: ListTile(
                  title: Text('#${o.id} ${o.symbol} ${o.side}'),
                  subtitle: Text(
                    '${o.username} · ${o.status} · qty ${o.quantity}',
                  ),
                  trailing:
                      canCancel
                          ? TextButton(
                            onPressed:
                                _admin.isMutating.value
                                    ? null
                                    : () => _admin.cancelOrder(o.id),
                            child: const Text('Cancel'),
                          )
                          : null,
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
