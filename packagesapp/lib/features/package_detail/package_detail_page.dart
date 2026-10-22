import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/network_constants.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_utils.dart';
import '../../models/package_model.dart';
import '../../models/resource_model.dart';

class PackageDetailPage extends ConsumerWidget {
  final String packageId;

  const PackageDetailPage({super.key, required this.packageId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packagesAsync = ref.watch(packagesProvider(null));

    return packagesAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(err.toString())),
      ),
      data: (packages) {
        final pkg = packages.firstWhere(
          (p) => p.id == packageId,
          orElse: () => packages.isNotEmpty ? packages.first : _emptyPackage(),
        );
        return _PackageDetailView(pkg: pkg);
      },
    );
  }

  PackageModel _emptyPackage() => PackageModel(
        id: '',
        networkId: '',
        name: 'Not found',
        category: '',
        subCategory: '',
        price: 0,
        validityDays: 0,
        activationCode: '',
        deactivationCode: '',
        resources: ResourceModel(
          onNetMinutes: null,
          offNetMinutes: null,
          sms: null,
          dataMb: null,
          dataGb: null,
        ),
        addons: [],
        extraServices: [],
        details: '',
        tags: [],
        isActive: false,
        isFeatured: false,
        createdAt: '',
        updatedAt: '',
      );
}

class _PackageDetailView extends ConsumerWidget {
  final PackageModel pkg;

  const _PackageDetailView({required this.pkg});

  void _showCodeActionSheet(
    BuildContext context, {
    required String title,
    required String code,
    required Color color,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? cs.surfaceContainerHighest : cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  code,
                  style: AppTextStyles.displayMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.phone_in_talk_rounded,
                      color: AppColors.success, size: 20),
                ),
                title: const Text('Dial Code',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Directly open in phone dialer'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: cs.surfaceContainerHigh.withOpacity(0.5),
                onTap: () {
                  Navigator.of(ctx).pop();
                  AppUtils.dialCode(code);
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.copy_rounded, color: color, size: 20),
                ),
                title: const Text('Copy Code',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Copy code to clipboard'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: cs.surfaceContainerHigh.withOpacity(0.5),
                onTap: () {
                  Navigator.of(ctx).pop();
                  AppUtils.copyToClipboard(context, code, label: title);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final networkInfo = NetworkConstants.findById(pkg.networkId);
    final networkColor = networkInfo?.brandColor ?? colorScheme.primary;
    final favourites = ref.watch(favouritesProvider);
    final isFav = favourites.any((f) => f.packageId == pkg.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(pkg.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_outline,
              color: isFav ? AppColors.error : null,
            ),
            onPressed: () => ref
                .read(favouritesProvider.notifier)
                .toggle(pkg.id, pkg.networkId),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => Share.share(
              '${pkg.name}\n${pkg.priceDisplay} | ${pkg.validityDisplay}\nActivate: ${pkg.activationCode}',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    networkColor.withOpacity(0.15),
                    networkColor.withOpacity(0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: networkColor.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (networkInfo != null)
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: Image.asset(networkInfo.logoAsset,
                              fit: BoxFit.contain),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pkg.name,
                              style: AppTextStyles.titleLarge.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              networkInfo?.name ?? pkg.networkId,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: networkColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatBox(
                        label: pkg.rechargeRequired != null &&
                                pkg.rechargeRequired! > 0
                            ? 'Load: Rs. ${pkg.rechargeRequired!.toInt()}'
                            : 'Price',
                        value: pkg.priceDisplay,
                        icon: Icons.payments_outlined,
                        color: networkColor,
                      ),
                      const SizedBox(width: 10),
                      _StatBox(
                        label: 'Validity',
                        value: pkg.validityDisplay,
                        icon: Icons.timer_outlined,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      _StatBox(
                        label: 'Category',
                        value: AppUtils.categoryLabel(pkg.category),
                        icon: AppUtils.categoryIcon(pkg.category),
                        color: AppColors.info,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Resources section
            _SectionTitle(title: 'Resources', icon: Icons.bar_chart_rounded),
            const SizedBox(height: 10),
            _ResourceGrid(pkg: pkg, networkColor: networkColor),

            // Social apps
            if (pkg.socialApps.isNotEmpty) ...[
              const SizedBox(height: 20),
              _SectionTitle(title: 'Included Apps', icon: Icons.apps_rounded),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: pkg.socialApps
                    .map((app) => _SocialAppChip(app: app))
                    .toList(),
              ),
            ],

            // Activation codes
            const SizedBox(height: 20),
            _SectionTitle(title: 'Codes', icon: Icons.dialpad_outlined),
            const SizedBox(height: 10),
            _CodeRow(
              label: 'Activate',
              code: pkg.activationCode,
              color: AppColors.success,
              onTap: () => _showCodeActionSheet(
                context,
                title: 'Activate ${pkg.name}',
                code: pkg.activationCode,
                color: networkColor,
              ),
              onCopy: () => AppUtils.copyToClipboard(
                context,
                pkg.activationCode,
                label: 'Activation code',
              ),
            ),
            if (pkg.deactivationCode.isNotEmpty) ...[
              const SizedBox(height: 8),
              _CodeRow(
                label: 'Deactivate',
                code: pkg.deactivationCode,
                color: AppColors.error,
                onTap: () => _showCodeActionSheet(
                  context,
                  title: 'Deactivate ${pkg.name}',
                  code: pkg.deactivationCode,
                  color: AppColors.error,
                ),
                onCopy: () => AppUtils.copyToClipboard(
                  context,
                  pkg.deactivationCode,
                  label: 'Deactivation code',
                ),
              ),
            ],

            // Addons
            if (pkg.addons.isNotEmpty) ...[
              const SizedBox(height: 20),
              _SectionTitle(title: 'Add-ons', icon: Icons.add_circle_outline),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: pkg.addons
                    .map((a) => _DetailChip(label: a.displayLabel))
                    .toList(),
              ),
            ],

            // Extra services
            if (pkg.extraServices.isNotEmpty) ...[
              const SizedBox(height: 20),
              _SectionTitle(
                  title: 'Extra Services', icon: Icons.star_outline_rounded),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: pkg.extraServices
                    .map((s) => _DetailChip(
                          label: s,
                          color: AppColors.warning,
                        ))
                    .toList(),
              ),
            ],

            // Tags
            if (pkg.tags.isNotEmpty) ...[
              const SizedBox(height: 20),
              _SectionTitle(title: 'Tags', icon: Icons.label_outline),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: pkg.tags
                    .map((t) => _DetailChip(
                          label: '#$t',
                          color: colorScheme.onSurfaceVariant,
                        ))
                    .toList(),
              ),
            ],

            // Details
            if (pkg.details.isNotEmpty) ...[
              const SizedBox(height: 20),
              _SectionTitle(
                  title: 'Details', icon: Icons.info_outline_rounded),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  pkg.details,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                if (pkg.deactivationCode.isNotEmpty)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showCodeActionSheet(
                        context,
                        title: 'Deactivate ${pkg.name}',
                        code: pkg.deactivationCode,
                        color: AppColors.error,
                      ),
                      icon: const Icon(Icons.stop_circle_outlined, size: 18),
                      label: const Text('Deactivate'),
                    ),
                  ),
                if (pkg.deactivationCode.isNotEmpty) const SizedBox(width: 12),
                if (pkg.activationCode.isNotEmpty)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showCodeActionSheet(
                        context,
                        title: 'Activate ${pkg.name}',
                        code: pkg.activationCode,
                        color: networkColor,
                      ),
                      icon: const Icon(Icons.dialpad_outlined, size: 18),
                      label: const Text('Activate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: networkColor,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.titleSmall.copyWith(color: colorScheme.onSurface),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.titleSmall.copyWith(color: colorScheme.onSurface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceGrid extends StatelessWidget {
  final PackageModel pkg;
  final Color networkColor;

  const _ResourceGrid({required this.pkg, required this.networkColor});

  @override
  Widget build(BuildContext context) {
    final items = <_ResourceData>[];

    if (pkg.allNetMinutes != null && pkg.allNetMinutes! > 0) {
      items.add(_ResourceData(
        icon: Icons.phone_outlined,
        label: '${pkg.allNetMinutes} All-Net Mins',
        color: AppColors.success,
      ));
    } else {
      if (pkg.resources.onNetMinutes != null && pkg.resources.onNetMinutes! > 0) {
        items.add(_ResourceData(
          icon: Icons.phone_outlined,
          label: '${pkg.resources.onNetMinutes} On-Net Mins',
          color: AppColors.success,
        ));
      }
      if (pkg.resources.offNetMinutes != null && pkg.resources.offNetMinutes! > 0) {
        items.add(_ResourceData(
          icon: Icons.phone_forwarded_outlined,
          label: '${pkg.resources.offNetMinutes} Off-Net Mins',
          color: AppColors.warning,
        ));
      }
    }

    if (pkg.resources.sms != null && pkg.resources.sms! > 0) {
      items.add(_ResourceData(
        icon: Icons.chat_bubble_outline,
        label: '${pkg.resources.sms} SMS',
        color: AppColors.info,
      ));
    }

    if (pkg.resources.dataGb != null && pkg.resources.dataGb! > 0) {
      items.add(_ResourceData(
        icon: Icons.wifi_outlined,
        label: '${pkg.resources.dataGb} GB Data',
        color: networkColor,
      ));
    } else if (pkg.resources.dataMb != null && pkg.resources.dataMb! > 0) {
      items.add(_ResourceData(
        icon: Icons.wifi_outlined,
        label: '${pkg.resources.dataMb} MB Data',
        color: networkColor,
      ));
    }

    if (pkg.dataTimeWindow != null && pkg.dataTimeWindow!.trim().isNotEmpty) {
      items.add(_ResourceData(
        icon: Icons.schedule_rounded,
        label: pkg.dataTimeWindow!,
        color: const Color(0xFF6C5CE7),
      ));
    }

    if (items.isEmpty) {
      return Text(
        'No resource information available',
        style: AppTextStyles.bodyMedium.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: item.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: item.color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(item.icon, size: 18, color: item.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ResourceData {
  final IconData icon;
  final String label;
  final Color color;

  const _ResourceData({required this.icon, required this.label, required this.color});
}

class _CodeRow extends StatelessWidget {
  final String label;
  final String code;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onCopy;

  const _CodeRow({
    required this.label,
    required this.code,
    required this.color,
    required this.onTap,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.dialpad_outlined, size: 16, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.caption.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      code,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: color,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onCopy,
                icon: Icon(Icons.copy_outlined, size: 18, color: color),
                tooltip: 'Copy',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String label;
  final Color? color;

  const _DetailChip({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: effectiveColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: effectiveColor.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: effectiveColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SocialAppChip extends StatelessWidget {
  final String app;

  const _SocialAppChip({required this.app});

  @override
  Widget build(BuildContext context) {
    final clean = app.toLowerCase().trim();
    Color brandColor;
    IconData icon;
    String name;

    switch (clean) {
      case 'whatsapp':
        brandColor = const Color(0xFF25D366);
        icon = Icons.chat_outlined;
        name = 'WhatsApp';
        break;
      case 'youtube':
        brandColor = const Color(0xFFFF0000);
        icon = Icons.play_circle_outline_rounded;
        name = 'YouTube';
        break;
      case 'facebook':
        brandColor = const Color(0xFF1877F2);
        icon = Icons.facebook_rounded;
        name = 'Facebook';
        break;
      case 'tiktok':
        brandColor = const Color(0xFFEE1D52);
        icon = Icons.music_note_rounded;
        name = 'TikTok';
        break;
      case 'instagram':
        brandColor = const Color(0xFFE1306C);
        icon = Icons.camera_alt_outlined;
        name = 'Instagram';
        break;
      case 'twitter':
      case 'x':
        brandColor = const Color(0xFF1DA1F2);
        icon = Icons.tag_rounded;
        name = 'X / Twitter';
        break;
      case 'tamasha':
        brandColor = const Color(0xFFFF9F1C);
        icon = Icons.tv_rounded;
        name = 'Tamasha';
        break;
      case 'imo':
        brandColor = const Color(0xFF0084FF);
        icon = Icons.video_call_outlined;
        name = 'IMO';
        break;
      default:
        brandColor = Theme.of(context).colorScheme.primary;
        icon = Icons.apps_rounded;
        name = app.isNotEmpty ? app[0].toUpperCase() + app.substring(1) : app;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? brandColor.withOpacity(0.2) : brandColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: brandColor.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: brandColor),
          const SizedBox(width: 5),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? brandColor.withOpacity(0.9) : brandColor,
            ),
          ),
        ],
      ),
    );
  }
}
