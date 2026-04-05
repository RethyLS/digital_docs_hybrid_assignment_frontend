import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
        title: Text('settings.appearance'.tr()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'appearance.theme_mode'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'appearance.subtitle'.tr(),
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
                    title: 'appearance.light_mode'.tr(),
                    icon: HeroIcons.sun,
                    value: ThemeMode.light,
                    currentValue: themeMode,
                  ),
                  const Divider(),
                  _buildThemeOption(
                    context,
                    ref,
                    title: 'appearance.dark_mode'.tr(),
                    icon: HeroIcons.moon,
                    value: ThemeMode.dark,
                    currentValue: themeMode,
                  ),
                  const Divider(),
                  _buildThemeOption(
                    context,
                    ref,
                    title: 'appearance.system_default'.tr(),
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

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.05) : Colors.transparent,
      ),
      child: ListTile(
        leading: HeroIcon(
          icon,
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? theme.colorScheme.primary : null,
          ),
        ),
        trailing: isSelected ? Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: const HeroIcon(HeroIcons.check, size: 16, color: Colors.white),
        ) : null,
        onTap: () {
          ref.read(themeProvider.notifier).setThemeMode(value);
        },
      ),
    );
  }
}
