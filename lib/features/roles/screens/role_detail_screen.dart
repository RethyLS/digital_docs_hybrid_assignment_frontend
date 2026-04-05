import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:go_router/go_router.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/roles/providers/role_provider.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/roles/repositories/role_repository.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/models/role.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_card.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/utils/dialog_utils.dart';

class RoleDetailScreen extends ConsumerStatefulWidget {
  final Role role;

  const RoleDetailScreen({super.key, required this.role});

  @override
  ConsumerState<RoleDetailScreen> createState() => _RoleDetailScreenState();
}

class _RoleDetailScreenState extends ConsumerState<RoleDetailScreen> {
  bool _isDeleting = false;

  Future<void> _deleteRole() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Role'),
        content: const Text('Are you sure you want to delete this role? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      DialogUtils.showLoadingDialog(context, message: 'Deleting...');
      try {
        final repo = ref.read(roleRepositoryProvider);
        final success = await repo.deleteRole(widget.role.id);
        
        if (mounted) DialogUtils.hideLoadingDialog(context);

        if (success && mounted) {
          ref.invalidate(rolesProvider);
          DialogUtils.showSuccessDialog(
            context,
            message: 'Role deleted successfully',
            onDismiss: () => context.pop(),
          );
        }
      } catch (e) {
        if (mounted) DialogUtils.hideLoadingDialog(context);
        if (mounted) {
          DialogUtils.showErrorDialog(
            context,
            message: e.toString().replaceAll('Exception: ', ''),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final role = widget.role;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Role Details'),
        actions: [
          IconButton(
            icon: const HeroIcon(HeroIcons.pencilSquare, size: 24),
            onPressed: () => context.push('/roles/edit', extra: role),
          ),
          IconButton(
            icon: HeroIcon(HeroIcons.trash, size: 24, color: Colors.redAccent.withValues(alpha: 0.8)),
            onPressed: _deleteRole,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.name ?? 'Untitled Role',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (role.description != null && role.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      role.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildInfoChip(
                        context,
                        HeroIcons.shieldCheck,
                        '${role.permissionsCount ?? 0} Permissions',
                      ),
                      const SizedBox(width: 16),
                      _buildInfoChip(
                        context,
                        HeroIcons.userGroup,
                        '${role.usersCount ?? 0} Users Assigned',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Assigned Permissions',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CustomCard(
              padding: EdgeInsets.zero,
              child: (role.permissions == null || role.permissions!.isEmpty)
                  ? const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: Text('No permissions assigned to this role.')),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: role.permissions!.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final permission = role.permissions![index];
                        return ListTile(
                          leading: HeroIcon(
                            HeroIcons.checkCircle,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(
                            permission.name ?? 'Unknown Permission',
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          subtitle: permission.description != null 
                              ? Text(permission.description!, style: theme.textTheme.bodySmall) 
                              : null,
                        );
                      },
                    ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, HeroIcons icon, String label) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        HeroIcon(
          icon,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

