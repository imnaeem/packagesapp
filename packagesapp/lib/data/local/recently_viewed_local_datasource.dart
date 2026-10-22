import '../../core/constants/app_constants.dart';
import 'hive_service.dart';

class RecentlyViewedLocalDataSource {
  // Stores package IDs in order (most recent first)
  List<String> getIds() {
    final box = HiveService.recentlyViewedBox;
    return box.values.toList();
  }

  Future<void> record(String packageId) async {
    final box = HiveService.recentlyViewedBox;
    // Remove if already present (to re-insert at front)
    final existing = box.keys
        .cast<dynamic>()
        .firstWhere((k) => box.get(k) == packageId, orElse: () => null);
    if (existing != null) await box.delete(existing);

    // Insert at the "front" by using a timestamp key so latest is retrievable
    await box.add(packageId);

    // Trim to limit
    if (box.length > AppConstants.recentlyViewedLimit) {
      final firstKey = box.keys.first;
      await box.delete(firstKey);
    }
  }

  Future<void> clear() => HiveService.recentlyViewedBox.clear();
}
