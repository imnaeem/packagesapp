import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../models/package_model.dart';
import '../../models/network_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/network_constants.dart';
import 'hive_service.dart';

class PackageLocalDataSource {
  Future<void> ensureSeedDataLoaded() async {
    final seedVersion = HiveService.metaBox.get('bundled_seed_version') as int? ?? 0;
    const currentSeedVersion = 3;
    final hasMultiNetwork = HiveService.packagesBox.values.any((p) => p.networkId == 'zong');
    if (HiveService.packagesBox.isEmpty || !hasMultiNetwork || seedVersion < currentSeedVersion) {
      await loadBundledSeedData();
      await HiveService.metaBox.put('bundled_seed_version', currentSeedVersion);
    }
  }

  Future<void> loadBundledSeedData() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/bundled_packages.json');
      final dynamic decoded = jsonDecode(jsonString);

      List<PackageModel> packages = [];
      List<NetworkModel> networks = [];

      if (decoded is Map<String, dynamic>) {
        if (decoded['packages'] is List) {
          packages = (decoded['packages'] as List)
              .map((e) => PackageModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        if (decoded['networks'] is List) {
          networks = (decoded['networks'] as List)
              .map((e) => NetworkModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } else if (decoded is List) {
        packages = decoded
            .map((e) => PackageModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (packages.isNotEmpty) {
        final box = HiveService.packagesBox;
        await box.clear();
        final map = {for (final p in packages) p.id: p};
        await box.putAll(map);
      }

      if (networks.isEmpty) {
        networks = NetworkConstants.networks.map((info) {
          final count = packages.where((p) => p.networkId == info.id).length;
          return NetworkModel(
            id: info.id,
            name: info.name,
            slug: info.slug,
            slogan: info.slogan,
            logoUrl: info.logoAsset,
            brandColor:
                '#${info.brandColor.toARGB32().toRadixString(16).substring(2)}',
            isActive: true,
            packageCount: count,
          );
        }).toList();
      }

      if (networks.isNotEmpty) {
        final netBox = HiveService.networksBox;
        await netBox.clear();
        final map = {for (final n in networks) n.id: n};
        await netBox.putAll(map);
      }

      if (!HiveService.metaBox.containsKey(AppConstants.lastFetchKey)) {
        await HiveService.metaBox.put(
          AppConstants.lastFetchKey,
          DateTime.now().millisecondsSinceEpoch,
        );
      }
    } catch (e) {
      debugPrint('Error loading bundled seed data: $e');
    }
  }

  Future<void> savePackages(List<PackageModel> packages) async {
    final box = HiveService.packagesBox;
    await box.clear();
    final map = {for (final p in packages) p.id: p};
    await box.putAll(map);
    await HiveService.metaBox.put(
      AppConstants.lastFetchKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  List<PackageModel> getPackages({String? networkId, String? category}) {
    if (HiveService.packagesBox.isEmpty) {
      ensureSeedDataLoaded();
    }
    final all = HiveService.packagesBox.values.toList();
    return all.where((p) {
      if (networkId != null && networkId != 'all' && p.networkId != networkId) return false;
      if (category != null && category != 'all' && p.category != category) {
        return false;
      }
      return true;
    }).toList();
  }

  PackageModel? getPackageById(String id) => HiveService.packagesBox.get(id);

  Future<void> saveNetworks(List<NetworkModel> networks) async {
    final box = HiveService.networksBox;
    await box.clear();
    final map = {for (final n in networks) n.id: n};
    await box.putAll(map);
  }

  List<NetworkModel> getNetworks() {
    if (HiveService.networksBox.isEmpty && HiveService.packagesBox.isEmpty) {
      ensureSeedDataLoaded();
    }
    return HiveService.networksBox.values.toList();
  }

  bool get isCacheExpired {
    final ts = HiveService.metaBox.get(AppConstants.lastFetchKey) as int?;
    if (ts == null) return true;
    final lastFetch = DateTime.fromMillisecondsSinceEpoch(ts);
    return DateTime.now().difference(lastFetch) > AppConstants.cacheExpiry;
  }

  bool get hasCache => HiveService.packagesBox.isNotEmpty;

  // Daily Refetch Limit (4 times per day max)
  String _todayDateStr() => DateTime.now().toIso8601String().split('T').first;

  int _getTodayRefreshCount() {
    final storedDate = HiveService.metaBox.get('daily_refresh_date') as String?;
    final count = HiveService.metaBox.get('daily_refresh_count') as int? ?? 0;
    if (storedDate != _todayDateStr()) {
      return 0;
    }
    return count;
  }

  bool canRefreshToday({int maxDaily = 4}) {
    return _getTodayRefreshCount() < maxDaily;
  }

  int remainingRefreshesToday({int maxDaily = 4}) {
    final used = _getTodayRefreshCount();
    final remaining = maxDaily - used;
    return remaining > 0 ? remaining : 0;
  }

  void recordDailyRefresh() {
    final today = _todayDateStr();
    final storedDate = HiveService.metaBox.get('daily_refresh_date') as String?;
    int current = HiveService.metaBox.get('daily_refresh_count') as int? ?? 0;
    if (storedDate != today) {
      current = 0;
    }
    HiveService.metaBox.put('daily_refresh_date', today);
    HiveService.metaBox.put('daily_refresh_count', current + 1);
  }
}
