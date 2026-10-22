import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/constants/network_constants.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/local/hive_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/sim_service.dart';
import '../../core/utils/app_utils.dart';
import 'widgets/app_drawer.dart';
import 'widgets/network_card.dart';
import 'widgets/featured_carousel.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isRefreshing = false;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    final ts = HiveService.metaBox.get(AppConstants.lastFetchKey) as int?;
    if (ts != null) {
      _lastUpdated = DateTime.fromMillisecondsSinceEpoch(ts);
    }
  }

  String _friendlyError(Object e) {
    final s = e.toString().toLowerCase();
    if (s.contains('timeout') || s.contains('timedout')) {
      return 'Connection timed out. Check your network and try again.';
    }
    if (s.contains('socketexception') || s.contains('connection refused') || s.contains('network')) {
      return 'Cannot reach the server. Make sure you\'re on the same network.';
    }
    if (s.contains('404')) return 'Server endpoint not found (404).';
    if (s.contains('500') || s.contains('internal server')) return 'Server error. Please try again later.';
    if (s.contains('unauthorized') || s.contains('401')) return 'Not authorized. Please sign in again.';
    return 'Could not fetch packages. Please try again.';
  }

  Future<void> _fetchLatest() async {
    if (_isRefreshing) return;
    final repo = ref.read(packageRepositoryProvider);
    setState(() => _isRefreshing = true);
    try {
      if (repo.canRefreshToday()) {
        await repo.refreshAll();
        repo.recordDailyRefresh();
      }
      ref.invalidate(networksProvider);
      ref.invalidate(packagesProvider(null));
      ref.invalidate(recentlyViewedProvider);
      if (mounted) {
        setState(() => _lastUpdated = DateTime.now());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Packages updated successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      ref.invalidate(networksProvider);
      ref.invalidate(packagesProvider(null));
      if (mounted) {
        setState(() => _lastUpdated = DateTime.now());
        final msg = _friendlyError(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final packagesAsync = ref.watch(packagesProvider(null));
    final favCount = ref.watch(favouritesProvider).length;

    final packageCounts = packagesAsync.when(
      data: (packages) {
        final map = <String, int>{};
        for (final p in packages) {
          map[p.networkId] = (map[p.networkId] ?? 0) + 1;
        }
        return map;
      },
      loading: () => <String, int>{},
      error: (_, __) => <String, int>{},
    );

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Text(
              'PK',
              style: AppTextStyles.titleLarge.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              ' Packages',
              style: AppTextStyles.titleLarge.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.manage_search_rounded, color: colorScheme.primary),
            onPressed: () => context.push('/find-package'),
            tooltip: 'Find me a Package',
          ),
          GestureDetector(
            onTap: () => context.push('/favourites'),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: EdgeInsets.fromLTRB(10, 6, favCount > 0 ? 10 : 8, 6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    favCount > 0 ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  if (favCount > 0) ...[
                    const SizedBox(width: 5),
                    Text(
                      '$favCount',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLatest,
        color: colorScheme.primary,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modern Top Status Card
                  _ModernStatusCard(
                    isRefreshing: _isRefreshing,
                    lastUpdated: _lastUpdated,
                    onRefresh: _fetchLatest,
                  ),

                  // Layered 3D Featured Packages Carousel
                  const FeaturedCarousel(),

                  // Free Tricks & Offers Special Section Banner
                  const _FreeOffersBanner(),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Network',
                          style: AppTextStyles.displayMedium.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 100.ms, duration: 400.ms)
                            .slideX(begin: -0.1, end: 0),
                        const SizedBox(height: 4),
                        Text(
                          'Browse packages from Pakistan\'s top networks',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 150.ms, duration: 400.ms),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Network cards — mixed layout
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _NetworkGrid(packageCounts: packageCounts),
              ),
            ),

            // Recently viewed
            const SliverToBoxAdapter(child: _RecentlyViewedSection()),

            // Bottom spacer — includes nav bar height so content isn't hidden behind it
            SliverToBoxAdapter(
              child: SizedBox(
                height: 24 + MediaQuery.of(context).padding.bottom,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NetworkGrid extends ConsumerWidget {
  final Map<String, int> packageCounts;
  const _NetworkGrid({required this.packageCounts});

  void _goToPackages(BuildContext context, NetworkInfo network,
      {String? category}) {
    context.push(
      '/packages/${network.id}',
      extra: {'name': network.name, if (category != null) 'category': category},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networks = NetworkConstants.networks.where((n) => n.id != 'ptcl').toList();
    final simIds = ref.watch(simNetworkIdsProvider).whenOrNull(data: (s) => s) ?? {};
    const gap = 12.0;
    return Column(
      children: List.generate(networks.length, (i) {
        return Padding(
          padding: EdgeInsets.only(bottom: i < networks.length - 1 ? gap : 0),
          child: NetworkCard(
            network: networks[i],
            packageCount: packageCounts[networks[i].id] ?? 0,
            index: i,
            isWide: true,
            hasSim: simIds.contains(networks[i].id),
            onTap: () => _goToPackages(context, networks[i]),
            onCategoryTap: (cat) =>
                _goToPackages(context, networks[i], category: cat),
          ),
        );
      }),
    );
  }
}

class _RecentlyViewedSection extends ConsumerWidget {
  const _RecentlyViewedSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(recentlyViewedProvider);
    if (recent.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
          child: Row(
            children: [
              Text(
                'Recently Viewed',
                style: AppTextStyles.titleMedium.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => ref.read(recentlyViewedProvider.notifier).clear(),
                child: Text(
                  'Clear',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          // network row ~14 + gap 5 + title 34 + gap 6 + footer ~14 + padding 20 = 93
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recent.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final pkg = recent[i];
              final network = NetworkConstants.findById(pkg.networkId);
              final color = network?.brandColor ?? cs.primary;
              return GestureDetector(
                onTap: () => context.push(
                  '/packages/${pkg.networkId}',
                  extra: {'name': network?.name ?? pkg.networkId},
                ),
                child: Container(
                  width: 152,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? cs.surfaceContainerHighest : cs.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Network label
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            network?.name ?? pkg.networkId,
                            style: TextStyle(
                              fontSize: 9,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      // Title — fixed 2-line area
                      SizedBox(
                        height: 34,
                        child: Text(
                          pkg.name,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Price + validity footer
                      Row(
                        children: [
                          Text(
                            pkg.priceDisplay,
                            style: TextStyle(
                              fontSize: 11,
                              color: color,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            pkg.validityDisplay,
                            style: TextStyle(
                              fontSize: 9,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate(delay: Duration(milliseconds: 40 * i))
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: 0.1, end: 0);
            },
          ),
        ),
      ],
    );
  }
}

class _ModernStatusCard extends ConsumerWidget {
  final bool isRefreshing;
  final DateTime? lastUpdated;
  final VoidCallback onRefresh;

  const _ModernStatusCard({
    required this.isRefreshing,
    required this.onRefresh,
    this.lastUpdated,
  });

  String _formatLastUpdated(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d, h:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // SIM card detection
    final simList = ref.watch(simCardDetailsProvider).valueOrNull ?? [];
    final String simLabel;
    if (simList.isNotEmpty) {
      simLabel = 'SIM: ${simList.map((s) => s.carrierLabel.toUpperCase()).join(' & ')}';
    } else {
      simLabel = 'All Pakistan Networks';
    }

    // Packages count
    final allPackages = ref.watch(packagesProvider(null)).valueOrNull ?? [];
    final totalCount = allPackages.isNotEmpty ? allPackages.length : 36;

    final updatedStr = lastUpdated != null
        ? 'Updated ${_formatLastUpdated(lastUpdated!)}'
        : 'All packages ready offline';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  cs.primary.withValues(alpha: 0.18),
                  cs.surfaceContainerHighest,
                ]
              : [
                  cs.primary.withValues(alpha: 0.10),
                  cs.surface,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cs.primary.withValues(alpha: isDark ? 0.35 : 0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: isDark ? 0.16 : 0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Active SIM or all networks badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      simList.isNotEmpty
                          ? Icons.sim_card_rounded
                          : Icons.cell_tower_rounded,
                      size: 15,
                      color: cs.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      simLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Modern refresh button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isRefreshing
                      ? null
                      : () {
                          AppUtils.hapticLight();
                          onRefresh();
                        },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isRefreshing)
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        else
                          const Icon(
                            Icons.refresh_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        const SizedBox(width: 6),
                        Text(
                          isRefreshing ? 'Syncing...' : 'Refresh',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Bottom stats info row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? cs.surfaceContainerHighest.withValues(alpha: 0.6)
                  : cs.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 15,
                  color: cs.primary,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '$totalCount Packages',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.sync_rounded,
                  size: 13,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 4),
                Text(
                  updatedStr,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: -0.1, end: 0, curve: Curves.easeOut);
  }
}

class _FreeOffersBanner extends StatelessWidget {
  const _FreeOffersBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        context.push(
          '/packages/all',
          extra: {'name': 'Free Offers', 'category': 'free'},
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 14, 16, 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF1E3A2F),
                    const Color(0xFF142820),
                  ]
                : [
                    const Color(0xFFE8F5E9),
                    const Color(0xFFC8E6C9),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: const Color(0xFF2E7D32).withValues(alpha: isDark ? 0.4 : 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D32).withValues(alpha: isDark ? 0.2 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                color: Color(0xFF2E7D32),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Free Tricks & Offers',
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '100% FREE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'SIM Lagao, Free WhatsApp, Tamasha MBs & Zero-Balance Tricks',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? Colors.white70
                          : const Color(0xFF2E7D32).withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color:
                    const Color(0xFF2E7D32).withValues(alpha: isDark ? 0.3 : 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}
