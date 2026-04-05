import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/models/user.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/providers/user_profile_provider.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_button.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_card.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_text_field.dart';

import 'package:hybrid_digital_docs_assignment_frontend/shared/utils/dialog_utils.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {  
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();       

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      DialogUtils.showErrorDialog(
        context,
        message: 'security_screen.password_mismatch'.tr(),
      );
      return;
    }

    DialogUtils.showLoadingDialog(context, message: 'Saving...');   

    try {
      final success = await ref.read(userProfileProvider.notifier).updatePassword(
        _oldPasswordController.text,
        _newPasswordController.text,
        _confirmPasswordController.text,
      );

      if (mounted) DialogUtils.hideLoadingDialog(context);

      if (success && mounted) {
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        DialogUtils.showSuccessDialog(
          context,
          message: 'security_screen.password_changed'.tr(),
          onDismiss: () {
            if (mounted) {
              setState(() {
                _obscureOld = true;
                _obscureNew = true;
                _obscureConfirm = true;
              });
            }
          },
        );
      }
    } catch (e) {
      if (mounted) DialogUtils.hideLoadingDialog(context);

      if (mounted) {
        DialogUtils.showErrorDialog(
          context,
          message: e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('settings.security'.tr()),
      ),
      body: userAsync.when(
        data: (user) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,     
                  children: [
                    Text(
                      'security_screen.change_password'.tr(),       
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'security_screen.old_password'.tr(),   
                      controller: _oldPasswordController,
                      obscureText: _obscureOld,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureOld ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () => setState(() => _obscureOld = !_obscureOld),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'security_screen.new_password'.tr(),   
                      controller: _newPasswordController,
                      obscureText: _obscureNew,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () => setState(() => _obscureNew = !_obscureNew),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        if (val.length < 8) return 'Minimum 8 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'security_screen.confirm_password'.tr(),
                      controller: _confirmPasswordController,       
                      obscureText: _obscureConfirm,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'security_screen.update_password'.tr(),
                        onPressed: () => _submitForm(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),  
      ),
    );
  }
}
