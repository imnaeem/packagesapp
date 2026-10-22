import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/network_constants.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_utils.dart';
import '../../../models/package_model.dart';
import '../../../models/resource_model.dart';

class PackageCard extends ConsumerWidget {
  final PackageModel package;
  final Color networkColor;

  const PackageCard({
    super.key,
    required this.package,
    required this.networkColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pkg = package;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favourites = ref.watch(favouritesProvider);
    final isFav = favourites.any((f) => f.packageId == pkg.id);
    final bestValueIds = ref.watch(bestValueIdsProvider(pkg.networkId));
    final isBestValue = bestValueIds.contains(pkg.id);
    final compareList = ref.watch(compareProvider);
    final isComparing = compareList.any((p) => p.id == pkg.id);

    final cardBg = isDark ? cs.surfaceContainerHighest : cs.surface;
    final divColor = cs.outline.withOpacity(isDark ? 0.6 : 0.5);
    final stripBg = networkColor.withOpacity(isDark ? 0.18 : 0.10);
    final stripText = networkColor;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: isComparing
            ? Border.all(color: networkColor.withOpacity(0.6), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left tinted strip: price + validity + best value badge
              Container(
                width: 88,
                color: stripBg,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Best value badge in the strip
                    if (isBestValue) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded, size: 8, color: Colors.white),
                            SizedBox(width: 2),
                            Text(
                              'Best',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      'Rs.',
                      style: TextStyle(
                        fontSize: 9,
                        color: stripText.withOpacity(0.65),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          pkg.price == pkg.price.roundToDouble()
                              ? pkg.price.toInt().toString()
                              : pkg.price.toStringAsFixed(1),
                          maxLines: 1,
                          softWrap: false,
                          style: TextStyle(
                            fontSize: 22,
                            color: stripText,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                          ),
                        ),
                      ),
                    ),
                    if (pkg.rechargeRequired != null &&
                        pkg.rechargeRequired! > 0) ...[
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Load: Rs. ${pkg.rechargeRequired!.toInt()}',
                          style: TextStyle(
                            fontSize: 7.5,
                            color: stripText.withOpacity(0.9),
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Container(width: 24, height: 1, color: stripText.withOpacity(0.2)),
                    const SizedBox(height: 6),
                    Icon(Icons.timer_outlined, size: 11, color: stripText.withOpacity(0.6)),
                    const SizedBox(height: 2),
                    Text(
                      pkg.validityDisplay,
                      style: TextStyle(
                        fontSize: 9,
                        color: stripText.withOpacity(0.75),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // ── Right content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + action icons
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              pkg.name,
                              style: AppTextStyles.titleSmall.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Compare toggle
                          _SmallIconBtn(
                            icon: isComparing
                                ? Icons.compare_arrows_rounded
                                : Icons.compare_arrows_outlined,
                            color: isComparing ? networkColor : cs.onSurfaceVariant,
                            tooltip: 'Compare',
                            onTap: () {
                              AppUtils.hapticLight();
                              final ok = ref.read(compareProvider.notifier).toggle(pkg);
                              if (!ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Max $kMaxCompare packages for comparison'),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                              }
                            },
                          ),
                          _SmallIconBtn(
                            icon: isFav ? Icons.favorite : Icons.favorite_outline,
                            color: isFav ? AppColors.error : cs.onSurfaceVariant,
                            tooltip: 'Favourite',
                            onTap: () {
                              AppUtils.hapticMedium();
                              ref.read(favouritesProvider.notifier).toggle(pkg.id, pkg.networkId);
                            },
                          ),
                          _SmallIconBtn(
                            icon: Icons.share_outlined,
                            color: cs.onSurfaceVariant,
                            tooltip: 'Share',
                            onTap: () => _shareAsImage(context, pkg, networkColor),
                          ),
                          _SmallIconBtn(
                            icon: Icons.info_outline_rounded,
                            color: cs.onSurfaceVariant,
                            tooltip: 'Details',
                            onTap: () {
                              ref.read(recentlyViewedProvider.notifier).record(pkg);
                              _showDetail(context, pkg, networkColor);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),
                      Divider(height: 1, thickness: 1, color: divColor),
                      const SizedBox(height: 8),

                      // Resources
                      _ResourceChips(pkg: pkg, networkColor: networkColor),

                      // Addons / extra
                      if (pkg.addons.isNotEmpty || pkg.extraServices.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            ...pkg.addons.map((a) => _Chip(
                                  label: a.displayLabel,
                                  color: cs.onSurfaceVariant,
                                  icon: Icons.add_rounded,
                                )),
                            ...pkg.extraServices.map((s) => _Chip(
                                  label: s,
                                  color: cs.onSurfaceVariant,
                                  icon: Icons.star_rounded,
                                )),
                          ],
                        ),
                      ],

                      // Code buttons
                      if (pkg.activationCode.isNotEmpty ||
                          pkg.deactivationCode.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Divider(height: 1, thickness: 1, color: divColor),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (pkg.activationCode.isNotEmpty)
                                _CodeBtn(
                                  label: 'Activate',
                                  code: pkg.activationCode,
                                  icon: Icons.phone_callback_outlined,
                                  color: networkColor,
                                  filled: true,
                                  onTap: () => _dialCode(pkg.activationCode),
                                ),
                              if (pkg.activationCode.isNotEmpty &&
                                  pkg.deactivationCode.isNotEmpty)
                                const SizedBox(width: 8),
                              if (pkg.deactivationCode.isNotEmpty)
                                _CodeBtn(
                                  label: 'Deactivate',
                                  code: pkg.deactivationCode,
                                  icon: Icons.phone_disabled_outlined,
                                  color: cs.onSurfaceVariant,
                                  filled: false,
                                  onTap: () => _dialCode(pkg.deactivationCode),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareAsImage(BuildContext context, PackageModel pkg, Color networkColor) async {
    AppUtils.hapticLight();
    final network = NetworkConstants.findById(pkg.networkId);
    final networkName = network?.name ?? pkg.networkId;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final repaintKey = GlobalKey();
    Uint8List? imageBytes;

    await showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => _SharePreviewDialog(
        repaintKey: repaintKey,
        pkg: pkg,
        networkColor: networkColor,
        networkName: networkName,
        isDark: isDark,
        onShare: () async {
          try {
            final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
            if (boundary != null) {
              final image = await boundary.toImage(pixelRatio: 3.0);
              final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
              imageBytes = byteData?.buffer.asUint8List();
            }
          } catch (_) {}
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );

    if (imageBytes != null) {
      final xFile = XFile.fromData(
        imageBytes!,
        mimeType: 'image/png',
        name: '${pkg.name.replaceAll(' ', '_')}.png',
      );
      await Share.shareXFiles([xFile],
          text: '${pkg.name} | ${pkg.priceDisplay} | ${pkg.validityDisplay}');
    } else {
      Share.share(
        '${pkg.name}\n${pkg.priceDisplay} | ${pkg.validityDisplay}\nActivate: ${pkg.activationCode}',
      );
    }
  }

  Future<void> _dialCode(String code) async {
    AppUtils.dialCode(code);
  }

  void _showDetail(BuildContext context, PackageModel pkg, Color networkColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PackageDetailSheet(pkg: pkg, networkColor: networkColor),
    );
  }
}

// ─── Resource Chips row ──────────────────────────────────────────────────────

class _ResourceChips extends StatelessWidget {
  final PackageModel pkg;
  final Color networkColor;

  const _ResourceChips({required this.pkg, required this.networkColor});

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    final resources = pkg.resources;

    // 1. All-Net or On-Net Minutes
    if (pkg.allNetMinutes != null && pkg.allNetMinutes! > 0) {
      chips.add(_ResChip(
        icon: Icons.phone_outlined,
        label: '${pkg.allNetMinutes}',
        sublabel: 'All-Net',
        accentColor: AppColors.success,
      ));
    } else {
      if (resources.onNetMinutes != null && resources.onNetMinutes! > 0) {
        chips.add(_ResChip(
          icon: Icons.phone_outlined,
          label: '${resources.onNetMinutes}',
          sublabel: 'On-Net',
          accentColor: AppColors.success,
        ));
      }
      if (resources.offNetMinutes != null && resources.offNetMinutes! > 0) {
        chips.add(_ResChip(
          icon: Icons.phone_forwarded_outlined,
          label: '${resources.offNetMinutes}',
          sublabel: 'Off-Net',
          accentColor: AppColors.warning,
        ));
      }
    }

    // 2. SMS (only if > 0)
    if (resources.sms != null && resources.sms! > 0) {
      chips.add(_ResChip(
        icon: Icons.chat_bubble_outline,
        label: '${resources.sms}',
        sublabel: 'SMS',
        accentColor: AppColors.info,
      ));
    }

    // 3. Data (prominently displayed for internet/hybrid packages)
    final hasData = (resources.dataGb != null && resources.dataGb! > 0) ||
        (resources.dataMb != null && resources.dataMb! > 0);
    if (hasData) {
      chips.add(_ResChip(
        icon: Icons.wifi_rounded,
        label: resources.dataDisplay,
        sublabel: 'Data',
        accentColor: networkColor,
        isProminent: pkg.category == 'internet',
      ));
    }

    // 4. Data Time Window (e.g. '2 AM - 2 PM' or '6 AM - 6 PM')
    if (pkg.dataTimeWindow != null && pkg.dataTimeWindow!.trim().isNotEmpty) {
      chips.add(_ResChip(
        icon: Icons.schedule_rounded,
        label: pkg.dataTimeWindow!,
        sublabel: 'Window',
        accentColor: const Color(0xFF6C5CE7),
      ));
    }

    // 5. Social Apps
    for (final app in pkg.socialApps) {
      chips.add(_SocialAppChip(app: app));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: 6, runSpacing: 6, children: chips);
  }
}

class _ResChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color? accentColor;
  final bool isProminent;

  const _ResChip({
    required this.icon,
    required this.label,
    required this.sublabel,
    this.accentColor,
    this.isProminent = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = accentColor ??
        (isDark ? const Color(0xFF9E9E9E) : const Color(0xFF757575));

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isProminent ? 9 : 8,
        vertical: isProminent ? 6 : 5,
      ),
      decoration: BoxDecoration(
        color: isProminent
            ? color.withOpacity(isDark ? 0.22 : 0.12)
            : (isDark
                ? cs.surfaceContainerHighest.withOpacity(0.6)
                : cs.surfaceContainerHighest.withOpacity(0.7)),
        borderRadius: BorderRadius.circular(20),
        border: isProminent
            ? Border.all(color: color.withOpacity(0.35), width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isProminent ? 13 : 12, color: color),
          const SizedBox(width: 4),
          Text(
            '$label ',
            style: TextStyle(
              fontSize: isProminent ? 11.5 : 11,
              fontWeight: FontWeight.w700,
              color: isProminent ? (isDark ? Colors.white : color) : cs.onSurface,
            ),
          ),
          Text(
            sublabel,
            style: TextStyle(
              fontSize: 9,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? brandColor.withOpacity(0.18)
            : brandColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: brandColor.withOpacity(0.35),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: brandColor),
          const SizedBox(width: 3),
          Text(
            name,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isDark ? brandColor.withOpacity(0.9) : brandColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Detail Bottom Sheet ─────────────────────────────────────────────────────

class _PackageDetailSheet extends StatelessWidget {
  final PackageModel pkg;
  final Color networkColor;

  const _PackageDetailSheet({required this.pkg, required this.networkColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? cs.surfaceContainerHighest : cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [networkColor, networkColor.withOpacity(0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(AppUtils.categoryIcon(pkg.category),
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pkg.name,
                                style: AppTextStyles.titleMedium.copyWith(
                                    color: Colors.white, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 3),
                            Row(children: [
                              _WhiteTag(_subCatLabel(pkg.subCategory)),
                              const SizedBox(width: 6),
                              _WhiteTag(AppUtils.categoryLabel(pkg.category)),
                            ]),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(pkg.priceDisplay,
                              style: AppTextStyles.titleLarge.copyWith(
                                  color: Colors.white, fontWeight: FontWeight.w900)),
                          if (pkg.rechargeRequired != null &&
                              pkg.rechargeRequired! > 0)
                            Text(
                              'Load: Rs. ${pkg.rechargeRequired!.toInt()}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          Text(pkg.validityDisplay,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(20),
                children: [
                  if (pkg.details.isNotEmpty) ...[
                    _SectionTitle('About this Package'),
                    const SizedBox(height: 8),
                    Text(pkg.details,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: cs.onSurface, height: 1.5)),
                    const SizedBox(height: 20),
                  ],
                  _SectionTitle('Resources Included'),
                  const SizedBox(height: 10),
                  _ResourceChips(pkg: pkg, networkColor: networkColor),
                  const SizedBox(height: 20),
                  _SectionTitle('Activation Codes'),
                  const SizedBox(height: 10),
                  _CodeRow(label: 'Activate', code: pkg.activationCode,
                      color: AppColors.success, context: context),
                  if (pkg.deactivationCode.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _CodeRow(label: 'Deactivate', code: pkg.deactivationCode,
                        color: AppColors.error, context: context),
                  ],
                  if (pkg.addons.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SectionTitle('Add-ons'),
                    const SizedBox(height: 8),
                    ...pkg.addons.map((a) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(children: [
                            Icon(Icons.add_circle_outline,
                                size: 15, color: AppColors.info),
                            const SizedBox(width: 8),
                            Text(a.displayLabel,
                                style: AppTextStyles.bodyMedium
                                    .copyWith(color: cs.onSurface)),
                          ]),
                        )),
                  ],
                  if (pkg.extraServices.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SectionTitle('Extra Services'),
                    const SizedBox(height: 8),
                    ...pkg.extraServices.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(children: [
                            Icon(Icons.star_outline,
                                size: 15, color: AppColors.warning),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(s,
                                  style: AppTextStyles.bodyMedium
                                      .copyWith(color: cs.onSurface)),
                            ),
                          ]),
                        )),
                  ],
                  if (pkg.tags.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SectionTitle('Tags'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: pkg.tags
                          .map((t) => _Chip(label: '#$t', color: networkColor))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _subCatLabel(String s) {
    switch (s) {
      case 'daily': return 'Daily';
      case 'weekly': return 'Weekly';
      case 'monthly': return 'Monthly';
      case 'yearly': return 'Yearly';
      default: return s[0].toUpperCase() + s.substring(1);
    }
  }
}

// ─── Shared small widgets ────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _Chip({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 9, color: color.withOpacity(0.7)),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(isDark ? 0.9 : 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _WhiteTag extends StatelessWidget {
  final String label;
  const _WhiteTag(this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
      );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(title.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: cs.onSurfaceVariant,
        ));
  }
}

class _CodeRow extends StatelessWidget {
  final String label;
  final String code;
  final Color color;
  final BuildContext context;

  const _CodeRow({
    required this.label,
    required this.code,
    required this.color,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    return GestureDetector(
      onTap: () => AppUtils.copyToClipboard(context, code, label: label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.dialpad_outlined, size: 16, color: color),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 9,
                        color: color.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5)),
                Text(code,
                    style: TextStyle(
                        fontSize: 15,
                        color: color,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5)),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.phone_in_talk_outlined, size: 16, color: color),
              tooltip: 'Dial code',
              onPressed: () => AppUtils.dialCode(code),
            ),
            IconButton(
              icon: Icon(Icons.copy_outlined,
                  size: 15, color: color.withOpacity(0.6)),
              tooltip: 'Copy code',
              onPressed: () =>
                  AppUtils.copyToClipboard(context, code, label: label),
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeBtn extends StatelessWidget {
  final String label;
  final String code;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _CodeBtn({
    required this.label,
    required this.code,
    required this.icon,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = filled
        ? color.withOpacity(isDark ? 0.18 : 0.1)
        : cs.surfaceContainerHighest.withOpacity(isDark ? 0.5 : 0.6);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: ',
              style: TextStyle(
                fontSize: 9,
                color: (filled ? color : cs.onSurfaceVariant).withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              code,
              style: TextStyle(
                fontSize: 11,
                color: cs.onSurface,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallIconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? tooltip;

  const _SmallIconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    Widget btn = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: color),
      ),
    );
    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: btn);
    }
    return btn;
  }
}

// ─── Share Preview Dialog ─────────────────────────────────────────────────────

class _SharePreviewDialog extends StatelessWidget {
  final GlobalKey repaintKey;
  final PackageModel pkg;
  final Color networkColor;
  final String networkName;
  final bool isDark;
  final Future<void> Function() onShare;

  const _SharePreviewDialog({
    required this.repaintKey,
    required this.pkg,
    required this.networkColor,
    required this.networkName,
    required this.isDark,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RepaintBoundary(
            key: repaintKey,
            child: _ShareCard(
              pkg: pkg,
              networkColor: networkColor,
              networkName: networkName,
              isDark: false,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel', style: TextStyle(color: cs.onSurfaceVariant)),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share_rounded, size: 16),
                label: const Text('Share Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: networkColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShareCard extends StatelessWidget {
  final PackageModel pkg;
  final Color networkColor;
  final String networkName;
  final bool isDark;

  const _ShareCard({
    required this.pkg,
    required this.networkColor,
    required this.networkName,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [networkColor, networkColor.withOpacity(0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          networkName.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          AppUtils.categoryLabel(pkg.category),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    pkg.name,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _WhiteInfoBox(
                        label: 'Price',
                        value: pkg.priceDisplay,
                      ),
                      const SizedBox(width: 8),
                      _WhiteInfoBox(
                        label: 'Validity',
                        value: pkg.validityDisplay,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ResourceRow(resources: pkg.resources, color: networkColor),
                  if (pkg.activationCode.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: networkColor.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: networkColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.dialpad_outlined,
                              size: 16, color: networkColor),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ACTIVATE',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF757575),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                pkg.activationCode,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: networkColor,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'PK Packages App',
                        style: TextStyle(
                          fontSize: 10,
                          color: networkColor.withOpacity(0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhiteInfoBox extends StatelessWidget {
  final String label;
  final String value;
  const _WhiteInfoBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 9, color: Colors.white70, fontWeight: FontWeight.w500)),
          Text(value,
              style: const TextStyle(
                  fontSize: 15, color: Colors.white, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _ResourceRow extends StatelessWidget {
  final ResourceModel resources;
  final Color color;
  const _ResourceRow({required this.resources, required this.color});

  @override
  Widget build(BuildContext context) {
    final items = <Map<String, String>>[];
    if (resources.onNetMinutes != null && resources.onNetMinutes! > 0) {
      items.add({'label': 'On-Net Mins', 'value': '${resources.onNetMinutes}'});
    }
    if (resources.offNetMinutes != null && resources.offNetMinutes! > 0) {
      items.add({'label': 'Off-Net Mins', 'value': '${resources.offNetMinutes}'});
    }
    if (resources.sms != null && resources.sms! > 0) {
      items.add({'label': 'SMS', 'value': '${resources.sms}'});
    }
    final hasData = (resources.dataGb != null && resources.dataGb! > 0) ||
        (resources.dataMb != null && resources.dataMb! > 0);
    if (hasData) {
      items.add({'label': 'Data', 'value': resources.dataDisplay});
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map((item) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withOpacity(0.15)),
                ),
                child: Column(
                  children: [
                    Text(
                      item['value']!,
                      style: TextStyle(
                          fontSize: 16, color: color, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      item['label']!,
                      style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF757575),
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
