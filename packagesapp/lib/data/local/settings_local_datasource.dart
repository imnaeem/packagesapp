import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import 'hive_service.dart';

class SettingsLocalDataSource {
  ThemeMode getThemeMode() {
    final val = HiveService.settingsBox.get(AppConstants.themeModeKey) as String?;
    switch (val) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final val = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await HiveService.settingsBox.put(AppConstants.themeModeKey, val);
  }

  AppAccentColor getAccentColor() {
    final val = HiveService.settingsBox.get(AppConstants.themeAccentKey) as String?;
    return AppAccentColor.fromId(val);
  }

  Future<void> saveAccentColor(AppAccentColor accent) async {
    await HiveService.settingsBox.put(AppConstants.themeAccentKey, accent.id);
  }
}
