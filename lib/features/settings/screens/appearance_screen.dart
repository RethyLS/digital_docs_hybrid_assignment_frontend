import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hybrid_digital_docs_assignment_frontend/core/theme/theme_provider.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_card.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme Mode',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how the app looks to you.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            CustomCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildThemeOption(
                    context,
                    ref,
                    title: 'Light Mode',
                    icon: HeroIcons.sun,
                    value: ThemeMode.light,
                    currentValue: themeMode,
                  ),
                  const Divider(),
                  _buildThemeOption(
                    context,
                    ref,
                    title: 'Dark Mode',
                    icon: HeroIcons.moon,
                    value: ThemeMode.dark,
                    currentValue: themeMode,
                  ),
                  const Divider(),
                  _buildThemeOption(
                    context,
                    ref,
                    title: 'System Default',
                    icon: HeroIcons.cpuChip,
                    value: ThemeMode.system,
                    currentValue: themeMode,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required HeroIcons icon,
    required ThemeMode value,
    required ThemeMode currentValue,
  }) {
    final theme = Theme.of(context);
    final isSelected = value == currentValue;

    return ListTile(
      leading: HeroIcon(
        icon,
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.5),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: Switch.adaptive(
        value: isSelected,
        activeColor: theme.colorScheme.primary,
        onChanged: (bool newValue) {
          if (newValue) {
            ref.read(themeProvider.notifier).setThemeMode(value);
          }
        },
      ),
      onTap: () {
        ref.read(themeProvider.notifier).setThemeMode(value);
      },
    );
  }
}
