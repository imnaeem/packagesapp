import 'package:hive_flutter/hive_flutter.dart';
import '../../models/network_model.dart';
import '../../models/package_model.dart';
import '../../models/resource_model.dart';
import '../../models/addon_model.dart';
import '../../models/favourite_model.dart';
import '../../core/constants/app_constants.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(NetworkModelAdapter());
    Hive.registerAdapter(ResourceModelAdapter());
    Hive.registerAdapter(AddonModelAdapter());
    Hive.registerAdapter(PackageModelAdapter());
    Hive.registerAdapter(FavouriteModelAdapter());

    await Future.wait([
      Hive.openBox<NetworkModel>(AppConstants.networksBox),
      Hive.openBox<PackageModel>(AppConstants.packagesBox),
      Hive.openBox<FavouriteModel>(AppConstants.favouritesBox),
      Hive.openBox(AppConstants.settingsBox),
      Hive.openBox(AppConstants.metaBox),
      Hive.openBox<String>(AppConstants.recentlyViewedBox),
    ]);
  }

  static Box<NetworkModel> get networksBox =>
      Hive.box<NetworkModel>(AppConstants.networksBox);

  static Box<PackageModel> get packagesBox =>
      Hive.box<PackageModel>(AppConstants.packagesBox);

  static Box<FavouriteModel> get favouritesBox =>
      Hive.box<FavouriteModel>(AppConstants.favouritesBox);

  static Box get settingsBox => Hive.box(AppConstants.settingsBox);

  static Box get metaBox => Hive.box(AppConstants.metaBox);

  static Box<String> get recentlyViewedBox =>
      Hive.box<String>(AppConstants.recentlyViewedBox);
}
