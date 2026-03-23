import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/models/employee.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/providers/employee_provider.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/repositories/employee_repository.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/branch.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/department.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_button.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_card.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_text_field.dart';

class EmployeeFormScreen extends ConsumerStatefulWidget {
  final Employee? employee;

  const EmployeeFormScreen({super.key, this.employee});

  @override
  ConsumerState<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends ConsumerState<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _positionController;
  late TextEditingController _employeeCodeController;

  int? _selectedBranchId;
  int? _selectedDepartmentId;
  DateTime? _selectedJoinDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.employee?.firstName);
    _lastNameController = TextEditingController(text: widget.employee?.lastName);
    _emailController = TextEditingController(text: widget.employee?.email);
    _phoneController = TextEditingController(text: widget.employee?.phone);
    _positionController = TextEditingController(text: widget.employee?.position);

    // Auto-generate employee code if new
    final code = widget.employee?.employeeCode ?? _generateEmployeeCode();
    _employeeCodeController = TextEditingController(text: code);

    _selectedBranchId = widget.employee?.branchId;
    _selectedDepartmentId = widget.employee?.departmentId;
    
    if (widget.employee?.joinDate != null) {
      _selectedJoinDate = DateTime.tryParse(widget.employee!.joinDate!);
    } else if (widget.employee == null) {
      _selectedJoinDate = DateTime.now(); // Default to today for new employees
    }
  }

  String _generateEmployeeCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final suffix = timestamp.substring(timestamp.length - 6);
    final year = DateTime.now().year;
    return 'EMP$year-$suffix';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _employeeCodeController.dispose();
    super.dispose();
  }

  Future<void> _selectJoinDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedJoinDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedJoinDate) {
      setState(() {
        _selectedJoinDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBranchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Branch'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    if (_selectedJoinDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Join Date'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isLoading = true);

    final phoneText = _phoneController.text.trim();
    final positionText = _positionController.text.trim();

    final employee = Employee(
      id: widget.employee?.id ?? 0,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: phoneText.isEmpty ? null : phoneText,
      position: positionText.isEmpty ? null : positionText,
      employeeCode: _employeeCodeController.text.trim(),
      status: widget.employee?.status ?? 'active',
      branchId: _selectedBranchId,
      departmentId: _selectedDepartmentId,
      joinDate: DateFormat('yyyy-MM-dd').format(_selectedJoinDate!),
      organizationId: widget.employee?.organizationId ?? 1,
    );

    try {
      final repo = ref.read(employeeRepositoryProvider);
      bool success;

      if (widget.employee == null) {
        success = await repo.createEmployee(employee);
      } else {
        success = await repo.updateEmployee(employee.id, employee);
      }

      if (success && mounted) {
        ref.invalidate(employeesProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.employee == null ? 'Employee added successfully' : 'Employee updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/employees');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.employee != null;

    final branchesAsync = ref.watch(employeeBranchesProvider);
    final departmentsAsync = ref.watch(employeeDepartmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Employee' : 'Add Employee'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Employee Information',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Code Input with Auto Generate
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Employee Code *',
                        controller: _employeeCodeController,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                    if (!isEditing) ...[
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _employeeCodeController.text = _generateEmployeeCode();
                            });
                          },
                          icon: const HeroIcon(HeroIcons.arrowPath),
                          tooltip: 'Generate Code',
                        ),
                      ),
                    ]
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'First Name *',
                        controller: _firstNameController,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Last Name *',
                        controller: _lastNameController,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Email *',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (!value.contains('@')) return 'Invalid email format';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Join Date Picker
                Text(
                  'Join Date *',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectJoinDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: theme.inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedJoinDate == null
                              ? 'Select Date'
                              : DateFormat('MMM dd, yyyy').format(_selectedJoinDate!),
                          style: theme.textTheme.bodyMedium,
                        ),
                        HeroIcon(HeroIcons.calendar, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  label: 'Phone (Optional)',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Position (Optional)',
                  controller: _positionController,
                ),
                const SizedBox(height: 16),

                // Branch Dropdown (Required)
                Text(
                  'Branch *',
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
                    border: Border.all(
                      color: _selectedBranchId == null ? theme.colorScheme.error : Colors.transparent,
                      width: _selectedBranchId == null ? 1 : 0,
                    ),
                  ),
                  child: branchesAsync.when(
                    data: (branches) {
                      final branchExists = branches.any((b) => b.id == _selectedBranchId);
                      final effectiveBranchId = branchExists ? _selectedBranchId : null;

                      return DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          isExpanded: true,
                          value: effectiveBranchId,
                          hint: const Text('Select a Branch'),
                          icon: HeroIcon(HeroIcons.chevronDown, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                          items: branches.map((Branch branch) {
                            return DropdownMenuItem<int?>(
                              value: branch.id,
                              child: Text(branch.name ?? 'Unknown', style: theme.textTheme.bodyMedium),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedBranchId = val),
                        ),
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Text('Loading branches...'),
                    ),
                    error: (_, __) => const Text('Error loading branches'),
                  ),
                ),
                const SizedBox(height: 16),

                // Department Dropdown (Optional)
                Text(
                  'Department (Optional)',
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
                  child: departmentsAsync.when(
                    data: (departments) {
                      final deptExists = departments.any((d) => d.id == _selectedDepartmentId);
                      final effectiveDeptId = deptExists ? _selectedDepartmentId : null;

                      return DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          isExpanded: true,
                          value: effectiveDeptId,
                          hint: const Text('Select a Department'),
                          icon: HeroIcon(HeroIcons.chevronDown, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                          items: [
                            DropdownMenuItem<int?>(
                              value: null,
                              child: Text('None', style: theme.textTheme.bodyMedium),
                            ),
                            ...departments.map((Department dept) {
                              return DropdownMenuItem<int?>(
                                value: dept.id,
                                child: Text(dept.name ?? 'Unknown', style: theme.textTheme.bodyMedium),
                              );
                            }),
                          ],
                          onChanged: (val) => setState(() => _selectedDepartmentId = val),
                        ),
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Text('Loading departments...'),
                    ),
                    error: (_, __) => const Text('Error loading departments'),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    onPressed: _isLoading ? () {} : _submitForm,
                    text: isEditing ? 'Update Employee' : 'Save Employee',
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
