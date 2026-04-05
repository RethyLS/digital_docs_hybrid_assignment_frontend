import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:go_router/go_router.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/settings/screens/document_configuration/document_prefix_provider.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/settings/screens/document_configuration/document_prefix_repository.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/document_prefix.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_button.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_card.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_text_field.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/utils/dialog_utils.dart';

class DocumentPrefixFormScreen extends ConsumerStatefulWidget {
  final DocumentPrefix? prefix;

  const DocumentPrefixFormScreen({super.key, this.prefix});

  @override
  ConsumerState<DocumentPrefixFormScreen> createState() => _DocumentPrefixFormScreenState();
}

class _DocumentPrefixFormScreenState extends ConsumerState<DocumentPrefixFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _prefixController;
  late TextEditingController _separatorController;
  late TextEditingController _descriptionController;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.prefix?.name);
    _prefixController = TextEditingController(text: widget.prefix?.prefix);
    _separatorController = TextEditingController(text: widget.prefix?.separator ?? '-');
    _descriptionController = TextEditingController(text: widget.prefix?.description);
    _isDefault = widget.prefix?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _prefixController.dispose();
    _separatorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    DialogUtils.showLoadingDialog(context, message: 'Saving...');
    final isEditing = widget.prefix != null;

    try {
      final repo = ref.read(documentPrefixRepositoryProvider);
      bool success;

      final newPrefix = DocumentPrefix(
        id: widget.prefix?.id ?? 0,
        name: _nameController.text.trim(),
        prefix: _prefixController.text.trim(),
        separator: _separatorController.text.trim().isEmpty ? null : _separatorController.text.trim(),
        format: '{prefix}{separator}{sequence}', // Assuming simple format based on backend
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        status: widget.prefix?.status ?? 'active',
        isDefault: _isDefault,
      );

      if (widget.prefix == null) {
        success = await repo.createPrefix(newPrefix);
      } else {
        success = await repo.updatePrefix(widget.prefix!.id, newPrefix);
      }
      
      if (mounted) DialogUtils.hideLoadingDialog(context);

      if (success && mounted) {
        ref.invalidate(documentPrefixesProvider);
        DialogUtils.showSuccessDialog(
          context,
          message: widget.prefix == null ? 'Prefix created successfully' : 'Prefix updated successfully',
          onDismiss: () {
            if (isEditing) {
              context.pop();
              context.pop();
            } else {
              context.pop();
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
    final isEditing = widget.prefix != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Prefix' : 'Add Prefix'),
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
                      'Prefix Configuration',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Name *',
                      controller: _nameController,
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Prefix Value *',
                            controller: _prefixController,
                            validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            label: 'Separator',
                            controller: _separatorController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Description',
                      controller: _descriptionController,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Set as Default'),
                      subtitle: const Text('New documents will use this prefix automatically'),
                      value: _isDefault,
                      activeColor: theme.colorScheme.primary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (bool value) {
                        setState(() {
                          _isDefault = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: isEditing ? 'Update Prefix' : 'Save Prefix',
                onPressed: _submitForm,
                icon: isEditing ? HeroIcons.check : HeroIcons.plus,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

