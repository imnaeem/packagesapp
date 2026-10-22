import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_text_styles.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.phone_android_rounded, size: 40, color: colorScheme.primary),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              AppConstants.appName,
              style: AppTextStyles.displayMedium.copyWith(color: colorScheme.onSurface),
            ),
          ),
          Center(
            child: Text(
              'Version ${AppConstants.appVersion}',
              style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 32),
          _Section(
            title: 'What is PK Packages?',
            content:
                'PK Packages is your go-to app for browsing, comparing, and managing mobile packages from all major Pakistani telecom networks including Jazz, Zong, Telenor, Ufone, and PTCL.',
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Features',
            content:
                '• Browse packages from 5 networks\n• Filter by Call, SMS, Internet, Hybrid & Social\n• Sort by price or validity\n• Save favourites (guest or signed-in)\n• Dark mode support\n• Offline caching — works without internet',
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Disclaimer',
            content:
                'Package information is fetched from our servers and may not always reflect real-time pricing or availability. Always verify with your network operator before activating.',
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;

  const _Section({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.titleSmall.copyWith(color: colorScheme.primary)),
        const SizedBox(height: 8),
        Text(content, style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface, height: 1.6)),
      ],
    );
  }
}
