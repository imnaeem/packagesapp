import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/network_constants.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_utils.dart';
import '../../../models/package_model.dart';

class FeaturedCarousel extends ConsumerStatefulWidget {
  const FeaturedCarousel({super.key});

  @override
  ConsumerState<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends ConsumerState<FeaturedCarousel> {
  static const int _infiniteMultiplier = 1000;
  late final PageController _pageController;
  Timer? _timer;
  int _currentPageIndex = 0;
  int _initialPage = 0;
  bool _isUserScrolling = false;

  @override
  void initState() {
    super.initState();
    // Default controller, will configure initial page once packages load
    _pageController = PageController(viewportFraction: 0.88);
  }

  void _setupAutoScroll(int totalCount) {
    if (totalCount <= 1 || _timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_isUserScrolling && _pageController.hasClients) {
        final nextPage = (_pageController.page?.round() ?? _initialPage) + 1;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final packages = ref.watch(featuredPackagesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (packages.isEmpty) {
      return const SizedBox.shrink();
    }

    final int totalCount = packages.length;
    final int itemCount = totalCount > 1 ? totalCount * _infiniteMultiplier : 1;

    // Center the initial page for infinite scroll
    if (totalCount > 1 && _initialPage == 0) {
      _initialPage = (itemCount ~/ 2) - ((itemCount ~/ 2) % totalCount);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_initialPage);
        }
        _setupAutoScroll(totalCount);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Top & Featured Packages',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Best Value',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3D Layered Carousel
        SizedBox(
          height: 195,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                _isUserScrolling = true;
              } else if (notification is ScrollEndNotification) {
                _isUserScrolling = false;
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: itemCount,
              onPageChanged: (pageIndex) {
                setState(() {
                  _currentPageIndex = pageIndex % totalCount;
                });
              },
              itemBuilder: (context, index) {
                final pkg = packages[index % totalCount];
                final networkInfo = NetworkConstants.findById(pkg.networkId);

                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 0.0;
                    if (_pageController.position.haveDimensions) {
                      value = (_pageController.page! - index);
                    } else {
                      value = (index - _initialPage).toDouble();
                    }
                    final absDiff = value.abs().clamp(0.0, 1.0);
                    // 0.92 to 1.0 subtle layered scale transform
                    final scale = 1.0 - (absDiff * 0.08);

                    return Transform.scale(
                      scale: scale,
                      alignment: Alignment.center,
                      child: child,
                    );
                  },
                  child: _CarouselCard(
                    package: pkg,
                    network: networkInfo,
                    onTap: () => context.push('/package/${pkg.id}'),
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Dot indicators
        if (totalCount > 1)
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(totalCount, (idx) {
                final isActive = idx == _currentPageIndex;
                final activePkg = packages[_currentPageIndex];
                final brandColor =
                    NetworkConstants.findById(activePkg.networkId)?.brandColor ??
                        colorScheme.primary;

                return GestureDetector(
                  onTap: () {
                    final current = _pageController.page?.round() ?? _initialPage;
                    final target = current + (idx - (current % totalCount));
                    _pageController.animateToPage(
                      target,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? brandColor
                          : colorScheme.outline.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _CarouselCard extends StatelessWidget {
  final PackageModel package;
  final NetworkInfo? network;
  final VoidCallback onTap;

  const _CarouselCard({
    required this.package,
    required this.network,
    required this.onTap,
  });

  String _buildHighlights() {
    final parts = <String>[];
    if (package.resources.dataDisplay != '—') {
      parts.add('${package.resources.dataDisplay} Data');
    }
    if (package.resources.callDisplay != '—') {
      parts.add(package.resources.callDisplay);
    }
    if (package.resources.smsDisplay != '—') {
      parts.add(package.resources.smsDisplay);
    }
    if (parts.isEmpty) {
      if (package.extraServices.isNotEmpty) {
        return package.extraServices.first;
      }
      return package.validityDisplay;
    }
    return parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final brandColor = network?.brandColor ?? cs.primary;
    final highlights = _buildHighlights();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: isDark
                ? [
                    cs.surfaceContainerHigh,
                    cs.surfaceContainerHighest,
                  ]
                : [
                    Colors.white,
                    brandColor.withValues(alpha: 0.04),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: brandColor.withValues(alpha: isDark ? 0.35 : 0.2),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: brandColor.withValues(alpha: isDark ? 0.25 : 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Network Badge + Validity Chip + Price Badge
            Row(
              children: [
                // Network badge with brand color
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: brandColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: brandColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: brandColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        network?.name ?? package.networkId.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: brandColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                // Validity chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 11,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        package.validityDisplay,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Price badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: brandColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    package.priceDisplay,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            // Package Name
            Text(
              package.name,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Bottom Row: Primary Highlights + Quick Activate Button
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        size: 16,
                        color: brandColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          highlights,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Quick Activate Button
                ElevatedButton.icon(
                  onPressed: () => AppUtils.dialCode(package.activationCode),
                  icon: const Icon(Icons.phone_rounded, size: 14),
                  label: const Text('Activate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    visualDensity: VisualDensity.compact,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
