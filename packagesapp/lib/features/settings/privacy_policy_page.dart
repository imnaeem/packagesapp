import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Privacy Policy',
            style: AppTextStyles.displayMedium.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            'Last updated: April 2026',
            style: AppTextStyles.caption.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          _PolicySection(
            title: '1. Information We Collect',
            content:
                'We collect information you provide directly to us when you create an account (name, email), as well as usage data to improve the app experience. We do not sell your personal information.',
          ),
          _PolicySection(
            title: '2. Firebase & Authentication',
            content:
                'Authentication is handled by Firebase Authentication. When you sign in, Firebase collects your email and a hashed password. We never have access to your plain-text password.',
          ),
          _PolicySection(
            title: '3. Local Storage',
            content:
                'Package data is stored locally on your device using Hive for offline access. This data is not shared with third parties.',
          ),
          _PolicySection(
            title: '4. Favourites',
            content:
                'Guest favourites are stored locally only. Signed-in users have their favourites synced to our secure servers for cross-device access.',
          ),
          _PolicySection(
            title: '5. Analytics',
            content:
                'We may collect anonymised usage analytics to understand app performance. No personally identifiable information is included in analytics data.',
          ),
          _PolicySection(
            title: '6. Contact',
            content:
                'For privacy-related queries, contact us at: privacy@pkpackages.app',
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;

  const _PolicySection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleSmall.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
