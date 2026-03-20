import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:go_router/go_router.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/roles/providers/role_provider.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/roles/repositories/role_repository.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/models/role.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_button.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_card.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_text_field.dart';

class RoleFormScreen extends ConsumerStatefulWidget {
  final Role? role;

  const RoleFormScreen({super.key, this.role});

  @override
  ConsumerState<RoleFormScreen> createState() => _RoleFormScreenState();
}

class _RoleFormScreenState extends ConsumerState<RoleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  bool _isLoading = false;
  final Set<String> _selectedPermissions = {};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.role?.name);
    _descriptionController = TextEditingController(text: widget.role?.description);
    
    if (widget.role?.permissions != null) {
      for (var p in widget.role!.permissions!) {
        if (p.name != null) {
          _selectedPermissions.add(p.name!);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(roleRepositoryProvider);
      bool success;

      if (widget.role == null) {
        success = await repo.createRole(
          _nameController.text.trim(),
          _descriptionController.text.trim(),
          _selectedPermissions.toList(),
        );
      } else {
        success = await repo.updateRole(
          widget.role!.id,
          _nameController.text.trim(),
          _descriptionController.text.trim(),
          _selectedPermissions.toList(),
        );
      }

      if (success && mounted) {
        ref.invalidate(rolesProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.role == null ? 'Role created successfully' : 'Role updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
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
    final isEditing = widget.role != null;
    final permissionsAsync = ref.watch(permissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Role' : 'Create Role'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Role Details',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Role Name',
                      controller: _nameController,
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Description',
                      controller: _descriptionController,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomCard(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Permissions',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(height: 1),
                    permissionsAsync.when(
                      data: (response) {
                        if (response.data.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No permissions available.'),
                          );
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: response.data.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final permission = response.data[index];
                            final isSelected = _selectedPermissions.contains(permission.name);
                            return CheckboxListTile(
                              title: Text(permission.name ?? 'Unknown', style: theme.textTheme.bodyMedium),
                              subtitle: permission.description != null ? Text(permission.description!, style: theme.textTheme.bodySmall) : null,
                              value: isSelected,
                              activeColor: theme.colorScheme.primary,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true && permission.name != null) {
                                    _selectedPermissions.add(permission.name!);
                                  } else if (permission.name != null) {
                                    _selectedPermissions.remove(permission.name);
                                  }
                                });
                              },
                            );
                          },
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, stack) => Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Error loading permissions: $error', style: TextStyle(color: theme.colorScheme.error)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: isEditing ? 'Update Role' : 'Save Role',
                onPressed: _submitForm,
                isLoading: _isLoading,
                icon: isEditing ? HeroIcons.check : HeroIcons.plus,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
