import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('settings.about'.tr()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // App Logo
            CustomCard(
              padding: const EdgeInsets.all(20),
              child: Image.asset(
                'assets/images/logo1.png',
                width: 180,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Digital Docs',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 32),
            _buildInfoSection(
              context,
              title: 'Project Overview',
              content:
                  'Digital Docs is a modern HR Document Management System designed to simplify organizational workflows, employee record keeping, and secure document storage with high accessibility and platform-native performance.',
            ),
            const SizedBox(height: 24),
            _buildFeaturesSection(context),
            const SizedBox(height: 40),
            Divider(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
            const SizedBox(height: 20),
            Text(
              '© 2026 Digital Docs',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context,
      {required String title, required String content}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.6,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Key Capabilities',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(context, HeroIcons.documentText, 'Automated Document Numbering'),
        _buildFeatureItem(context, HeroIcons.users, 'Employee Assignment & Tracking'),
        _buildFeatureItem(context, HeroIcons.shieldCheck, 'Spatie Role-Based Permissions'),
        _buildFeatureItem(context, HeroIcons.adjustmentsHorizontal, 'Custom Document Prefixes'),
        _buildFeatureItem(context, HeroIcons.devicePhoneMobile, 'Cross-Device Cloud Sync'),
        _buildFeatureItem(context, HeroIcons.language, 'Native English & Khmer Support'),
      ],
    );
  }

  Widget _buildFeatureItem(BuildContext context, HeroIcons icon, String label) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          HeroIcon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
