import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hybrid_digital_docs_assignment_frontend/core/auth/auth_provider.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/providers/user_profile_provider.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_card.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/skeleton.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildUserHeader(context, ref),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Account'),
            _buildSettingsGroup(context, [
              _buildSettingItem(
                context,
                icon: HeroIcons.user,
                title: 'My Profile',
                subtitle: 'Personal information and avatar',
                onTap: () {},
              ),
              _buildSettingItem(
                context,
                icon: HeroIcons.lockClosed,
                title: 'Security',
                subtitle: 'Password and authentication',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Organization'),
            _buildSettingsGroup(context, [
              _buildSettingItem(
                context,
                icon: HeroIcons.users,
                title: 'User Management',
                subtitle: 'Manage staff and permissions',
                onTap: () => context.push('/users'),
              ),
              _buildSettingItem(
                context,
                icon: HeroIcons.shieldCheck,
                title: 'Roles & Permissions',
                subtitle: 'Configure access levels',
                onTap: () => context.push('/roles'),
              ),
              _buildSettingItem(
                context,
                icon: HeroIcons.key,
                title: 'Document Configuration',
                subtitle: 'Manage prefixes and categories',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'App Preferences'),
            _buildSettingsGroup(context, [
              _buildSettingItem(
                context,
                icon: HeroIcons.swatch,
                title: 'Appearance',
                subtitle: 'Theme, colors, and styling',
                onTap: () => context.push('/appearance'),
              ),
              _buildSettingItem(
                context,
                icon: HeroIcons.language,
                title: 'Language',
                subtitle: 'English, Khmer, etc.',
                onTap: () => context.push('/language'),
              ),
              _buildSettingItem(
                context,
                icon: HeroIcons.informationCircle,
                title: 'About',
                subtitle: 'App version and info',
                onTap: () => context.push('/about'),
              ),
            ]),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                },
                icon: const HeroIcon(HeroIcons.arrowRightOnRectangle, size: 18),
                label: const Text('Log Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userProfileAsync = ref.watch(userProfileProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomCard(
        child: userProfileAsync.when(
          data: (user) => Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                backgroundImage: user.image != null && user.image!.isNotEmpty 
                    ? NetworkImage(user.image!) 
                    : null,
                child: user.image == null || user.image!.isEmpty
                    ? Text(
                        _getInitials(user.fullName),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user.email ?? 'No Email',
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const HeroIcon(HeroIcons.pencilSquare, size: 20),
                onPressed: () {},
              ),
            ],
          ),
          loading: () => Row(
            children: [
              const Skeleton(width: 60, height: 60, borderRadius: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Skeleton(width: 150, height: 18, margin: EdgeInsets.only(bottom: 8)),
                    Skeleton(width: 100, height: 14),
                  ],
                ),
              ),
              const Skeleton(width: 20, height: 20, borderRadius: 4),
            ],
          ),
          error: (_, __) => Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: theme.colorScheme.error.withValues(alpha: 0.1),
                child: HeroIcon(
                  HeroIcons.user,
                  size: 24,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Error Loading Profile',
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '??';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.black.withValues(alpha: 0.3) 
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: children.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
          itemBuilder: (context, index) => children[index],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required HeroIcons icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: HeroIcon(icon, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall,
      ),
      onTap: onTap,
    );
  }
}
