import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:go_router/go_router.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/roles/providers/role_provider.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/roles/widgets/role_card.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_card.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/skeleton.dart';

class RolesScreen extends ConsumerStatefulWidget {
  const RolesScreen({super.key});

  @override
  ConsumerState<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends ConsumerState<RolesScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rolesAsync = ref.watch(rolesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Roles & Permissions'),
        actions: [
          IconButton(
            icon: const HeroIcon(HeroIcons.plus, size: 24),
            onPressed: () => context.push('/roles/add'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar (simplified for roles)
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
                decoration: InputDecoration(
                  hintText: 'Search roles...',
                  fillColor: Colors.transparent,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: HeroIcon(HeroIcons.magnifyingGlass, size: 20),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: rolesAsync.when(
              data: (response) {
                if (response.data.isEmpty) {
                  return const Center(child: Text('No roles found.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: response.data.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final role = response.data[index];
                    return RoleCard(
                      role: role,
                      onTap: () => context.push('/roles/detail', extra: role),
                    );
                  },
                );
              },
              loading: () => ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: 4,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Skeleton(width: 150, height: 20, margin: EdgeInsets.only(bottom: 8)),
                        const Skeleton(width: double.infinity, height: 14, margin: EdgeInsets.only(bottom: 16)),
                        Row(
                          children: const [
                            Skeleton(width: 100, height: 12),
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
                child: Text('Failed to load roles:\n$error', textAlign: TextAlign.center),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
