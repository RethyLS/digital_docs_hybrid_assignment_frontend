import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/models/user.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_card.dart';

class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback? onTap;

  const UserCard({
    super.key,
    required this.user,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CustomCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
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
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email ?? 'No Email',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    HeroIcon(
                      HeroIcons.shieldCheck,
                      size: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        user.roleName,
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user.organization?.name != null) ...[
                      const SizedBox(width: 12),
                      HeroIcon(
                        HeroIcons.buildingOffice,
                        size: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          user.organization!.name!,
                          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          _buildStatusBadge(context, user.status),
        ],
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

  Widget _buildStatusBadge(BuildContext context, String? status) {
    final theme = Theme.of(context);
    Color color;
    switch (status?.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'inactive':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status?.toUpperCase() ?? 'UNKNOWN',
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
