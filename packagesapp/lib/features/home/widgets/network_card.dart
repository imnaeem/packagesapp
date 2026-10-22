import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/network_constants.dart';
import '../../../core/theme/app_text_styles.dart';

class NetworkCard extends StatelessWidget {
  final NetworkInfo network;
  final int packageCount;
  final VoidCallback onTap;
  final void Function(String category) onCategoryTap;
  final int index;
  final bool isWide;
  final bool hasSim;

  const NetworkCard({
    super.key,
    required this.network,
    required this.packageCount,
    required this.onTap,
    required this.onCategoryTap,
    required this.index,
    this.isWide = false,
    this.hasSim = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = network.brandColor;
    final colorDark = network.brandColorDark;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: BoxConstraints(minHeight: isWide ? 88 : 140),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: isDark
                  ? [colorDark.withOpacity(0.3), colorDark.withOpacity(0.08)]
                  : [color.withOpacity(0.12), color.withOpacity(0.03)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: color.withOpacity(isDark ? 0.3 : 0.2),
              width: 1.2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Decorative circles (non-interactive)
                Positioned(
                  right: -20,
                  top: -20,
                  child: IgnorePointer(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.08),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: -15,
                  bottom: -25,
                  child: IgnorePointer(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.06),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(12),
                  child: isWide
                      ? _WideLayout(network: network, packageCount: packageCount, color: color, onCategoryTap: onCategoryTap)
                      : _SquareLayout(network: network, packageCount: packageCount, color: color, onCategoryTap: onCategoryTap),
                ),

                // SIM detected badge
                if (hasSim)
                  Positioned(
                    top: 8,
                    right: 10,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sim_card_rounded, size: 10, color: Colors.white),
                            const SizedBox(width: 3),
                            const Text(
                              'SIM',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 80 * index))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.15, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}

class _SquareLayout extends StatelessWidget {
  final NetworkInfo network;
  final int packageCount;
  final Color color;
  final void Function(String) onCategoryTap;

  const _SquareLayout({
    required this.network,
    required this.packageCount,
    required this.color,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LogoBadge(network: network, color: color, size: 52),
            const Spacer(),
            if (packageCount > 0) _CountBadge(count: packageCount, color: color),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          network.name,
          style: AppTextStyles.titleMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          network.slogan,
          style: AppTextStyles.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _QuickIcon(
              icon: Icons.phone_outlined,
              color: color,
              tooltip: 'Call',
              onTap: () => onCategoryTap('call'),
            ),
            const SizedBox(width: 6),
            _QuickIcon(
              icon: Icons.chat_bubble_outline,
              color: color,
              tooltip: 'SMS',
              onTap: () => onCategoryTap('sms'),
            ),
            const SizedBox(width: 6),
            _QuickIcon(
              icon: Icons.wifi_outlined,
              color: color,
              tooltip: 'Internet',
              onTap: () => onCategoryTap('internet'),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: color.withOpacity(0.5),
            ),
          ],
        ),
      ],
    );
  }
}

class _WideLayout extends StatelessWidget {
  final NetworkInfo network;
  final int packageCount;
  final Color color;
  final void Function(String) onCategoryTap;

  const _WideLayout({
    required this.network,
    required this.packageCount,
    required this.color,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LogoBadge(network: network, color: color, size: 50),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    network.name,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (packageCount > 0)
                    _CountBadge(count: packageCount, color: color),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                network.slogan,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _QuickIcon(
                    icon: Icons.phone_outlined,
                    color: color,
                    tooltip: 'Call',
                    onTap: () => onCategoryTap('call'),
                  ),
                  const SizedBox(width: 6),
                  _QuickIcon(
                    icon: Icons.chat_bubble_outline,
                    color: color,
                    tooltip: 'SMS',
                    onTap: () => onCategoryTap('sms'),
                  ),
                  const SizedBox(width: 6),
                  _QuickIcon(
                    icon: Icons.wifi_outlined,
                    color: color,
                    tooltip: 'Internet',
                    onTap: () => onCategoryTap('internet'),
                  ),
                  const SizedBox(width: 6),
                  _QuickIcon(
                    icon: Icons.layers_outlined,
                    color: color,
                    tooltip: 'Hybrid',
                    onTap: () => onCategoryTap('hybrid'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: color.withOpacity(0.5),
        ),
      ],
    );
  }
}

class _LogoBadge extends StatelessWidget {
  final NetworkInfo network;
  final Color color;
  final double size;

  const _LogoBadge({required this.network, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Image.asset(
        network.logoAsset,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Center(
          child: Text(
            network.name[0],
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: size * 0.4,
            ),
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final Color color;

  const _CountBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count pkgs',
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _QuickIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _QuickIcon({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          splashColor: color.withOpacity(0.3),
          child: SizedBox(
            width: 30,
            height: 30,
            child: Icon(icon, size: 15, color: color),
          ),
        ),
      ),
    );
  }
}
