import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/ModelDto/AdminDtos.dart';
import 'package:voxtrade_core/assembler/Controller/Admin_Controller.dart';
import 'package:voxtrade_core/Components/shimer/page_loading_shimmers.dart';
import 'package:voxtrade_core/pages/admin/admin_page_scaffold.dart';

class AdminWalletsPage extends StatefulWidget {
  const AdminWalletsPage({super.key});

  @override
  State<AdminWalletsPage> createState() => _AdminWalletsPageState();
}

class _AdminWalletsPageState extends State<AdminWalletsPage> {
  late final AdminController _admin;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _admin = Get.isRegistered<AdminController>()
        ? Get.find<AdminController>()
        : Get.put(AdminController());
    _admin.loadWallets();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AdminWalletDto> _filteredWallets() {
    return _admin.wallets
        .where((w) => w.matchesSearch(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AdminPageScaffold(
      title: 'Wallets',
      body: Obx(() {
        if (_admin.isLoadingWallets.value && _admin.wallets.isEmpty) {
          return const ListCardsPageShimmer();
        }

        final filtered = _filteredWallets();
        final hasQuery = _searchQuery.trim().isNotEmpty;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search username, user ID, or currency',
                  prefixIcon: Icon(Icons.search, color: scheme.primary),
                  suffixIcon:
                      hasQuery
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _searchController.clear(),
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  isDense: true,
                ),
              ),
            ),
            if (hasQuery)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${filtered.length} of ${_admin.wallets.length} wallets',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _admin.loadWallets,
                child:
                    filtered.isEmpty
                        ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.sizeOf(context).height * 0.25,
                            ),
                            Center(
                              child: Text(
                                hasQuery
                                    ? 'No wallets match your search'
                                    : 'No wallets found',
                                style: TextStyle(color: scheme.onSurfaceVariant),
                              ),
                            ),
                          ],
                        )
                        : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final w = filtered[index];
                            return Card(
                              elevation: 0,
                              child: ListTile(
                                title: Text(w.username),
                                subtitle: Text(
                                  'ID ${w.userId} · ${w.currencySymbol} · '
                                  'Bal ${w.balance.toStringAsFixed(2)} · '
                                  'Avail ${w.availableBalance.toStringAsFixed(2)}',
                                ),
                                trailing: Chip(
                                  label: Text(w.isFrozen ? 'Frozen' : 'Active'),
                                  visualDensity: VisualDensity.compact,
                                  backgroundColor:
                                      w.isFrozen
                                          ? scheme.errorContainer
                                          : null,
                                ),
                                onTap:
                                    () => _showWalletActions(w.userId, w.isFrozen),
                              ),
                            );
                          },
                        ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showWalletActions(int userId, bool isFrozen) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.ac_unit),
              title: Text(isFrozen ? 'Unfreeze wallet' : 'Freeze wallet'),
              onTap: () async {
                Navigator.pop(ctx);
                if (isFrozen) {
                  await _admin.unfreezeWallet(userId);
                } else {
                  await _admin.freezeWallet(userId);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
