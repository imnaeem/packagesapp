import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_text_styles.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.support_agent_rounded, size: 36, color: colorScheme.primary),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Get in touch',
              style: AppTextStyles.titleLarge.copyWith(color: colorScheme.onSurface),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'We\'d love to hear from you',
              style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 32),
          _ContactTile(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: 'support@pkpackages.app',
            onTap: () => launchUrl(Uri.parse('mailto:support@pkpackages.app')),
          ),
          const SizedBox(height: 12),
          _ContactTile(
            icon: Icons.language_outlined,
            title: 'Website',
            subtitle: 'www.pkpackages.app',
            onTap: () => launchUrl(Uri.parse('https://pkpackages.app')),
          ),
          const SizedBox(height: 32),
          Text(
            'Support hours: Monday – Saturday, 9am – 6pm PKT',
            style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: colorScheme.primary),
        ),
        title: Text(title, style: AppTextStyles.titleSmall),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
