import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:go_router/go_router.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/settings/screens/document_configuration/document_prefix_provider.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/settings/screens/document_configuration/document_prefix_repository.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/document_prefix.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_button.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_card.dart';

class DocumentConfigurationScreen extends ConsumerWidget {
  const DocumentConfigurationScreen({super.key});

  Future<void> _deletePrefix(BuildContext context, WidgetRef ref, DocumentPrefix prefix) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Prefix'),
        content: Text('Are you sure you want to delete the prefix "${prefix.name}"?'),
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
      try {
        final repo = ref.read(documentPrefixRepositoryProvider);
        await repo.deletePrefix(prefix.id);
        ref.invalidate(documentPrefixesProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Prefix deleted successfully'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final prefixesAsync = ref.watch(documentPrefixesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Configuration'),
      ),
      body: prefixesAsync.when(
        data: (prefixes) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: prefixes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final prefix = prefixes[index];
              return CustomCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: HeroIcon(
                        HeroIcons.hashtag,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                prefix.name ?? 'Unknown',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              if (prefix.isDefault == true) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Format: ${prefix.prefix}${prefix.separator}{sequence}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const HeroIcon(HeroIcons.pencilSquare, size: 20),
                      onPressed: () => context.push('/document-configuration/edit', extra: prefix),
                    ),
                    if (prefix.isDefault != true)
                      IconButton(
                        icon: HeroIcon(HeroIcons.trash, size: 20, color: theme.colorScheme.error),
                        onPressed: () => _deletePrefix(context, ref, prefix),
                      ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/document-configuration/add'),
        backgroundColor: theme.colorScheme.primary,
        child: const HeroIcon(HeroIcons.plus, color: Colors.white),
      ),
    );
  }
}
