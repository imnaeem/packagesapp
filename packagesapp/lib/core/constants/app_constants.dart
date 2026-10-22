class AppConstants {
  AppConstants._();

  static const String appName = 'PK Packages';
  static const String appVersion = '1.0.0';

  // API
  // - Emulator: http://10.0.2.2:3000/api/v1
  // - Real device: http://<YOUR_PC_LOCAL_IP>:3000/api/v1
  static const String apiBaseUrl = 'http://10.232.186.164:3000/api/v1';

  // Hive box names
  static const String packagesBox = 'packages_box';
  static const String networksBox = 'networks_box';
  static const String favouritesBox = 'favourites_box';
  static const String settingsBox = 'settings_box';
  static const String metaBox = 'meta_box';
  static const String recentlyViewedBox = 'recently_viewed_box';

  // Hive keys
  static const String lastFetchKey = 'last_fetch_timestamp';
  static const String themeModeKey = 'theme_mode';
  static const String themeAccentKey = 'theme_accent';
  static const String guestFavouritesKey = 'guest_favourites';

  // Recently viewed limit
  static const int recentlyViewedLimit = 10;

  // Cache duration
  static const Duration cacheExpiry = Duration(hours: 24);

  // Package categories
  static const List<String> packageCategories = [
    'all',
    'call',
    'sms',
    'internet',
    'hybrid',
    'social',
    'free',
  ];

  static const List<String> packageSubCategories = [
    'daily',
    'weekly',
    'monthly',
    'yearly',
    'custom',
  ];
}
