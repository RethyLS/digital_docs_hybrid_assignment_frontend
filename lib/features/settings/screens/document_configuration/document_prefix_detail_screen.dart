import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:go_router/go_router.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/settings/screens/document_configuration/document_prefix_provider.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/settings/screens/document_configuration/document_prefix_repository.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/document_prefix.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_card.dart';

import 'package:hybrid_digital_docs_assignment_frontend/shared/utils/dialog_utils.dart';

class DocumentPrefixDetailScreen extends ConsumerStatefulWidget {
  final DocumentPrefix prefix;

  const DocumentPrefixDetailScreen({super.key, required this.prefix});

  @override
  ConsumerState<DocumentPrefixDetailScreen> createState() => _DocumentPrefixDetailScreenState();
}

class _DocumentPrefixDetailScreenState extends ConsumerState<DocumentPrefixDetailScreen> {
  bool _isDeleting = false;

  Future<void> _deletePrefix() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Prefix'),
        content: Text('Are you sure you want to delete the prefix "${widget.prefix.name}"?'),
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
        final repo = ref.read(documentPrefixRepositoryProvider);
        await repo.deletePrefix(widget.prefix.id);
        
        if (mounted) DialogUtils.hideLoadingDialog(context);

        ref.invalidate(documentPrefixesProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Prefix deleted successfully'), backgroundColor: Colors.green),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) DialogUtils.hideLoadingDialog(context);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prefix = widget.prefix;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prefix Details'),
        actions: [
          IconButton(
            icon: const HeroIcon(HeroIcons.pencilSquare, size: 24),
            onPressed: () => context.push('/document-configuration/edit', extra: prefix),
          ),
          if (prefix.isDefault != true)
            IconButton(
              icon: HeroIcon(HeroIcons.trash, size: 24, color: Colors.redAccent.withValues(alpha: 0.8)),
              onPressed: _deletePrefix,
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: HeroIcon(HeroIcons.hashtag, color: theme.colorScheme.primary, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prefix.name ?? 'Unknown',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (prefix.isDefault == true) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              'DEFAULT',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Configuration',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CustomCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildDetailRow(context, 'Prefix Value', prefix.prefix ?? 'N/A'),
                  const Divider(height: 1),
                  _buildDetailRow(context, 'Separator', prefix.separator ?? 'N/A'),
                  const Divider(height: 1),
                  _buildDetailRow(context, 'Format', '${prefix.prefix}${prefix.separator}{sequence}'),
                ],
              ),
            ),
            if (prefix.description != null && prefix.description!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Description',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              CustomCard(
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    prefix.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
