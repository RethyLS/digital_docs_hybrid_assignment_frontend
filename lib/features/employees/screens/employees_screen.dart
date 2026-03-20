import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/providers/employee_provider.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/widgets/employee_card.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_card.dart';

class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen> {
  bool _isFilterExpanded = false;
  String _selectedDepartment = 'All Departments';
  String _selectedBranch = 'All Branches';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final employeesAsync = ref.watch(employeesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
          IconButton(
            icon: const HeroIcon(HeroIcons.userPlus, size: 24),
            onPressed: () {},
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
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _isFilterExpanded 
                                ? theme.colorScheme.primary 
                                : theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: HeroIcon(
                            HeroIcons.funnel,
                            size: 18,
                            color: _isFilterExpanded ? Colors.white : theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: employeesAsync.when(
                  data: (response) {
                    if (response.data.isEmpty) {
                      return const Center(child: Text('No employees found.'));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: response.data.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return EmployeeCard(employee: response.data[index]);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
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
              top: 76, // Positioned right below the search bar
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
                      _buildDropdown(
                        theme,
                        label: 'Department',
                        value: _selectedDepartment,
                        items: ['All Departments', 'IT Department', 'Human Resources', 'Design'],
                        onChanged: (val) => setState(() => _selectedDepartment = val!),
                      ),
                      const SizedBox(height: 16),
                      // Branch Filter
                      _buildDropdown(
                        theme,
                        label: 'Branch',
                        value: _selectedBranch,
                        items: ['All Branches', 'Main Office', 'Development Center'],
                        onChanged: (val) => setState(() => _selectedBranch = val!),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedDepartment = 'All Departments';
                                _selectedBranch = 'All Branches';
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
