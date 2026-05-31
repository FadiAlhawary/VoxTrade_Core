import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/ModelDto/AdminDtos.dart';
import 'package:voxtrade_core/assembler/Controller/Admin_Controller.dart';
import 'package:voxtrade_core/Components/shimer/page_loading_shimmers.dart';
import 'package:voxtrade_core/pages/admin/admin_page_scaffold.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  late final AdminController _admin;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _admin = Get.isRegistered<AdminController>()
        ? Get.find<AdminController>()
        : Get.put(AdminController());
    _admin.loadUsers();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AdminUserDto> _filteredUsers() {
    return _admin.users
        .where((user) => user.matchesSearch(_searchQuery))
        .toList();
  }

  Future<void> _confirmLock(AdminUserDto user) async {
    final reasonController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Lock ${user.username}?'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason (optional)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Lock'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await _admin.lockUser(user.id, reason: reasonController.text.trim());
    }
    reasonController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AdminPageScaffold(
      title: 'Users',
      body: Obx(() {
        if (_admin.isLoadingUsers.value && _admin.users.isEmpty) {
          return const ListCardsPageShimmer();
        }

        final filtered = _filteredUsers();
        final hasQuery = _searchQuery.trim().isNotEmpty;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search name, username, role, or ID',
                  prefixIcon: Icon(Icons.search, color: scheme.primary),
                  suffixIcon:
                      hasQuery
                          ? IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                            },
                            icon: const Icon(Icons.clear),
                          )
                          : null,
                  filled: true,
                  fillColor:
                      isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: scheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: scheme.primary.withValues(alpha: 0.18),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: scheme.primary, width: 1.5),
                  ),
                ),
              ),
            ),
            if (hasQuery)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${filtered.length} of ${_admin.users.length} users',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _admin.loadUsers,
                child:
                    filtered.isEmpty
                        ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(24),
                          children: [
                            Icon(
                              hasQuery
                                  ? Icons.person_search_outlined
                                  : Icons.people_outline,
                              size: 48,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              hasQuery
                                  ? 'No users match "${_searchQuery.trim()}"'
                                  : 'No users found',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:
                                    isDark
                                        ? Colors.white70
                                        : scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        )
                        : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final user = filtered[index];
                            return _UserTile(
                              user: user,
                              isBusy: _admin.isMutating.value,
                              onLock: () => _confirmLock(user),
                              onUnlock: () => _admin.unlockUser(user.id),
                              onRestore: () => _admin.restoreUser(user.id),
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
}

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.isBusy,
    required this.onLock,
    required this.onUnlock,
    required this.onRestore,
  });

  final AdminUserDto user;
  final bool isBusy;
  final VoidCallback onLock;
  final VoidCallback onUnlock;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    user.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                if (user.isLocked)
                  Chip(
                    label: const Text('Locked'),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: scheme.errorContainer,
                  ),
                if (user.isDeleted)
                  Chip(
                    label: const Text('Deleted'),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            Text('@${user.username} · ${user.roleName} · ID ${user.id}'),
            if (user.lockReason != null && user.lockReason!.isNotEmpty)
              Text(
                'Reason: ${user.lockReason}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (!user.isLocked && !user.isDeleted)
                  TextButton.icon(
                    onPressed: isBusy ? null : onLock,
                    icon: const Icon(Icons.lock_outline, size: 18),
                    label: const Text('Lock'),
                  ),
                if (user.isLocked)
                  TextButton.icon(
                    onPressed: isBusy ? null : onUnlock,
                    icon: const Icon(Icons.lock_open_outlined, size: 18),
                    label: const Text('Unlock'),
                  ),
                if (user.isDeleted)
                  TextButton.icon(
                    onPressed: isBusy ? null : onRestore,
                    icon: const Icon(Icons.restore, size: 18),
                    label: const Text('Restore'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
