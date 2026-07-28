import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_app/core/router/app_router.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/l10n/app_localizations.dart';
import 'package:movie_app/providers/providers.dart';
import 'package:movie_app/services/favorites_service.dart';
import 'package:movie_app/services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 서비스 초기화
  final favoritesService = FavoritesService();
  await favoritesService.init();

  final settingsService = SettingsService();
  await settingsService.init();

  // 저장된 테마 모드 로드
  final savedThemeMode = settingsService.getThemeMode();

  runApp(
    ProviderScope(
      overrides: [
        favoritesServiceProvider.overrideWithValue(favoritesService),
        settingsServiceProvider.overrideWithValue(settingsService),
      ],
      child: MyApp(initialThemeMode: savedThemeMode),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  final ThemeMode initialThemeMode;

  const MyApp({super.key, required this.initialThemeMode});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // 저장된 테마 모드 적용
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(themeModeProvider.notifier)
          .setThemeMode(widget.initialThemeMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Movie App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
