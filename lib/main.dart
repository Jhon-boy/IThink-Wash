import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithinkwash/app/config/env_config.dart';
import 'package:ithinkwash/app/config/enviroment.dart';
import 'package:ithinkwash/app/providers/provider.dart';
import 'package:ithinkwash/core/app_constants.dart';
import 'package:ithinkwash/core/services/conection_service.dart';
import 'package:ithinkwash/core/services/shared_preferences_service.dart';
import 'package:ithinkwash/core/services/storage_service.dart';
import 'package:ithinkwash/core/theme_app.dart';
import 'package:ithinkwash/core/utils/app_util.dart';
import 'package:ithinkwash/core/utils/platform_util.dart';
import 'package:ithinkwash/modules/authentication/presentation/login_page.dart';
import 'package:ithinkwash/modules/authentication/presentation/login_page_web.dart';
import 'package:ithinkwash/modules/authentication/presentation/splash_page.dart';
import 'package:ithinkwash/modules/main/presentation/main_page.dart';
import 'package:ithinkwash/shared/enums/enviroment.dart';
import 'package:ithinkwash/shared/widgets/global_loader.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load();
  EnvironmentConfig.initialize(EnvironmentType.development);
  await StorageService.initialize();

  if (!PlatformUtil.isWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }

  await Supabase.initialize(
    url: EnvConfig.SUPABASE_URL,
    anonKey: EnvConfig.SUPABASE_ANON_KEY,
  );
  await SharedPrefsService.instance.init();
  runApp(const ProviderScope(child: AppEntry()));
}

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    if (PlatformUtil.isWeb) {
      return const MyAppWeb();
    }
    return const MyApp();
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late ConnectivityService _connectivityService;

  @override
  void initState() {
    super.initState();
    _connectivityService = ConnectivityService();
    _connectivityService.initialize();
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);

    return MaterialApp(
      title: AppConstants.APP_NAME,
      debugShowCheckedModeBanner: false,
      theme: ThemeApp.getTheme(isDarkMode: false),
      darkTheme: ThemeApp.getTheme(isDarkMode: true),
      themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: appState.currentLocale,
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      navigatorKey: AppUtils.navigatorKey,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/splash': (context) => const SplashPage(),
        '/base': (context) => const MainPage(),
      },
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text("¡Ups! Algo salió mal",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text("Por favor, inténtalo nuevamente",
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (AppUtils.navigatorKey.currentState != null) {
                            AppUtils.navigatorKey.currentState!
                                .pushReplacementNamed('/splash');
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Reintentar",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          );
        };
        return Stack(
          children: [
            child!,
            if (appState.isLoading) const GlobalLoader(),
          ],
        );
      },
    );
  }
}

class MyAppWeb extends StatelessWidget {
  const MyAppWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.APP_NAME,
      debugShowCheckedModeBanner: false,
      theme: ThemeApp.getTheme(isDarkMode: false),
      darkTheme: ThemeApp.getTheme(isDarkMode: true),
      themeMode: ThemeMode.light,
      locale: const Locale('es', 'ES'),
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      navigatorKey: AppUtils.navigatorKey,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPageWeb(),
        '/splash': (context) => const SplashPage(),
        '/base': (context) => const MainPage(),
      },
      builder: (context, child) {
        return Stack(
          children: [
            child!,
          ],
        );
      },
    );
  }
}
