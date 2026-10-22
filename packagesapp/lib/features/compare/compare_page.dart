import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/network_constants.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_utils.dart';
import '../../models/package_model.dart';

class ComparePage extends ConsumerWidget {
  const ComparePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packages = ref.watch(compareProvider);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Compare Packages'),
        actions: [
          if (packages.isNotEmpty)
            TextButton(
              onPressed: () {
                ref.read(compareProvider.notifier).clear();
                Navigator.of(context).pop();
              },
              child: Text(
                'Clear',
                style: TextStyle(color: cs.error),
              ),
            ),
        ],
      ),
      body: packages.isEmpty
          ? _EmptyCompare(cs: cs)
          : _CompareTable(packages: packages, isDark: isDark, cs: cs),
    );
  }
}

// ─── Empty state ─────────────────────────────────────────────────────────────

class _EmptyCompare extends StatelessWidget {
  final ColorScheme cs;
  const _EmptyCompare({required this.cs});

  @override
  Widget build(BuildContext context) {
    final networks = NetworkConstants.networks.where((n) => n.id != 'ptcl').toList();
    final navBottom = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 32, 20, 24 + navBottom),
      child: Column(
        children: [
          // Icon + heading
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.compare_arrows_rounded,
              size: 36,
              color: cs.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No packages selected',
            style: AppTextStyles.titleMedium.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Open any network below, tap the  icon on packages to select up to $kMaxCompare, then come back here.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 6),
          // Compare icon inline hint
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.compare_arrows_rounded, size: 14, color: cs.primary),
              const SizedBox(width: 4),
              Text(
                'Look for this icon on each package card',
                style: AppTextStyles.caption.copyWith(color: cs.primary),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // How it works steps
          _HowItWorksCard(cs: cs),

          const SizedBox(height: 24),

          // Network shortcuts
          Text(
            'Browse a network to get started',
            style: AppTextStyles.labelSmall.copyWith(
              color: cs.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ...networks.map((n) => _NetworkShortcut(network: n, cs: cs)),
        ],
      ),
    );
  }
}

class _HowItWorksCard extends StatelessWidget {
  final ColorScheme cs;
  const _HowItWorksCard({required this.cs});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final steps = [
      (Icons.open_in_new_rounded, 'Open a network from the list below'),
      (Icons.compare_arrows_rounded, 'Tap  on up to $kMaxCompare packages'),
      (Icons.check_circle_outline_rounded, 'Return here to see the comparison'),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainerHighest.withOpacity(0.4) : cs.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HOW IT WORKS',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: cs.primary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 10),
          ...steps.asMap().entries.map((e) => Padding(
                padding: EdgeInsets.only(bottom: e.key < steps.length - 1 ? 8 : 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${e.key + 1}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: cs.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          e.value.$2,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _NetworkShortcut extends StatelessWidget {
  final NetworkInfo network;
  final ColorScheme cs;
  const _NetworkShortcut({required this.network, required this.cs});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = network.brandColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            AppUtils.hapticLight();
            context.push(
              '/packages/${network.id}',
              extra: {'name': network.name},
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: isDark
                  ? color.withOpacity(0.1)
                  : color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(5),
                  child: Image.asset(
                    network.logoAsset,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        network.name[0],
                        style: TextStyle(color: color, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        network.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        network.slogan,
                        style: AppTextStyles.caption.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 13, color: color.withOpacity(0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Comparison table ────────────────────────────────────────────────────────

class _CompareTable extends ConsumerWidget {
  final List<PackageModel> packages;
  final bool isDark;
  final ColorScheme cs;

  const _CompareTable({
    required this.packages,
    required this.isDark,
    required this.cs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = packages
        .map((p) => NetworkConstants.findById(p.networkId)?.brandColor ?? cs.primary)
        .toList();

    return Column(
      children: [
        // Package header row (sticky)
        _HeaderRow(packages: packages, colors: colors, isDark: isDark, cs: cs),

        // Scrollable comparison rows
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: 24 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              children: [
                _SectionLabel('Pricing & Validity', cs: cs, showTopDivider: false),
                _CompareRow(
                  label: 'Price',
                  icon: null,
                  customLabel: 'PKR',
                  values: packages.map((p) => p.priceDisplay).toList(),
                  colors: colors,
                  highlight: _minIndex(packages.map((p) => p.price).toList()),
                  highlightLabel: 'Cheapest',
                  cs: cs,
                  isDark: isDark,
                ),
                _CompareRow(
                  label: 'Validity',
                  icon: Icons.timer_outlined,
                  values: packages.map((p) => p.validityDisplay).toList(),
                  colors: colors,
                  highlight: _maxIndex(packages.map((p) => p.validityDays.toDouble()).toList()),
                  highlightLabel: 'Longest',
                  cs: cs,
                  isDark: isDark,
                ),
                _CompareRow(
                  label: 'Category',
                  icon: Icons.category_outlined,
                  values: packages.map((p) => AppUtils.categoryLabel(p.category)).toList(),
                  colors: colors,
                  cs: cs,
                  isDark: isDark,
                ),

                _SectionLabel('Data', cs: cs),
                _CompareRow(
                  label: 'Internet',
                  icon: Icons.wifi_rounded,
                  values: packages.map((p) => p.resources.dataDisplay).toList(),
                  colors: colors,
                  highlight: _maxDataIndex(packages),
                  highlightLabel: 'Most Data',
                  cs: cs,
                  isDark: isDark,
                ),

                _SectionLabel('Calls', cs: cs),
                _CompareRow(
                  label: 'On-Net Mins',
                  icon: Icons.phone_outlined,
                  values: packages
                      .map((p) => p.resources.onNetMinutes != null && p.resources.onNetMinutes! > 0
                          ? '${p.resources.onNetMinutes} Mins'
                          : '—')
                      .toList(),
                  colors: colors,
                  highlight: _maxIndex(
                      packages.map((p) => (p.resources.onNetMinutes ?? 0).toDouble()).toList()),
                  highlightLabel: 'Most',
                  cs: cs,
                  isDark: isDark,
                ),
                _CompareRow(
                  label: 'Off-Net Mins',
                  icon: Icons.phone_forwarded_outlined,
                  values: packages
                      .map((p) => p.resources.offNetMinutes != null && p.resources.offNetMinutes! > 0
                          ? '${p.resources.offNetMinutes} Mins'
                          : '—')
                      .toList(),
                  colors: colors,
                  highlight: _maxIndex(
                      packages.map((p) => (p.resources.offNetMinutes ?? 0).toDouble()).toList()),
                  highlightLabel: 'Most',
                  cs: cs,
                  isDark: isDark,
                ),

                _SectionLabel('SMS', cs: cs),
                _CompareRow(
                  label: 'SMS',
                  icon: Icons.chat_bubble_outline,
                  values: packages
                      .map((p) => p.resources.sms != null && p.resources.sms! > 0
                          ? '${p.resources.sms} SMS'
                          : '—')
                      .toList(),
                  colors: colors,
                  highlight: _maxIndex(
                      packages.map((p) => (p.resources.sms ?? 0).toDouble()).toList()),
                  highlightLabel: 'Most',
                  cs: cs,
                  isDark: isDark,
                ),

                _SectionLabel('Value', cs: cs),
                _CompareRow(
                  label: 'Price/Day',
                  icon: Icons.trending_down_rounded,
                  values: packages.map((p) {
                    if (p.validityDays <= 0) return '—';
                    final perDay = p.price / p.validityDays;
                    return 'Rs. ${perDay.toStringAsFixed(1)}';
                  }).toList(),
                  colors: colors,
                  highlight: _minIndex(packages.map((p) {
                    if (p.validityDays <= 0) return double.infinity;
                    return p.price / p.validityDays;
                  }).toList()),
                  highlightLabel: 'Best',
                  cs: cs,
                  isDark: isDark,
                ),

                _SectionLabel('Activation', cs: cs),
                _DialRow(
                  label: 'Activate',
                  icon: Icons.phone_callback_outlined,
                  packages: packages,
                  colors: colors,
                  getCode: (p) => p.activationCode,
                  cs: cs,
                  isDark: isDark,
                ),
                _DialRow(
                  label: 'Deactivate',
                  icon: Icons.phone_disabled_outlined,
                  packages: packages,
                  colors: colors,
                  getCode: (p) => p.deactivationCode,
                  cs: cs,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  int? _minIndex(List<double> values) {
    if (values.every((v) => v == 0 || v == double.infinity)) return null;
    final filtered = values.where((v) => v > 0 && v != double.infinity).toList();
    if (filtered.isEmpty) return null;
    final min = filtered.reduce((a, b) => a < b ? a : b);
    final idx = values.indexOf(min);
    // Only highlight if not all equal
    return values.where((v) => v == min).length == values.length ? null : idx;
  }

  int? _maxIndex(List<double> values) {
    if (values.every((v) => v == 0)) return null;
    final max = values.reduce((a, b) => a > b ? a : b);
    if (max == 0) return null;
    final idx = values.indexOf(max);
    return values.where((v) => v == max).length == values.length ? null : idx;
  }

  int? _maxDataIndex(List<PackageModel> pkgs) {
    final mbs = pkgs.map((p) {
      if (p.resources.dataGb != null && p.resources.dataGb! > 0) {
        return p.resources.dataGb! * 1024;
      }
      return (p.resources.dataMb ?? 0).toDouble();
    }).toList();
    return _maxIndex(mbs);
  }
}

// ─── Header row ──────────────────────────────────────────────────────────────

class _HeaderRow extends ConsumerWidget {
  final List<PackageModel> packages;
  final List<Color> colors;
  final bool isDark;
  final ColorScheme cs;

  const _HeaderRow({
    required this.packages,
    required this.colors,
    required this.isDark,
    required this.cs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainerHighest : cs.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Label column spacer
          const SizedBox(width: 110),
          ...List.generate(packages.length, (i) {
            final pkg = packages[i];
            final color = colors[i];
            final network = NetworkConstants.findById(pkg.networkId);
            return Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(4, 10, 4, 10),
                    padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(isDark ? 0.15 : 0.07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color.withOpacity(0.25)),
                    ),
                    child: Column(
                      children: [
                        // Network dot + name
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              network?.name ?? pkg.networkId,
                              style: TextStyle(
                                fontSize: 9,
                                color: color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          pkg.name,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          pkg.priceDisplay,
                          style: TextStyle(
                            fontSize: 13,
                            color: color,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Remove button
                  Positioned(
                    top: 4,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        AppUtils.hapticLight();
                        ref.read(compareProvider.notifier).remove(pkg.id);
                      },
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          shape: BoxShape.circle,
                          border: Border.all(color: cs.outline.withOpacity(0.2)),
                        ),
                        child: Icon(Icons.close_rounded, size: 11, color: cs.onSurfaceVariant),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Section label ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final ColorScheme cs;
  final bool showTopDivider;
  const _SectionLabel(this.label, {required this.cs, this.showTopDivider = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTopDivider)
          Divider(height: 1, thickness: 1, color: cs.outline.withOpacity(0.15)),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 3),
          child: Row(
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: cs.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Divider(height: 1, color: cs.outline.withOpacity(0.15))),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Compare row ─────────────────────────────────────────────────────────────

class _CompareRow extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? customLabel; // shown instead of icon (e.g. "PKR")
  final List<String> values;
  final List<Color> colors;
  final int? highlight;
  final String? highlightLabel;
  final ColorScheme cs;
  final bool isDark;

  const _CompareRow({
    required this.label,
    this.icon,
    this.customLabel,
    required this.values,
    required this.colors,
    this.highlight,
    this.highlightLabel,
    required this.cs,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainerHighest.withOpacity(0.3) : cs.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label column
          SizedBox(
            width: 108,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              child: Row(
                children: [
                  if (customLabel != null)
                    Text(
                      customLabel!,
                      style: TextStyle(
                        fontSize: 9,
                        color: cs.onSurfaceVariant.withOpacity(0.6),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    )
                  else if (icon != null)
                    Icon(icon, size: 12, color: cs.onSurfaceVariant.withOpacity(0.6)),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Value cells
          ...List.generate(values.length, (i) {
            final isBest = highlight == i;
            final color = colors[i];
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                decoration: BoxDecoration(
                  color: isBest
                      ? color.withOpacity(isDark ? 0.2 : 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  border: isBest ? Border.all(color: color.withOpacity(0.35)) : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      values[i],
                      style: TextStyle(
                        fontSize: 11,
                        color: isBest ? color : cs.onSurface,
                        fontWeight: isBest ? FontWeight.w800 : FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (isBest && highlightLabel != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        highlightLabel!,
                        style: TextStyle(
                          fontSize: 7,
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Dial row (activation / deactivation) ────────────────────────────────────

class _DialRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<PackageModel> packages;
  final List<Color> colors;
  final String Function(PackageModel) getCode;
  final ColorScheme cs;
  final bool isDark;

  const _DialRow({
    required this.label,
    required this.icon,
    required this.packages,
    required this.colors,
    required this.getCode,
    required this.cs,
    required this.isDark,
  });

  Future<void> _dial(String code) async {
    AppUtils.dialCode(code);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainerHighest.withOpacity(0.3) : cs.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 108,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              child: Row(
                children: [
                  Icon(icon, size: 12, color: cs.onSurfaceVariant.withOpacity(0.6)),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ...List.generate(packages.length, (i) {
            final code = getCode(packages[i]);
            final color = colors[i];
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                child: code.isEmpty
                    ? Center(
                        child: Text('—',
                            style: TextStyle(
                                fontSize: 12, color: cs.onSurfaceVariant.withOpacity(0.4))),
                      )
                    : GestureDetector(
                        onTap: () => _dial(code),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                          decoration: BoxDecoration(
                            color: color.withOpacity(isDark ? 0.18 : 0.09),
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(color: color.withOpacity(0.25)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                code,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: color,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 2),
                              Icon(Icons.phone_rounded, size: 9, color: color.withOpacity(0.6)),
                            ],
                          ),
                        ),
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
