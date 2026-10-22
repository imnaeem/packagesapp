import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Terms of Service',
            style: AppTextStyles.displayMedium.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            'Last updated: April 2026',
            style: AppTextStyles.caption.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          _TermsSection(
            title: '1. Acceptance of Terms',
            content:
                'By downloading and using PK Packages, you agree to be bound by these Terms of Service. If you do not agree, please do not use the app.',
          ),
          _TermsSection(
            title: '2. Use of the App',
            content:
                'PK Packages provides package information for informational purposes only. We do not guarantee the accuracy, completeness, or timeliness of any package information.',
          ),
          _TermsSection(
            title: '3. User Accounts',
            content:
                'You are responsible for maintaining the confidentiality of your account credentials. You agree to notify us immediately of any unauthorised use of your account.',
          ),
          _TermsSection(
            title: '4. Intellectual Property',
            content:
                'All network logos and trademarks displayed belong to their respective owners. PK Packages is not affiliated with any of the telecom operators listed.',
          ),
          _TermsSection(
            title: '5. Limitation of Liability',
            content:
                'PK Packages is provided "as is" without warranties. We are not responsible for any decisions made based on information provided in this app. Always verify packages with your network operator.',
          ),
          _TermsSection(
            title: '6. Changes to Terms',
            content:
                'We reserve the right to update these Terms at any time. Continued use of the app after changes constitutes acceptance of the new Terms.',
          ),
          _TermsSection(
            title: '7. Contact',
            content: 'For questions about these Terms, email us at: legal@pkpackages.app',
          ),
        ],
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  final String title;
  final String content;

  const _TermsSection({required this.title, required this.content});

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
