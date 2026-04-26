import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/assembler/Controller/ThemeController.dart';
import 'package:voxtrade_core/assembler/Controller/User_&_Auth/User_Controller.dart';

class UserInfoPage extends StatelessWidget {
  const UserInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(title: const Text('User Info')),
      body: Obx(() {
        final user = userController.user.value;
        final isDark = themeController.isDarkMode.value;
        final scheme = Theme.of(context).colorScheme;
        final borderColor =
            isDark ? const Color(0xff273443) : scheme.outlineVariant;

        if (user == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_off_outlined,
                    size: 44,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No user data available',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: userController.fetchUserProfileData,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            ),
          );
        }

        final fullName = '${user.firstNameEn} ${user.lastNameEn}'.trim();

        return RefreshIndicator(
          onRefresh: userController.fetchUserProfileData,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;
              final horizontalPadding = isWide ? 24.0 : 16.0;
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  24,
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            isDark
                                ? const [Color(0xff0f1a28), Color(0xff17283d)]
                                : [scheme.primaryContainer, scheme.tertiaryContainer],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: borderColor),
                      boxShadow:
                          isDark
                              ? const [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.22),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ]
                              : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ACCOUNT CENTER',
                                style: TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      isDark
                                          ? Colors.cyanAccent
                                          : scheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                fullName.isEmpty ? 'Unknown User' : fullName,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color:
                                      isDark
                                          ? Colors.white
                                          : scheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.primaryEmail,
                                style: TextStyle(
                                  color:
                                      isDark
                                          ? Colors.white70
                                          : scheme.onPrimaryContainer.withValues(
                                            alpha: 0.85,
                                          ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _TagChip(
                                    label: '@${user.username}',
                                    isDark: isDark,
                                  ),
                                  _TagChip(
                                    label:
                                        user.isPrimaryEmailActive
                                            ? 'Email Verified'
                                            : 'Email Pending',
                                    isDark: isDark,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: userController.fetchUserProfileData,
                          icon: const Icon(Icons.refresh_rounded),
                          tooltip: 'Refresh profile',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  isWide
                      ? Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              title: 'Username',
                              value: user.username,
                              icon: Icons.alternate_email_rounded,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _InfoCard(
                              title: 'Date of Birth',
                              value: _formatDate(user.dob),
                              icon: Icons.cake_outlined,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      )
                      : Column(
                        children: [
                          _InfoCard(
                            title: 'Username',
                            value: user.username,
                            icon: Icons.alternate_email_rounded,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 10),
                          _InfoCard(
                            title: 'Date of Birth',
                            value: _formatDate(user.dob),
                            icon: Icons.cake_outlined,
                            isDark: isDark,
                          ),
                        ],
                      ),
                  const SizedBox(height: 10),
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ActionCard(
                    title: 'Forgot Password',
                    subtitle: 'Recover account access safely',
                    icon: Icons.lock_reset_outlined,
                    accentColor: Colors.orangeAccent,
                    isDark: isDark,
                    onTap: () {
                      Get.snackbar(
                        'Forgot Password',
                        'Password recovery flow will be connected here.',
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _ActionCard(
                    title: 'Change Password',
                    subtitle: 'Update your account password',
                    icon: Icons.password_rounded,
                    accentColor: Colors.cyanAccent,
                    isDark: isDark,
                    onTap: () {
                      Get.snackbar(
                        'Change Password',
                        'Change password screen will be connected here.',
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _ActionCard(
                    title: 'Logout',
                    subtitle: 'Sign out from this account',
                    icon: Icons.logout_rounded,
                    accentColor: Colors.redAccent,
                    isDark: isDark,
                    onTap: userController.logoutFunction,
                  ),
                  const SizedBox(height: 10),
                  _InfoCard(
                    title: 'Primary Phone',
                    value: user.primaryPhoneNumber,
                    icon: Icons.phone_outlined,
                    statusLabel:
                        user.isPrimaryPhoneNumberActive ? 'Verified' : 'Pending',
                    isActive: user.isPrimaryPhoneNumberActive,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _InfoCard(
                    title: 'Primary Email',
                    value: user.primaryEmail,
                    icon: Icons.mail_outline_rounded,
                    statusLabel:
                        user.isPrimaryEmailActive ? 'Verified' : 'Pending',
                    isActive: user.isPrimaryEmailActive,
                    isDark: isDark,
                  ),
                  if ((user.altEmail ?? '').isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _InfoCard(
                      title: 'Alt Email',
                      value: user.altEmail!,
                      icon: Icons.forward_to_inbox_outlined,
                      statusLabel:
                          user.isAltEmailActive ? 'Verified' : 'Pending',
                      isActive: user.isAltEmailActive,
                      isDark: isDark,
                    ),
                  ],
                  if ((user.altPhoneNumber ?? '').isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _InfoCard(
                      title: 'Alt Phone',
                      value: user.altPhoneNumber!,
                      icon: Icons.phone_in_talk_outlined,
                      statusLabel:
                          user.isAltPhoneNumberActive ? 'Verified' : 'Pending',
                      isActive: user.isAltPhoneNumberActive,
                      isDark: isDark,
                    ),
                  ],
                ],
              );
            },
          ),
        );
      }),
    );
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.isDark,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xff111821) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accentColor.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.isDark});

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color:
            isDark
                ? const Color(0xff223348).withValues(alpha: 0.72)
                : Colors.white.withValues(alpha: 0.46),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.isDark,
    this.statusLabel,
    this.isActive = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final bool isDark;
  final String? statusLabel;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cardColor =
        isDark ? const Color(0xff111821) : scheme.surfaceContainerLow;
    final borderColor = isDark ? const Color(0xff273443) : scheme.outlineVariant;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor.withValues(alpha: 0.85)),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? 'Not set' : value,
                  style: TextStyle(
                    fontSize: 14,
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (statusLabel != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    (isActive ? Colors.green : Colors.orange).withValues(
                      alpha: isDark ? 0.2 : 0.14,
                    ),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                statusLabel!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.greenAccent : Colors.orangeAccent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
