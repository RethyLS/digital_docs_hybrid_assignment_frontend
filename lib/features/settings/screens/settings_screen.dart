import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hybrid_digital_docs_assignment_frontend/core/auth/auth_provider.dart';
import 'package:hybrid_digital_docs_assignment_frontend/core/utils/image_utils.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/providers/user_profile_provider.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_card.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/skeleton.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings.title'.tr()),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildUserHeader(context, ref),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'settings.account'.tr()),
            _buildSettingsGroup(context, [
              _buildSettingItem(
                context,
                icon: HeroIcons.user,
                title: 'settings.my_profile'.tr(),
                subtitle: 'settings.my_profile_sub'.tr(),
                onTap: () => context.push('/profile'),
              ),
              _buildSettingItem(
                context,
                icon: HeroIcons.lockClosed,
                title: 'settings.security'.tr(),
                subtitle: 'settings.security_sub'.tr(),
                onTap: () => context.push('/security'),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'settings.organization'.tr()),
            _buildSettingsGroup(context, [
              _buildSettingItem(
                context,
                icon: HeroIcons.users,
                title: 'settings.user_management'.tr(),
                subtitle: 'settings.user_management_sub'.tr(),
                onTap: () => context.push('/users'),
              ),
              _buildSettingItem(
                context,
                icon: HeroIcons.shieldCheck,
                title: 'settings.roles_permissions'.tr(),
                subtitle: 'settings.roles_permissions_sub'.tr(),
                onTap: () => context.push('/roles'),
              ),
              _buildSettingItem(
                context,
                icon: HeroIcons.key,
                title: 'settings.doc_config'.tr(),
                subtitle: 'settings.doc_config_sub'.tr(),
                onTap: () => context.push('/document-configuration'),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'settings.app_preferences'.tr()),
            _buildSettingsGroup(context, [
              _buildSettingItem(
                context,
                icon: HeroIcons.swatch,
                title: 'settings.appearance'.tr(),
                subtitle: 'settings.appearance_sub'.tr(),
                onTap: () => context.push('/appearance'),
              ),
              _buildSettingItem(
                context,
                icon: HeroIcons.language,
                title: 'settings.language'.tr(),
                subtitle: 'settings.language_sub'.tr(),
                onTap: () => context.push('/language'),
              ),
              _buildSettingItem(
                context,
                icon: HeroIcons.informationCircle,
                title: 'settings.about'.tr(),
                subtitle: 'settings.about_sub'.tr(),
                onTap: () => context.push('/about'),
              ),
            ]),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('settings.logout_confirm_title'.tr()),
                      content: Text('settings.logout_confirm_message'.tr()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('common.cancel'.tr()),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                          child: Text('settings.logout'.tr()),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    ref.read(authProvider.notifier).logout();
                  }
                },
                icon: const HeroIcon(HeroIcons.arrowRightOnRectangle, size: 18),
                label: Text('settings.logout'.tr()),
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
                    ? NetworkImage(getFullImageUrl(user.image)) 
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
                      ],
                      ),          loading: () => Row(
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
          error: (err, __) => Row(
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
                      'common.error'.tr(),
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                    ),
                    Text(
                      err.toString().replaceAll('Exception: ', ''),
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
