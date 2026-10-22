import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/package_repository.dart';
import '../../data/repositories/favourite_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/local/settings_local_datasource.dart';
import '../../data/local/recently_viewed_local_datasource.dart';
import '../../data/local/package_local_datasource.dart';
import '../../models/package_model.dart';
import '../../models/network_model.dart';
import '../../models/favourite_model.dart';

// Repositories
final packageRepositoryProvider = Provider<PackageRepository>(
  (ref) => PackageRepository(),
);

final favouriteRepositoryProvider = Provider<FavouriteRepository>(
  (ref) => FavouriteRepository(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);

final settingsDataSourceProvider = Provider<SettingsLocalDataSource>(
  (ref) => SettingsLocalDataSource(),
);

// Theme
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(ref.watch(settingsDataSourceProvider)),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SettingsLocalDataSource _settings;

  ThemeModeNotifier(this._settings) : super(_settings.getThemeMode());

  Future<void> setTheme(ThemeMode mode) async {
    await _settings.saveThemeMode(mode);
    state = mode;
  }

  void toggle() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setTheme(next);
  }
}

// Accent Color
final accentColorProvider =
    StateNotifierProvider<AccentColorNotifier, AppAccentColor>(
  (ref) => AccentColorNotifier(ref.watch(settingsDataSourceProvider)),
);

class AccentColorNotifier extends StateNotifier<AppAccentColor> {
  final SettingsLocalDataSource _settings;

  AccentColorNotifier(this._settings) : super(_settings.getAccentColor());

  Future<void> setAccent(AppAccentColor accent) async {
    await _settings.saveAccentColor(accent);
    state = accent;
  }
}

// Networks
final networksProvider = FutureProvider<List<NetworkModel>>((ref) async {
  final repo = ref.watch(packageRepositoryProvider);
  return repo.getNetworks();
});

// Packages (per network + category)
class PackageFilter {
  final String? networkId;
  final String category;
  final String sortField;
  final bool ascending;
  final String searchQuery;
  final bool onlyBest;

  const PackageFilter({
    this.networkId,
    this.category = 'all',
    this.sortField = 'price',
    this.ascending = true,
    this.searchQuery = '',
    this.onlyBest = false,
  });

  PackageFilter copyWith({
    String? networkId,
    String? category,
    String? sortField,
    bool? ascending,
    String? searchQuery,
    bool? onlyBest,
  }) {
    return PackageFilter(
      networkId: networkId ?? this.networkId,
      category: category ?? this.category,
      sortField: sortField ?? this.sortField,
      ascending: ascending ?? this.ascending,
      searchQuery: searchQuery ?? this.searchQuery,
      onlyBest: onlyBest ?? this.onlyBest,
    );
  }
}

final packageFilterProvider =
    StateNotifierProvider.family<PackageFilterNotifier, PackageFilter, String?>(
  (ref, networkId) => PackageFilterNotifier(networkId),
);

class PackageFilterNotifier extends StateNotifier<PackageFilter> {
  PackageFilterNotifier(String? networkId)
      : super(PackageFilter(networkId: networkId));

  void setCategory(String cat) => state = state.copyWith(category: cat);
  void setSortField(String field) => state = state.copyWith(sortField: field);
  void toggleOrder() => state = state.copyWith(ascending: !state.ascending);
  void toggleOnlyBest() => state = state.copyWith(onlyBest: !state.onlyBest);
  void setOnlyBest(bool val) => state = state.copyWith(onlyBest: val);
  void setSearch(String q) => state = state.copyWith(searchQuery: q);
  void reset() => state = PackageFilter(networkId: state.networkId);
}

final packagesProvider =
    FutureProvider.family<List<PackageModel>, String?>((ref, networkId) async {
  final repo = ref.watch(packageRepositoryProvider);
  return repo.getPackages(networkId: networkId);
});

final filteredPackagesProvider =
    Provider.family<List<PackageModel>, String?>((ref, networkId) {
  final packagesAsync = ref.watch(packagesProvider(networkId));
  final filter = ref.watch(packageFilterProvider(networkId));

  return packagesAsync.when(
    data: (packages) {
      var filtered = packages.where((p) {
        if (filter.onlyBest && !(p.isFeatured || p.isPopular || p.isSpecialOffer)) {
          return false;
        }
        if (filter.category != 'all' && p.category != filter.category) return false;
        if (filter.searchQuery.isNotEmpty) {
          final q = filter.searchQuery.toLowerCase();
          if (!p.name.toLowerCase().contains(q) &&
              !p.activationCode.toLowerCase().contains(q)) return false;
        }
        return true;
      }).toList();

      filtered.sort((a, b) {
        int cmp;
        switch (filter.sortField) {
          case 'validity':
            cmp = a.validityDays.compareTo(b.validityDays);
          case 'name':
            cmp = a.name.compareTo(b.name);
          default:
            cmp = a.price.compareTo(b.price);
        }
        return filter.ascending ? cmp : -cmp;
      });

      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Featured packages across networks
final featuredPackagesProvider = Provider<List<PackageModel>>((ref) {
  final packagesAsync = ref.watch(packagesProvider(null));
  return packagesAsync.when(
    data: (packages) {
      final featured = packages
          .where((p) =>
              p.isFeatured ||
              p.tags.contains('featured') ||
              p.tags.contains('popular'))
          .toList();
      if (featured.isNotEmpty) return featured;
      return packages.take(8).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Free tricks and offers across networks
final freeOffersProvider = Provider<List<PackageModel>>((ref) {
  final packagesAsync = ref.watch(packagesProvider(null));
  return packagesAsync.when(
    data: (packages) {
      return packages
          .where((p) =>
              p.price <= 0.0 ||
              p.category == 'free' ||
              p.tags.contains('free'))
          .toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Favourites
final favouritesProvider =
    StateNotifierProvider<FavouritesNotifier, List<FavouriteModel>>(
  (ref) => FavouritesNotifier(ref.watch(favouriteRepositoryProvider)),
);

class FavouritesNotifier extends StateNotifier<List<FavouriteModel>> {
  final FavouriteRepository _repo;

  FavouritesNotifier(this._repo) : super(_repo.getFavourites());

  bool isFavourite(String packageId) => _repo.isFavourite(packageId);

  Future<void> toggle(String packageId, String networkId) async {
    await _repo.toggleFavourite(packageId: packageId, networkId: networkId);
    state = _repo.getFavourites();
  }

  Future<void> syncAfterLogin() async {
    await _repo.syncAfterLogin();
    state = _repo.getFavourites();
  }
}

// Auth
final authStateProvider = StreamProvider((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

// ── Compare ──────────────────────────────────────────────────────────────────
const int kMaxCompare = 3;

final compareProvider =
    StateNotifierProvider<CompareNotifier, List<PackageModel>>(
  (ref) => CompareNotifier(),
);

class CompareNotifier extends StateNotifier<List<PackageModel>> {
  CompareNotifier() : super([]);

  bool isSelected(String id) => state.any((p) => p.id == id);

  /// Returns false if already at max capacity and the package isn't selected.
  bool toggle(PackageModel pkg) {
    if (isSelected(pkg.id)) {
      state = state.where((p) => p.id != pkg.id).toList();
      return true;
    }
    if (state.length >= kMaxCompare) return false;
    state = [...state, pkg];
    return true;
  }

  void remove(String id) => state = state.where((p) => p.id != id).toList();

  void clear() => state = [];
}

// Recently viewed
final recentlyViewedDataSourceProvider = Provider<RecentlyViewedLocalDataSource>(
  (ref) => RecentlyViewedLocalDataSource(),
);

final _packageLocalProvider = Provider<PackageLocalDataSource>(
  (ref) => PackageLocalDataSource(),
);

final recentlyViewedProvider =
    StateNotifierProvider<RecentlyViewedNotifier, List<PackageModel>>(
  (ref) => RecentlyViewedNotifier(
    ref.watch(recentlyViewedDataSourceProvider),
    ref.watch(_packageLocalProvider),
  ),
);

class RecentlyViewedNotifier extends StateNotifier<List<PackageModel>> {
  final RecentlyViewedLocalDataSource _ds;
  final PackageLocalDataSource _localPkgs;

  RecentlyViewedNotifier(this._ds, this._localPkgs) : super([]) {
    _load();
  }

  void _load() {
    final ids = _ds.getIds().reversed.toList();
    final packages = <PackageModel>[];
    for (final id in ids) {
      final pkg = _localPkgs.getPackageById(id);
      if (pkg != null) packages.add(pkg);
    }
    state = packages;
  }

  Future<void> record(PackageModel pkg) async {
    await _ds.record(pkg.id);
    final updated = [pkg, ...state.where((p) => p.id != pkg.id)];
    state = updated.take(AppConstants.recentlyViewedLimit).toList();
  }

  Future<void> clear() async {
    await _ds.clear();
    state = [];
  }
}

// Best value package IDs per network (computed from value score)
final bestValueIdsProvider = Provider.family<Set<String>, String?>((ref, networkId) {
  final packagesAsync = ref.watch(packagesProvider(networkId));
  return packagesAsync.when(
    data: (packages) {
      if (packages.isEmpty) return {};

      // Group by category, find best value in each group
      final byCategory = <String, List<PackageModel>>{};
      for (final p in packages) {
        byCategory.putIfAbsent(p.category, () => []).add(p);
      }

      final bestIds = <String>{};
      for (final group in byCategory.values) {
        if (group.length < 2) continue;
        PackageModel? best;
        double bestScore = -1;
        for (final p in group) {
          if (p.price <= 0) continue;
          // Score: weight data + calls + validity per rupee
          final dataMb = (p.resources.dataGb != null && p.resources.dataGb! > 0)
              ? p.resources.dataGb! * 1024
              : (p.resources.dataMb?.toDouble() ?? 0);
          final mins = (p.resources.onNetMinutes ?? 0) +
              (p.resources.offNetMinutes ?? 0) * 0.5;
          final sms = (p.resources.sms ?? 0) * 0.1;
          final validityBonus = p.validityDays * 2.0;
          final score = (dataMb + mins + sms + validityBonus) / p.price;
          if (score > bestScore) {
            bestScore = score;
            best = p;
          }
        }
        if (best != null) bestIds.add(best.id);
      }
      return bestIds;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});
