import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hybrid_digital_docs_assignment_frontend/core/utils/image_utils.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/dashboard/providers/dashboard_provider.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/providers/user_profile_provider.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_card.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/skeleton.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dashboardAsync = ref.watch(dashboardProvider);
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('dashboard.title'.tr()),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => context.go('/settings'),
              child: userProfileAsync.when(
                data: (user) => CircleAvatar(
                  radius: 16,
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
                            fontSize: 12,
                          ),
                        )
                      : null,
                ),
                loading: () => const Skeleton(width: 32, height: 32, borderRadius: 16),
                error: (_, __) => CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.error.withValues(alpha: 0.1),
                  child: HeroIcon(
                    HeroIcons.user,
                    size: 18,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: dashboardAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'dashboard.overview'.tr(),
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.5,
                children: [
                  _buildMetricCard(
                    context, 
                    'dashboard.total_employees'.tr(), 
                    data.totalEmployees.toString(), 
                    HeroIcons.users,
                    onTap: () => context.go('/employees'),
                  ),
                  _buildMetricCard(
                    context, 
                    'dashboard.total_documents'.tr(), 
                    data.totalDocuments.toString(), 
                    HeroIcons.documentText,
                    onTap: () => context.go('/documents'),
                  ),
                  _buildMetricCard(
                    context, 
                    'dashboard.total_users'.tr(), 
                    data.totalUsers.toString(), 
                    HeroIcons.userGroup,
                    onTap: () => context.go('/settings'),
                  ),
                  _buildMetricCard(
                    context, 
                    'dashboard.active_employees'.tr(), 
                    data.activeEmployees.toString(), 
                    HeroIcons.users,
                    onTap: () => context.go('/employees'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'dashboard.recent_activities'.tr(),
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (data.recentDocuments.isEmpty)
                CustomCard(
                  child: Center(
                    child: Text(
                      'dashboard.no_recent_activities'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ),
                )
              else
                CustomCard(
                  padding: EdgeInsets.zero,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.recentDocuments.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final doc = data.recentDocuments[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          child: HeroIcon(
                            HeroIcons.documentCheck,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          doc.title ?? 'Untitled',
                          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(doc.documentCode ?? 'NO-CODE'),
                        trailing: Text(
                          doc.createdAt != null ? DateFormat('MMM dd, yyyy').format(doc.createdAt!) : 'N/A',
                          style: theme.textTheme.bodySmall,
                        ),                        onTap: () => context.go('/documents'),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        loading: () => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Skeleton(width: 100, height: 24),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.5,
                children: List.generate(4, (index) => CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Skeleton(width: 80, height: 12),
                          Skeleton(width: 16, height: 16, borderRadius: 4),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Skeleton(width: 40, height: 24),
                    ],
                  ),
                )),
              ),
              const SizedBox(height: 24),
              const Skeleton(width: 150, height: 24),
              const SizedBox(height: 16),
              CustomCard(
                padding: EdgeInsets.zero,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Skeleton(width: 40, height: 40, borderRadius: 20),
                      title: const Skeleton(width: double.infinity, height: 16, margin: EdgeInsets.only(bottom: 8)),
                      subtitle: const Skeleton(width: 100, height: 12),
                      trailing: const Skeleton(width: 50, height: 12),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Text('Failed to load dashboard:\n$error', textAlign: TextAlign.center),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, 
    String title, 
    String value, 
    HeroIcons icon, 
    {VoidCallback? onTap}
  ) {
    final theme = Theme.of(context);
    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              HeroIcon(
                icon,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 24,
            ),
          ),
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
}
