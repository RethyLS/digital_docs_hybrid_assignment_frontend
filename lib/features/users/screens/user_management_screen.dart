import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:go_router/go_router.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/providers/user_provider.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/widgets/user_card.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_card.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/skeleton.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  bool _isFilterExpanded = false;
  String _selectedRole = 'All Roles';
  String _selectedStatus = 'All Statuses';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const HeroIcon(HeroIcons.userPlus, size: 24),
            onPressed: () => context.push('/users/add'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      fillColor: Colors.transparent,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: HeroIcon(HeroIcons.magnifyingGlass, size: 20),
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isFilterExpanded = !_isFilterExpanded;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: HeroIcon(
                            HeroIcons.adjustmentsHorizontal,
                            size: 20,
                            color: _isFilterExpanded ? theme.colorScheme.primary : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: usersAsync.when(
                  data: (response) {
                    if (response.data.isEmpty) {
                      return const Center(child: Text('No users found.'));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: response.data.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return UserCard(user: response.data[index]);
                      },
                    );
                  },
                  loading: () => ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: 5,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return CustomCard(
                        child: Row(
                          children: [
                            const Skeleton(width: 48, height: 48, borderRadius: 24),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Skeleton(width: double.infinity, height: 16, margin: EdgeInsets.only(bottom: 4)),
                                  Skeleton(width: 100, height: 12, margin: EdgeInsets.only(bottom: 4)),
                                  Skeleton(width: 150, height: 12),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Skeleton(width: 60, height: 24, borderRadius: 12),
                          ],
                        ),
                      );
                    },
                  ),
                  error: (error, stack) => Center(
                    child: Text('Failed to load users:\n$error', textAlign: TextAlign.center),
                  ),
                ),
              ),
            ],
          ),

          // Expandable Filter Dropdown Overlay
          if (_isFilterExpanded)
            Positioned(
              top: 76,
              left: 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: CustomCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter Users',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      // Role Filter
                      _buildDropdown(
                        theme,
                        label: 'Role',
                        value: _selectedRole,
                        items: ['All Roles', 'Admin', 'Manager', 'Staff'],
                        onChanged: (val) => setState(() => _selectedRole = val!),
                      ),
                      const SizedBox(height: 16),
                      // Status Filter
                      _buildDropdown(
                        theme,
                        label: 'Status',
                        value: _selectedStatus,
                        items: ['All Statuses', 'Active', 'Inactive'],
                        onChanged: (val) => setState(() => _selectedStatus = val!),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedRole = 'All Roles';
                                _selectedStatus = 'All Statuses';
                                _isFilterExpanded = false;
                              });
                            },
                            child: const Text('Reset'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isFilterExpanded = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Apply'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown(ThemeData theme, {required String label, required String value, required List<String> items, required void Function(String?) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.inputDecorationTheme.fillColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              icon: HeroIcon(HeroIcons.chevronDown, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: theme.textTheme.bodyMedium),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
