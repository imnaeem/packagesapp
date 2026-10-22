import '../../models/package_model.dart';
import '../../models/network_model.dart';
import '../local/package_local_datasource.dart';
import '../remote/package_remote_datasource.dart';

class PackageRepository {
  final PackageLocalDataSource _local;
  final PackageRemoteDataSource _remote;

  PackageRepository({
    PackageLocalDataSource? local,
    PackageRemoteDataSource? remote,
  })  : _local = local ?? PackageLocalDataSource(),
        _remote = remote ?? PackageRemoteDataSource();

  Future<List<NetworkModel>> getNetworks({bool forceRefresh = false}) async {
    await _local.ensureSeedDataLoaded();
    if (!forceRefresh && !_local.isCacheExpired && _local.getNetworks().isNotEmpty) {
      return _local.getNetworks();
    }
    try {
      final networks = await _remote.fetchNetworks();
      await _local.saveNetworks(networks);
      return networks;
    } catch (_) {
      final cached = _local.getNetworks();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  Future<List<PackageModel>> getPackages({
    String? networkId,
    String? category,
    bool forceRefresh = false,
  }) async {
    await _local.ensureSeedDataLoaded();
    final cached = _local.getPackages(networkId: networkId, category: category);
    if (!forceRefresh && cached.isNotEmpty) {
      return cached;
    }
    try {
      final packages = await _remote.fetchPackages(networkId: networkId);
      if (networkId == null) {
        await _local.savePackages(packages);
      }
      return packages.where((p) {
        if (category != null && category != 'all') return p.category == category;
        return true;
      }).toList();
    } catch (_) {
      if (cached.isNotEmpty) {
        return cached;
      }
      return _local.getPackages(networkId: networkId, category: category);
    }
  }

  Future<void> refreshAll() async {
    final networks = await _remote.fetchNetworks();
    await _local.saveNetworks(networks);
    final packages = await _remote.fetchPackages();
    await _local.savePackages(packages);
  }

  Future<PackageModel?> getPackageById(String id) async {
    await _local.ensureSeedDataLoaded();
    final local = _local.getPackageById(id);
    if (local != null) return local;
    return _remote.fetchPackageById(id);
  }

  bool canRefreshToday({int maxDaily = 4}) =>
      _local.canRefreshToday(maxDaily: maxDaily);

  int remainingRefreshesToday({int maxDaily = 4}) =>
      _local.remainingRefreshesToday(maxDaily: maxDaily);

  void recordDailyRefresh() => _local.recordDailyRefresh();

  bool get isCacheExpired => _local.isCacheExpired;
  bool get hasCache => _local.hasCache;
}
