import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/assembler/Controller/Admin_Controller.dart';
import 'package:voxtrade_core/Components/shimer/page_loading_shimmers.dart';
import 'package:voxtrade_core/pages/admin/admin_page_scaffold.dart';

class AdminAuditLogsPage extends StatefulWidget {
  const AdminAuditLogsPage({super.key});

  @override
  State<AdminAuditLogsPage> createState() => _AdminAuditLogsPageState();
}

class _AdminAuditLogsPageState extends State<AdminAuditLogsPage> {
  late final AdminController _admin;

  @override
  void initState() {
    super.initState();
    _admin = Get.isRegistered<AdminController>()
        ? Get.find<AdminController>()
        : Get.put(AdminController());
    _admin.loadAuditLogs();
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageScaffold(
      title: 'Audit logs',
      body: Obx(() {
        if (_admin.isLoadingAudit.value && _admin.auditLogs.isEmpty) {
          return const ListCardsPageShimmer();
        }
        return RefreshIndicator(
          onRefresh: _admin.loadAuditLogs,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _admin.auditLogs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final log = _admin.auditLogs[index];
              return Card(
                elevation: 0,
                child: ListTile(
                  title: Text('${log.actionCode} · ${log.entity}'),
                  subtitle: Text(
                    '${log.username ?? '—'} · ${log.description ?? ''}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    log.createdAt?.toLocal().toString().split('.').first ?? '',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
