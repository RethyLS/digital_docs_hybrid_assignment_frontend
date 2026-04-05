import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:go_router/go_router.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/settings/screens/document_configuration/document_prefix_provider.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/settings/screens/document_configuration/document_prefix_repository.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/document_prefix.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_card.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/skeleton.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_text_field.dart';

class DocumentConfigurationScreen extends ConsumerStatefulWidget {
  const DocumentConfigurationScreen({super.key});

  @override
  ConsumerState<DocumentConfigurationScreen> createState() => _DocumentConfigurationScreenState();
}

class _DocumentConfigurationScreenState extends ConsumerState<DocumentConfigurationScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  Widget _buildSkeletonList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => CustomCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Skeleton(width: 44, height: 44, borderRadius: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Skeleton(width: 150, height: 16),
                  SizedBox(height: 8),
                  Skeleton(width: 100, height: 12),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const Skeleton(width: 24, height: 24, borderRadius: 4),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prefixesAsync = ref.watch(documentPrefixesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('document_config.title'.tr()),
        actions: [
          IconButton(
            icon: const HeroIcon(HeroIcons.plus, size: 24),
            onPressed: () => context.push('/document-configuration/add'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
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
                decoration: InputDecoration(
                  hintText: 'document_config.search_hint'.tr(),
                  fillColor: Colors.transparent,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: HeroIcon(HeroIcons.magnifyingGlass, size: 20),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: prefixesAsync.when(
              data: (prefixes) {
                final filteredPrefixes = prefixes.where((p) {
                  return (p.name?.toLowerCase().contains(_searchQuery) ?? false) ||
                         (p.prefix?.toLowerCase().contains(_searchQuery) ?? false);
                }).toList();

                if (filteredPrefixes.isEmpty) {
                   return Center(
                     child: Text(
                       _searchQuery.isEmpty ? 'No prefixes found.' : 'No results matching "$_searchQuery"',
                       style: theme.textTheme.bodyMedium?.copyWith(
                         color: theme.colorScheme.onSurface.withValues(alpha: 0.5)
                       ),
                     ),
                   );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredPrefixes.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final prefix = filteredPrefixes[index];
                    return CustomCard(
                      onTap: () => context.push('/document-configuration/detail', extra: prefix),
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
                                    Flexible(
                                      child: Text(
                                        prefix.name ?? 'Unknown',
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
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
                          HeroIcon(HeroIcons.chevronRight, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => _buildSkeletonList(),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

