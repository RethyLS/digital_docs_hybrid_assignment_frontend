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
        title: const Text('About'),
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
              'Digital Document System',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 32),
            _buildInfoSection(
              context,
              title: 'Project Overview',
              content:
                  'A comprehensive HR Document Management System designed to streamline organization workflows, employee records, and sensitive documentation with high security and modern accessibility.',
            ),
            const SizedBox(height: 24),
            _buildFeaturesSection(context),
            const SizedBox(height: 40),
            Divider(color: theme.colorScheme.outline.withOpacity(0.1)),
            const SizedBox(height: 20),
            Text(
              '© 2026 HR Digital Docs Assignment',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
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
            color: theme.colorScheme.onSurface.withOpacity(0.8),
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
            'Key Features',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(context, HeroIcons.documentCheck, 'Secure Document Storage'),
        _buildFeatureItem(context, HeroIcons.users, 'Employee Directory & Profiles'),
        _buildFeatureItem(context, HeroIcons.shieldCheck, 'Role-Based Access Control'),
        _buildFeatureItem(context, HeroIcons.bellAlert, 'Smart Notifications'),
        _buildFeatureItem(context, HeroIcons.devicePhoneMobile, 'Cross-Platform Sync'),
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
