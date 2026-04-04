import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedRole = ref.read(userRoleFilterProvider) ?? 'All Roles';
    _selectedStatus = ref.read(userStatusFilterProvider);
    _searchController.text = ref.read(userSearchQueryProvider);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(usersProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usersAsync = ref.watch(usersProvider);
    final rolesAsync = ref.watch(userRolesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('users.title'.tr()),
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
                    controller: _searchController,
                    onChanged: (val) {
                      ref.read(userSearchQueryProvider.notifier).updateQuery(val);
                    },
                    decoration: InputDecoration(
                      hintText: 'users.search_hint'.tr(),
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
                  data: (paginatedState) {
                    if (paginatedState.users.isEmpty) {
                      return const Center(child: Text('No users found.'));
                    }
                    return ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: paginatedState.users.length + (paginatedState.hasMore ? 1 : 0),
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == paginatedState.users.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return UserCard(user: paginatedState.users[index]);
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
                      rolesAsync.when(
                        data: (response) => _buildRoleDropdown(theme, response.data),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const Text('Error loading roles'),
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
                              ref.read(userRoleFilterProvider.notifier).updateRole(null);
                              ref.read(userStatusFilterProvider.notifier).updateStatus('All Statuses');
                            },
                            child: const Text('Reset'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isFilterExpanded = false;
                              });
                              ref.read(userRoleFilterProvider.notifier).updateRole(_selectedRole == 'All Roles' ? null : _selectedRole);
                              ref.read(userStatusFilterProvider.notifier).updateStatus(_selectedStatus);
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

  Widget _buildRoleDropdown(ThemeData theme, List<dynamic> roles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Role',
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
              value: _selectedRole,
              icon: HeroIcon(HeroIcons.chevronDown, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              items: [
                DropdownMenuItem<String>(
                  value: 'All Roles',
                  child: Text('All Roles', style: theme.textTheme.bodyMedium),
                ),
                ...roles.map((role) {
                  return DropdownMenuItem<String>(
                    value: role.name,
                    child: Text(role.name ?? 'Unknown', style: theme.textTheme.bodyMedium),
                  );
                }),
              ],
              onChanged: (val) => setState(() => _selectedRole = val!),
            ),
          ),
        ),
      ],
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
