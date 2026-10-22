import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/network_constants.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_text_styles.dart';
import '../packages/widgets/package_card.dart';

class FavouritesPage extends ConsumerWidget {
  const FavouritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favourites = ref.watch(favouritesProvider);
    final packagesAsync = ref.watch(packagesProvider(null));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourites'),
        actions: [
          if (favourites.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, ref),
              child: Text(
                'Clear All',
                style: TextStyle(color: colorScheme.error),
              ),
            ),
        ],
      ),
      body: packagesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load packages')),
        data: (allPackages) {
          if (favourites.isEmpty) {
            return _EmptyFavourites();
          }

          final favPackages = favourites
              .map((fav) {
                try {
                  return allPackages.firstWhere((p) => p.id == fav.packageId);
                } catch (_) {
                  return null;
                }
              })
              .whereType<dynamic>()
              .toList();

          if (favPackages.isEmpty) {
            return _EmptyFavourites();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: favPackages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final pkg = favPackages[index];
              final networkInfo = NetworkConstants.findById(pkg.networkId);
              return PackageCard(
                package: pkg,
                networkColor: networkInfo?.brandColor ?? Theme.of(context).colorScheme.primary,
              );
            },
          );
        },
      ),
    );
  }

  void _confirmClear(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Favourites'),
        content: const Text('Remove all packages from favourites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final repo = ref.read(favouriteRepositoryProvider);
              repo.getFavourites().forEach((f) {
                repo.toggleFavourite(
                    packageId: f.packageId, networkId: f.networkId);
              });
              ref.invalidate(favouritesProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _EmptyFavourites extends StatelessWidget {
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
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: cs.error.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_outline_rounded,
                size: 44,
                color: cs.error.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No favourites yet',
              style: AppTextStyles.titleMedium.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap the heart icon on any package\nto save it here for quick access',
              style: AppTextStyles.bodySmall.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.explore_outlined, size: 18),
              label: const Text('Browse Packages'),
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
