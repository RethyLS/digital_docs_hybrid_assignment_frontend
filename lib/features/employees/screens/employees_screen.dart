import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/providers/employee_provider.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/widgets/employee_card.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/branch.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/department.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_card.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/skeleton.dart';

class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen> {
  bool _isFilterExpanded = false;
  int? _selectedDepartment;
  int? _selectedBranch;
  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize local state from providers
    _selectedDepartment = ref.read(employeeDepartmentFilterProvider);
    _selectedBranch = ref.read(employeeBranchFilterProvider);
    _searchController.text = ref.read(employeeSearchQueryProvider);
    
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
      ref.read(employeesProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final employeesAsync = ref.watch(employeesProvider);
    final departmentsAsync = ref.watch(employeeDepartmentsProvider);
    final branchesAsync = ref.watch(employeeBranchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('employees.title'.tr()),
        actions: [
          IconButton(
            icon: const HeroIcon(HeroIcons.userPlus, size: 24),
            onPressed: () => context.push('/employees/add'),
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
                      ref.read(employeeSearchQueryProvider.notifier).updateQuery(val);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search employees...',
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
                child: employeesAsync.when(
                  data: (paginatedState) {
                    if (paginatedState.employees.isEmpty) {
                      return const Center(child: Text('No employees found.'));
                    }
                    return ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: paginatedState.employees.length + (paginatedState.hasMore ? 1 : 0),
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == paginatedState.employees.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return EmployeeCard(employee: paginatedState.employees[index]);
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
                          ],
                        ),
                      );
                    },
                  ),
                  error: (error, stack) => Center(
                    child: Text('Failed to load employees:\n$error', textAlign: TextAlign.center),
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
                        'Filter Employees',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      // Department Filter
                      departmentsAsync.when(
                        data: (departments) => _buildDepartmentDropdown(theme, departments),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const Text('Error loading departments'),
                      ),
                      const SizedBox(height: 16),
                      // Branch Filter
                      branchesAsync.when(
                        data: (branches) => _buildBranchDropdown(theme, branches),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const Text('Error loading branches'),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedDepartment = null;
                                _selectedBranch = null;
                                _isFilterExpanded = false;
                              });
                              ref.read(employeeDepartmentFilterProvider.notifier).updateDepartment(null);
                              ref.read(employeeBranchFilterProvider.notifier).updateBranch(null);
                            },
                            child: const Text('Reset'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isFilterExpanded = false;
                              });
                              ref.read(employeeDepartmentFilterProvider.notifier).updateDepartment(_selectedDepartment);
                              ref.read(employeeBranchFilterProvider.notifier).updateBranch(_selectedBranch);
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

  Widget _buildDepartmentDropdown(ThemeData theme, List<Department> departments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Department',
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
            child: DropdownButton<int?>(
              isExpanded: true,
              value: _selectedDepartment,
              hint: const Text('All Departments'),
              icon: HeroIcon(HeroIcons.chevronDown, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text('All Departments', style: theme.textTheme.bodyMedium),
                ),
                ...departments.map((Department dept) {
                  return DropdownMenuItem<int?>(
                    value: dept.id,
                    child: Text(dept.name ?? 'Unknown', style: theme.textTheme.bodyMedium),
                  );
                }),
              ],
              onChanged: (val) => setState(() => _selectedDepartment = val),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBranchDropdown(ThemeData theme, List<Branch> branches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Branch',
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
            child: DropdownButton<int?>(
              isExpanded: true,
              value: _selectedBranch,
              hint: const Text('All Branches'),
              icon: HeroIcon(HeroIcons.chevronDown, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text('All Branches', style: theme.textTheme.bodyMedium),
                ),
                ...branches.map((Branch branch) {
                  return DropdownMenuItem<int?>(
                    value: branch.id,
                    child: Text(branch.name ?? 'Unknown', style: theme.textTheme.bodyMedium),
                  );
                }),
              ],
              onChanged: (val) => setState(() => _selectedBranch = val),
            ),
          ),
        ),
      ],
    );
  }
}
