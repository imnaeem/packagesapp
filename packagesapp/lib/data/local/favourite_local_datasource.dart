import '../../models/favourite_model.dart';
import 'hive_service.dart';

class FavouriteLocalDataSource {
  List<FavouriteModel> getFavourites() =>
      HiveService.favouritesBox.values.toList();

  bool isFavourite(String packageId) =>
      HiveService.favouritesBox.containsKey(packageId);

  Future<void> addFavourite(FavouriteModel fav) async =>
      HiveService.favouritesBox.put(fav.packageId, fav);

  Future<void> removeFavourite(String packageId) async =>
      HiveService.favouritesBox.delete(packageId);

  Future<void> clearAll() async => HiveService.favouritesBox.clear();

  Future<void> syncFromCloud(List<FavouriteModel> cloudFavs) async {
    await HiveService.favouritesBox.clear();
    for (final fav in cloudFavs) {
      await HiveService.favouritesBox.put(fav.packageId, fav);
    }
  }

  List<FavouriteModel> getUnsyncedFavourites() => getFavourites();
}
