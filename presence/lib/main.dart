import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure system UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    // Wrap in ProviderScope for Riverpod
    const ProviderScope(
      child: PresenceApp(),
    ),
  );
}

class PresenceApp extends ConsumerWidget {
  const PresenceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Presence',
      debugShowCheckedModeBanner: false,

      // Material Design 3 themes
      theme: PresenceTheme.light,
      darkTheme: PresenceTheme.dark,
      themeMode: ThemeMode.system,

      // GoRouter
      routerConfig: router,

      // Accessibility
      builder: (context, child) {
        return MediaQuery(
          // Respect system text scaling — do not clamp
          data: MediaQuery.of(context),
          child: child!,
        );
      },
    );
  }
}
