import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/documents/providers/document_provider.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/documents/widgets/document_card.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/category.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_card.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/skeleton.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  bool _isFilterExpanded = false;
  String _selectedStatus = 'All Statuses';
  int? _selectedCategory;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize local state from providers
    _selectedStatus = ref.read(documentStatusFilterProvider);
    _selectedCategory = ref.read(documentCategoryFilterProvider);
    _searchController.text = ref.read(documentSearchQueryProvider);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final documentsAsync = ref.watch(documentsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [
          IconButton(
            icon: const HeroIcon(HeroIcons.plus, size: 24),
            onPressed: () => context.push('/documents/upload'),
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
                    controller: _searchController,
                    onChanged: (val) {
                      ref.read(documentSearchQueryProvider.notifier).updateQuery(val);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search documents...',
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
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: HeroIcon(
                            HeroIcons.adjustmentsHorizontal,
                            size: 20,
                            color: _isFilterExpanded ? theme.colorScheme.primary : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: documentsAsync.when(
                  data: (response) {
                    if (response.data.isEmpty) {
                      return const Center(child: Text('No documents found.'));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: response.data.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return DocumentCard(document: response.data[index]);
                      },
                    );
                  },
                  loading: () => ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: 5,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return CustomCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Skeleton(width: 40, height: 40, borderRadius: 8),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Skeleton(width: double.infinity, height: 16, margin: EdgeInsets.only(bottom: 4)),
                                      Skeleton(width: 100, height: 12),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Skeleton(width: 60, height: 20, borderRadius: 12),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: const [
                                Skeleton(width: 80, height: 12),
                                SizedBox(width: 16),
                                Skeleton(width: 80, height: 12),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  error: (error, stack) => Center(
                    child: Text('Failed to load documents:\n$error', textAlign: TextAlign.center),
                  ),
                ),
              ),
            ],
          ),

          // Expandable Filter Dropdown Overlay
          if (_isFilterExpanded)
            Positioned(
              top: 76,
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
                        'Filter Documents',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      // Status Filter
                      _buildStatusDropdown(theme),
                      const SizedBox(height: 16),
                      // Category Filter
                      categoriesAsync.when(
                        data: (categories) => _buildCategoryDropdown(theme, categories),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const Text('Error loading categories'),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedStatus = 'All Statuses';
                                _selectedCategory = null;
                                _isFilterExpanded = false;
                              });
                              ref.read(documentStatusFilterProvider.notifier).updateStatus('All Statuses');
                              ref.read(documentCategoryFilterProvider.notifier).updateCategory(null);
                            },
                            child: const Text('Reset'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isFilterExpanded = false;
                              });
                              ref.read(documentStatusFilterProvider.notifier).updateStatus(_selectedStatus);
                              ref.read(documentCategoryFilterProvider.notifier).updateCategory(_selectedCategory);
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

  Widget _buildStatusDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
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
              value: _selectedStatus,
              icon: HeroIcon(HeroIcons.chevronDown, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              items: ['All Statuses', 'Published', 'Draft', 'Archived'].map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: theme.textTheme.bodyMedium),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedStatus = val!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(ThemeData theme, List<Category> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
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
            child: DropdownButton<int?>(
              isExpanded: true,
              value: _selectedCategory,
              hint: const Text('All Categories'),
              icon: HeroIcon(HeroIcons.chevronDown, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text('All Categories', style: theme.textTheme.bodyMedium),
                ),
                ...categories.map((Category category) {
                  return DropdownMenuItem<int?>(
                    value: category.id,
                    child: Text(category.name ?? 'Unknown', style: theme.textTheme.bodyMedium),
                  );
                }),
              ],
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
          ),
        ),
      ],
    );
  }
}
