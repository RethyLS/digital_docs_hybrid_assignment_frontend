import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:go_router/go_router.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/models/employee.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/providers/employee_provider.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/repositories/employee_repository.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_card.dart';

import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/skeleton.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/utils/dialog_utils.dart';

class EmployeeDetailScreen extends ConsumerStatefulWidget {
  final Employee employee;

  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  ConsumerState<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends ConsumerState<EmployeeDetailScreen> {
  Employee? _fullEmployee;
  bool _isLoadingDetails = true;

  @override
  void initState() {
    super.initState();
    _fetchFullDetails();
  }

  Future<void> _fetchFullDetails() async {
    try {
      final repo = ref.read(employeeRepositoryProvider);
      final details = await repo.getEmployee(widget.employee.id);
      if (mounted) {
        setState(() {
          _fullEmployee = details;
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _fullEmployee = widget.employee; // Fallback to list data
          _isLoadingDetails = false;
        });
      }
    }
  }

  Future<void> _deleteEmployee() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: const Text('Are you sure you want to delete this employee? This action cannot be undone.'),
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
        final repo = ref.read(employeeRepositoryProvider);
        final success = await repo.deleteEmployee(widget.employee.id);
        
        if (mounted) DialogUtils.hideLoadingDialog(context);

        if (success && mounted) {
          ref.invalidate(employeesProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Employee deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/employees');
        }
      } catch (e) {
        if (mounted) DialogUtils.hideLoadingDialog(context);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final employee = _fullEmployee ?? widget.employee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Details'),
        actions: [
          IconButton(
            icon: const HeroIcon(HeroIcons.pencilSquare, size: 24),
            onPressed: () => context.push('/employees/edit', extra: employee),
          ),
          IconButton(
            icon: HeroIcon(HeroIcons.trash, size: 24, color: Colors.redAccent.withValues(alpha: 0.8)),
            onPressed: _deleteEmployee,
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
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: Text(
                      _getInitials(employee.fullName),
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.fullName,
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          employee.position ?? 'No Position',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(context, employee.status),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Contact Information',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CustomCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildDetailRow(context, HeroIcons.envelope, 'Email', employee.email ?? 'N/A'),
                  const Divider(),
                  _buildDetailRow(context, HeroIcons.phone, 'Phone', employee.phone ?? 'N/A'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Employment Details',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CustomCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildDetailRow(context, HeroIcons.identification, 'Employee Code', employee.employeeCode ?? 'N/A'),
                  const Divider(),
                  _buildDetailRow(context, HeroIcons.buildingOffice, 'Department', employee.department?.name ?? 'N/A'),
                  const Divider(),
                  _buildDetailRow(context, HeroIcons.mapPin, 'Branch', employee.branch?.name ?? 'N/A'),
                  const Divider(),
                  _buildDetailRow(context, HeroIcons.calendar, 'Join Date', employee.joinDate ?? 'N/A'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Assigned Documents',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_isLoadingDetails)
              const CustomCard(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            else if (_fullEmployee?.assignedDocuments == null || _fullEmployee!.assignedDocuments!.isEmpty)
              CustomCard(
                child: Center(
                  child: Text(
                    'No documents assigned to this employee.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _fullEmployee!.assignedDocuments!.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final doc = _fullEmployee!.assignedDocuments![index];
                  return CustomCard(
                    onTap: () => context.push('/documents/detail', extra: doc),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: HeroIcon(
                            HeroIcons.documentText,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc.title ?? doc.fileName ?? 'Unknown Document',
                                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                doc.documentCode ?? 'No Code',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        HeroIcon(HeroIcons.chevronRight, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, HeroIcons icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeroIcon(icon, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status?.toUpperCase() ?? 'UNKNOWN',
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

