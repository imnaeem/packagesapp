import '../../models/favourite_model.dart';
import '../local/favourite_local_datasource.dart';
import '../remote/favourite_remote_datasource.dart';

class FavouriteRepository {
  final FavouriteLocalDataSource _local;
  final FavouriteRemoteDataSource _remote;
  bool _isLoggedIn = false;

  FavouriteRepository({
    FavouriteLocalDataSource? local,
    FavouriteRemoteDataSource? remote,
  })  : _local = local ?? FavouriteLocalDataSource(),
        _remote = remote ?? FavouriteRemoteDataSource();

  void setLoggedIn(bool value) => _isLoggedIn = value;

  List<FavouriteModel> getFavourites() => _local.getFavourites();

  bool isFavourite(String packageId) => _local.isFavourite(packageId);

  Future<void> toggleFavourite({
    required String packageId,
    required String networkId,
  }) async {
    if (_local.isFavourite(packageId)) {
      await _local.removeFavourite(packageId);
      if (_isLoggedIn) {
        try {
          await _remote.removeFavourite(packageId);
        } catch (_) {}
      }
    } else {
      final fav = FavouriteModel(
        packageId: packageId,
        networkId: networkId,
        addedAt: DateTime.now().toIso8601String(),
      );
      await _local.addFavourite(fav);
      if (_isLoggedIn) {
        try {
          await _remote.addFavourite(packageId);
        } catch (_) {}
      }
    }
  }

  Future<void> syncAfterLogin() async {
    if (!_isLoggedIn) return;
    try {
      final localFavs = _local.getUnsyncedFavourites();
      if (localFavs.isNotEmpty) {
        await _remote.syncFavourites(localFavs);
      }
      final cloudFavs = await _remote.fetchFavourites();
      await _local.syncFromCloud(cloudFavs);
    } catch (_) {}
  }
}
