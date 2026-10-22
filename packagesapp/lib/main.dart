import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/providers/providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'data/local/hive_service.dart';
import 'data/local/package_local_datasource.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();
  await PackageLocalDataSource().ensureSeedDataLoaded();

  // Firebase initialization — requires google-services.json / GoogleService-Info.plist
  // Comment out if not yet configured
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase not configured yet; app runs in offline/local mode
  }

  runApp(const ProviderScope(child: PkPackagesApp()));
}

class PkPackagesApp extends ConsumerWidget {
  const PkPackagesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final accent = ref.watch(accentColorProvider);

    return MaterialApp.router(
      title: 'PK Packages',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(accent.lightColor),
      darkTheme: AppTheme.darkTheme(accent.darkColor),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        // Match the nav bar color to the scaffold background so it blends
        // seamlessly instead of showing a grey/transparent bar.
        final isDark = Theme.of(context).brightness == Brightness.dark;
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor:
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          systemNavigationBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ));
        return child!;
      },
    );
  }
}
