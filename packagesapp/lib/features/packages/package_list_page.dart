import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/network_constants.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_utils.dart';
import 'widgets/package_card.dart';

class PackageListPage extends ConsumerStatefulWidget {
  final String networkId;
  final String networkName;
  final String? initialCategory;

  const PackageListPage({
    super.key,
    required this.networkId,
    required this.networkName,
    this.initialCategory,
  });

  @override
  ConsumerState<PackageListPage> createState() => _PackageListPageState();
}

class _PackageListPageState extends ConsumerState<PackageListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(packageFilterProvider(widget.networkId).notifier).reset();
      if (widget.initialCategory != null) {
        ref
            .read(packageFilterProvider(widget.networkId).notifier)
            .setCategory(widget.initialCategory!);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final repo = ref.read(packageRepositoryProvider);
    try {
      if (repo.canRefreshToday()) {
        await repo.refreshAll();
        repo.recordDailyRefresh();
      }
      ref.invalidate(packagesProvider(widget.networkId));
      ref.invalidate(packagesProvider(null));
      ref.invalidate(networksProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Packages updated!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (_) {
      ref.invalidate(packagesProvider(widget.networkId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Showing latest cached packages.',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final networkInfo = NetworkConstants.findById(widget.networkId);
    final networkColor = networkInfo?.brandColor ?? colorScheme.primary;
    final filter = ref.watch(packageFilterProvider(widget.networkId));
    final filterNotifier = ref.read(packageFilterProvider(widget.networkId).notifier);
    final packagesAsync = ref.watch(packagesProvider(widget.networkId));
    final filteredPackages = ref.watch(filteredPackagesProvider(widget.networkId));

    final compareList = ref.watch(compareProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            if (networkInfo != null)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(3),
                child: Image.asset(
                  networkInfo.logoAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              )
            else
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: networkColor.withValues(alpha: 0.15),
                ),
                child: Icon(
                  Icons.card_giftcard_rounded,
                  size: 18,
                  color: networkColor,
                ),
              ),
            const SizedBox(width: 8),
            Text(widget.networkName),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Tinted background with random shapes from category color
          _CategoryBackground(color: networkColor, category: filter.category),

          Column(
            children: [
              // Top controls panel with rounded bottom + shadow
              Material(
                elevation: 3,
                shadowColor: Colors.black.withOpacity(0.12),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                color: colorScheme.surface,
                child: Column(
                  children: [
                    // Category segmented filter
                    _CategorySegment(
                      selected: filter.category,
                      onSelect: filterNotifier.setCategory,
                      networkColor: networkColor,
                    ),

                    // Sort + count bar
                    _SortCountBar(
                      sortField: filter.sortField,
                      ascending: filter.ascending,
                      onSortChange: filterNotifier.setSortField,
                      onToggleOrder: filterNotifier.toggleOrder,
                      onlyBest: filter.onlyBest,
                      onToggleBest: filterNotifier.toggleOnlyBest,
                      count: packagesAsync.when(
                        data: (_) => filteredPackages.length,
                        loading: () => null,
                        error: (_, __) => null,
                      ),
                      networkColor: networkColor,
                    ),

                    // Search bar (always visible)
                    _SearchBar(
                      controller: _searchController,
                      onChanged: filterNotifier.setSearch,
                      onClear: () {
                        _searchController.clear();
                        filterNotifier.setSearch('');
                      },
                      networkColor: networkColor,
                    ),

                    const SizedBox(height: 6),
                  ],
                ),
              ),

              // Packages list
              Expanded(
                child: packagesAsync.when(
                  loading: () => _ShimmerList(color: networkColor),
                  error: (err, _) => _ErrorView(
                    message: err.toString(),
                    onRetry: () =>
                        ref.invalidate(packagesProvider(widget.networkId)),
                  ),
                  data: (_) {
                    if (filteredPackages.isEmpty) {
                      return _EmptyView(category: filter.category);
                    }
                    final navBottom = MediaQuery.of(context).padding.bottom;
                    return ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        14,
                        8,
                        14,
                        compareList.isNotEmpty
                            ? 88 + navBottom
                            : 24 + navBottom,
                      ),
                      itemCount: filteredPackages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return PackageCard(
                          package: filteredPackages[index],
                          networkColor: networkColor,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // Floating compare bar
          if (compareList.isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16 + MediaQuery.of(context).padding.bottom,
              child: _CompareBar(
                packages: compareList,
                networkColor: networkColor,
                onCompare: () => context.push('/compare'),
                onClear: () => ref.read(compareProvider.notifier).clear(),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Compare floating bar ─────────────────────────────────────────────────────

class _CompareBar extends StatelessWidget {
  final List<dynamic> packages;
  final Color networkColor;
  final VoidCallback onCompare;
  final VoidCallback onClear;

  const _CompareBar({
    required this.packages,
    required this.networkColor,
    required this.onCompare,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      elevation: 12,
      borderRadius: BorderRadius.circular(18),
      shadowColor: networkColor.withOpacity(0.3),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
        decoration: BoxDecoration(
          color: isDark ? cs.surfaceContainerHighest : cs.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: networkColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.compare_arrows_rounded, size: 18, color: networkColor),
            const SizedBox(width: 8),
            Text(
              '${packages.length} selected',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: onClear,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('Clear',
                  style: TextStyle(
                      color: cs.onSurfaceVariant, fontSize: 12)),
            ),
            const SizedBox(width: 6),
            ElevatedButton(
              onPressed: packages.length >= 2 ? onCompare : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: networkColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                packages.length < 2 ? 'Add 1 more' : 'Compare',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Background ──────────────────────────────────────────────────────────────

class _CategoryBackground extends StatelessWidget {
  final Color color;
  final String category;

  const _CategoryBackground({required this.color, required this.category});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned.fill(
      child: CustomPaint(
        painter: _BgPainter(color: color, isDark: isDark),
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  final Color color;
  final bool isDark;

  _BgPainter({required this.color, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final opacity = isDark ? 0.05 : 0.06;

    final shapes = [
      // Large circle top-right
      (Offset(size.width * 0.88, -size.height * 0.04), size.width * 0.36, opacity * 1.4),
      // Medium circle mid-left
      (Offset(-size.width * 0.08, size.height * 0.35), size.width * 0.28, opacity),
      // Small circle bottom-right
      (Offset(size.width * 0.92, size.height * 0.72), size.width * 0.22, opacity * 1.2),
      // Tiny circle mid
      (Offset(size.width * 0.5, size.height * 0.55), size.width * 0.12, opacity * 0.8),
    ];

    for (final s in shapes) {
      paint.color = color.withOpacity(s.$3);
      canvas.drawCircle(s.$1, s.$2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BgPainter old) =>
      old.color != color || old.isDark != isDark;
}

// ─── Category Segment ────────────────────────────────────────────────────────

class _CategorySegment extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  final Color networkColor;

  const _CategorySegment({
    required this.selected,
    required this.onSelect,
    required this.networkColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categories = AppConstants.packageCategories;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: categories.map((cat) {
            final isSelected = cat == selected;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: GestureDetector(
                onTap: () => onSelect(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? networkColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppUtils.categoryIcon(cat),
                        size: 15,
                        color: isSelected
                            ? Colors.white
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        cat == 'all' ? 'All' : AppUtils.categoryLabel(cat),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : colorScheme.onSurfaceVariant,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Sort + Count Bar ────────────────────────────────────────────────────────

class _SortCountBar extends StatelessWidget {
  final String sortField;
  final bool ascending;
  final ValueChanged<String> onSortChange;
  final VoidCallback onToggleOrder;
  final bool onlyBest;
  final VoidCallback onToggleBest;
  final int? count;
  final Color networkColor;

  const _SortCountBar({
    required this.sortField,
    required this.ascending,
    required this.onSortChange,
    required this.onToggleOrder,
    required this.onlyBest,
    required this.onToggleBest,
    required this.count,
    required this.networkColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            // Package count pill
            if (count != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: networkColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count packages',
                  style: AppTextStyles.caption.copyWith(
                    color: networkColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: 8),

            // ⭐ Best Offers filter chip / toggle button
            GestureDetector(
              onTap: () {
                AppUtils.hapticLight();
                onToggleBest();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: onlyBest
                      ? const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.25 : 0.15)
                      : (isDark
                          ? colorScheme.surfaceContainerHighest
                          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.7)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: onlyBest
                        ? const Color(0xFFF59E0B)
                        : colorScheme.outline.withValues(alpha: 0.2),
                    width: onlyBest ? 1.4 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '⭐ Best Offers',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: onlyBest ? FontWeight.w700 : FontWeight.w600,
                        color: onlyBest
                            ? (isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706))
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Sort label
            Text(
              'Sort:',
              style: AppTextStyles.caption.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 6),
            _SortChip(
              label: 'Price',
              isSelected: sortField == 'price',
              color: networkColor,
              onTap: () => onSortChange('price'),
            ),
            const SizedBox(width: 4),
            _SortChip(
              label: 'Days',
              isSelected: sortField == 'validity',
              color: networkColor,
              onTap: () => onSortChange('validity'),
            ),
            const SizedBox(width: 4),
            // Asc/Desc toggle
            GestureDetector(
              onTap: onToggleOrder,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: colorScheme.outline.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Icon(
                      ascending
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      ascending ? 'Asc' : 'Des',
                      style: AppTextStyles.caption.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected ? color : colorScheme.outline.withOpacity(0.25),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected ? color : colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ─── Search Bar ──────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final Color networkColor;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.networkColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 2),
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: isDark
              ? colorScheme.surfaceContainerHighest
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(Icons.search_rounded, size: 17,
                color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                autofocus: false,
                onChanged: onChanged,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Search packages...',
                  hintStyle: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            ListenableBuilder(
              listenable: controller,
              builder: (_, __) => controller.text.isNotEmpty
                  ? GestureDetector(
                      onTap: onClear,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.close_rounded,
                            size: 16,
                            color: colorScheme.onSurfaceVariant),
                      ),
                    )
                  : const SizedBox(width: 10),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shimmer ─────────────────────────────────────────────────────────────────

class _ShimmerList extends StatelessWidget {
  final Color color;
  const _ShimmerList({required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade50,
      child: ListView.separated(
        padding: const EdgeInsets.all(14),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => Container(
          height: 190,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

// ─── Empty / Error ────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final String category;
  const _EmptyView({required this.category});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isSearch = category == 'all';
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearch ? Icons.search_off_rounded : AppUtils.categoryIcon(category),
                size: 38,
                color: cs.onSurfaceVariant.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isSearch ? 'No packages found' : 'No ${AppUtils.categoryLabel(category)} packages',
              style: AppTextStyles.titleMedium.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isSearch
                  ? 'Try adjusting your search or clear filters'
                  : 'There are no packages in this category yet.\nTry refreshing or selecting another category.',
              style: AppTextStyles.bodySmall.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.cloud_off_outlined,
                  size: 38, color: AppColors.error.withOpacity(0.6)),
            ),
            const SizedBox(height: 20),
            Text(
              'Could not load packages',
              style: AppTextStyles.titleMedium.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
