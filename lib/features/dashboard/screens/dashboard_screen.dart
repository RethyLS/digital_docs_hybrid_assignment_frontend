import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
      body: SingleChildScrollView(
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
                  '124', 
                  HeroIcons.users,
                  onTap: () => context.go('/employees'),
                ),
                _buildMetricCard(
                  context, 
                  'Active Documents', 
                  '45', 
                  HeroIcons.documentText,
                  onTap: () => context.go('/documents'),
                ),
                _buildMetricCard(
                  context, 
                  'Pending Approvals', 
                  '8', 
                  HeroIcons.clock,
                  onTap: () => context.go('/documents'),
                ),
                _buildMetricCard(
                  context, 
                  'Departments', 
                  '12', 
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
            CustomCard(
              padding: EdgeInsets.zero,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      child: HeroIcon(
                        HeroIcons.checkBadge,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Document Approved',
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    subtitle: const Text('Employee Handbook v2.0'),
                    trailing: Text(
                      '2h ago',
                      style: theme.textTheme.bodyMedium,
                    ),
                    onTap: () => context.go('/documents'),
                  );
                },
              ),
            ),
          ],
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
