import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:go_router/go_router.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/models/user.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/models/role.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/providers/user_provider.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/repositories/user_repository.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/roles/providers/all_roles_provider.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_button.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_card.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_text_field.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/utils/dialog_utils.dart';

class UserFormScreen extends ConsumerStatefulWidget {
  final User? user;

  const UserFormScreen({super.key, this.user});

  @override
  ConsumerState<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends ConsumerState<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  Role? _selectedRole;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user?.firstName);
    _lastNameController = TextEditingController(text: widget.user?.lastName);
    _emailController = TextEditingController(text: widget.user?.email);
    _phoneController = TextEditingController(text: widget.user?.phone);
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    if (widget.user?.roles != null && widget.user!.roles!.isNotEmpty) {
      _selectedRole = widget.user!.roles!.first;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (widget.user == null && _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('security_screen.password_mismatch'.tr()), backgroundColor: Colors.redAccent),
      );
      return;
    }

    DialogUtils.showLoadingDialog(context, message: 'Saving...');

    final user = User(
      id: widget.user?.id ?? 0,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      status: widget.user?.status ?? 'active',
      roles: _selectedRole != null ? [_selectedRole!] : [], 
    );

    try {
      final repo = ref.read(userRepositoryProvider);
      bool success;

      if (widget.user == null) {
        success = await repo.createUser(
          user, 
          password: _passwordController.text, 
          passwordConfirmation: _confirmPasswordController.text
        );
      } else {
        success = await repo.updateUser(user.id, user);
      }
      
      if (mounted) DialogUtils.hideLoadingDialog(context);

      if (success && mounted) {
        ref.invalidate(usersProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.user == null ? 'user_management.user_created'.tr() : 'user_management.user_updated'.tr()),
            backgroundColor: Colors.green,
          ),
        );
        if (widget.user != null) {
          // If editing, pop the Edit screen, then pop the Detail screen
          context.pop();
          context.pop();
        } else {
          // If adding, just pop the Add screen
          context.pop();
        }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.user != null;
    final rolesAsync = ref.watch(allRolesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'common.edit'.tr() : 'common.add'.tr()),
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
                  'user_management.user_info'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'profile.first_name'.tr(),
                  controller: _firstNameController,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'profile.last_name'.tr(),
                  controller: _lastNameController,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'profile.email'.tr(),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (!value.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'profile.phone'.tr(),
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                Text(
                  'user_management.role'.tr(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                rolesAsync.when(
                  data: (roles) {
                    // Try to map existing role by ID
                    if (_selectedRole != null) {
                      try {
                        _selectedRole = roles.firstWhere((r) => r.id == _selectedRole!.id);
                      } catch (_) {
                        // Role not found in the fetched list
                      }
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Role>(
                          isExpanded: true,
                          value: _selectedRole,
                          hint: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text('Select Role'),
                          ),
                          icon: Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: HeroIcon(HeroIcons.chevronDown, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                          ),
                          items: roles.map((role) {
                            return DropdownMenuItem<Role>(
                              value: role,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(role.name ?? 'Unknown', style: theme.textTheme.bodyMedium),
                              ),
                            );
                          }).toList(),
                          onChanged: (Role? newValue) {
                            setState(() {
                              _selectedRole = newValue;
                            });
                          },
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error loading roles: $e', style: const TextStyle(color: Colors.red)),
                ),
                if (!isEditing) ...[
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'security_screen.new_password'.tr(),
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    suffixIcon: IconButton(
                      icon: HeroIcon(
                        _obscurePassword ? HeroIcons.eyeSlash : HeroIcons.eye,
                        size: 20,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'security_screen.confirm_password'.tr(),
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    suffixIcon: IconButton(
                      icon: HeroIcon(
                        _obscureConfirmPassword ? HeroIcons.eyeSlash : HeroIcons.eye,
                        size: 20,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                CustomButton(
                  text: isEditing ? 'user_management.update_user'.tr() : 'user_management.save_user'.tr(),
                  onPressed: _submitForm,
                  icon: isEditing ? HeroIcons.check : HeroIcons.plus,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


