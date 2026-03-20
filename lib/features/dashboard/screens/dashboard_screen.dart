import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/dashboard/providers/dashboard_provider.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_card.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/skeleton.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dashboardAsync = ref.watch(dashboardProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => context.go('/settings'),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: HeroIcon(
                  HeroIcons.user,
                  size: 18,
                  color: theme.colorScheme.primary,
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
                'Overview',
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
                    'Total Employees', 
                    data.totalEmployees.toString(), 
                    HeroIcons.users,
                    onTap: () => context.go('/employees'),
                  ),
                  _buildMetricCard(
                    context, 
                    'Total Documents', 
                    data.totalDocuments.toString(), 
                    HeroIcons.documentText,
                    onTap: () => context.go('/documents'),
                  ),
                  _buildMetricCard(
                    context, 
                    'Total Users', 
                    data.totalUsers.toString(), 
                    HeroIcons.userGroup,
                    onTap: () => context.go('/settings'),
                  ),
                  _buildMetricCard(
                    context, 
                    'Departments', 
                    'N/A', 
                    HeroIcons.buildingOffice2,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Recent Activities',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (data.recentDocuments.isEmpty)
                CustomCard(
                  child: Center(
                    child: Text(
                      'No recent activities',
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
                          DateFormat('MMM dd, yyyy').format(doc.createdAt),
                          style: theme.textTheme.bodySmall,
                        ),
                        onTap: () => context.go('/documents'),
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
                color: theme.colorScheme.onSurface.withOpacity(0.5),
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
}
