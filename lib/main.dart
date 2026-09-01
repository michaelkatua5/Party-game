import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:device_preview/device_preview.dart';
import 'core/l10n/app_localizations.dart';
import 'core/providers/core_providers.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/providers/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation for standard pass-and-play phone handling
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final container = ProviderContainer();
  // Initialize persistent storage
  await container.read(storageServiceProvider).init();

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => UncontrolledProviderScope(
        container: container,
        child: const ChezaApp(),
      ),
    ),
  );
}

class ChezaApp extends ConsumerWidget {
  const ChezaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);

    return MaterialApp.router(
      title: 'CHEZA! Kenyan Party Game',
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to dark for high-energy party aesthetic
      routerConfig: appRouter,
      locale: DevicePreview.locale(context) ?? Locale(settings.language),
      builder: DevicePreview.appBuilder,
      supportedLocales: const [
        Locale('en', ''),
        Locale('sw', ''),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
