import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_card.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentLocale = context.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text('language_screen.title'.tr()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'language_screen.choose_language'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CustomCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildLanguageOption(
                    context,
                    title: 'language_screen.english'.tr(),
                    flag: '🇺🇸',
                    locale: const Locale('en'),
                    currentLocale: currentLocale,
                  ),
                  const Divider(),
                  _buildLanguageOption(
                    context,
                    title: 'language_screen.khmer'.tr(),
                    flag: '🇰🇭',
                    locale: const Locale('km'),
                    currentLocale: currentLocale,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String title,
    required String flag,
    required Locale locale,
    required Locale currentLocale,
  }) {
    final theme = Theme.of(context);
    final isSelected = locale.languageCode == currentLocale.languageCode;

    return ListTile(
      leading: Text(
        flag,
        style: const TextStyle(fontSize: 24),
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
        onChanged: (bool value) {
          if (value) {
            context.setLocale(locale);
          }
        },
      ),
      onTap: () {
        context.setLocale(locale);
      },
    );
  }
}
