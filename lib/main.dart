import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/theme/theme_cubit.dart';
import 'blocs/nav/nav_cubit.dart';
import 'blocs/tasbih/tasbih_cubit.dart';
import 'blocs/locale/locale_cubit.dart';
import 'core/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/notification_service.dart';
import 'core/services/location_service.dart';
import 'core/services/prayer_service.dart';
import 'screens/home_screen.dart';
import 'screens/prayer_times_screen.dart';
import 'screens/quran_screen.dart';
import 'screens/qibla_screen.dart';
import 'screens/tasbih_screen.dart';
import 'screens/duas_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/names_screen.dart';
import 'core/i18n/strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final preferencesService = PreferencesService(prefs: prefs);
  
  // Initialize notifications
  try {
    final notificationService = NotificationService();
    await notificationService.init();
  } catch (e) {
    // Ignore notification initialization errors
    print('Notification initialization error: $e');
  }
  
  // Auto-schedule notifications at startup if enabled
  final notifEnabled = preferencesService.getNotificationsEnabled();
  if (notifEnabled) {
    try {
      final notif = NotificationService();
      await notif.init();
      await notif.scheduleForTodayUsing(locationService: LocationService(), prayerService: PrayerService());
    } catch (e) {
      // Ignore notification errors to prevent app from crashing
      print('Notification service error: $e');
    }
  }
  runApp(MyApp(preferencesService: preferencesService));
}

class MyApp extends StatelessWidget {
  final PreferencesService preferencesService;
  const MyApp({super.key, required this.preferencesService});

  @override
  Widget build(BuildContext context) {
    final seed = const Color(0xFF10B981); // Green base
    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00C896), // Beautiful green from the image
        brightness: Brightness.light,
      ).copyWith(
        primary: const Color(0xFF00C896), // Main green
        primaryContainer: const Color(0xFF4DD0A7), // Light green
        secondary: const Color(0xFF26D0CE), // Teal accent
        surface: Colors.white,
        background: const Color(0xFFF8FFF8), // Very light green background
        onPrimary: Colors.white,
        onPrimaryContainer: Colors.white,
        onSurface: const Color(0xFF1B5E20), // Dark green text
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF00C896),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C896),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      ).copyWith(secondary: const Color(0xFFF59E0B)),
      appBarTheme: const AppBarTheme(centerTitle: true),
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<PreferencesService>.value(value: preferencesService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit(preferencesService: preferencesService)),
          BlocProvider(create: (_) => NavCubit()),
          BlocProvider(create: (_) => TasbihCubit(preferencesService: preferencesService)),
          BlocProvider(create: (_) => LocaleCubit(preferencesService: preferencesService)),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, mode) {
            return BlocBuilder<LocaleCubit, Locale>(builder: (context, locale) {
              return MaterialApp(
                title: 'We Muslim - Inspired',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  useMaterial3: true,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: const Color(0xFF00A876), // Darker emerald green
                    brightness: Brightness.light,
                  ).copyWith(
                    primary: const Color(0xFF00A876), // Darker main emerald green
                    primaryContainer: const Color(0xFF1BB896), // Darker teal
                    secondary: const Color(0xFF2DB087), // Darker secondary green
                    surface: Colors.white,
                    background: const Color(0xFFF8FFFE), // Very light mint background
                    onPrimary: Colors.white,
                    onPrimaryContainer: Colors.white,
                    onSurface: const Color(0xFF1A1A1A), // Dark text
                  ),
                  scaffoldBackgroundColor: const Color(0xFFF8FFFE),
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Color(0xFF00A876),
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  cardTheme: CardThemeData(
                    color: Colors.white,
                    elevation: 8,
                    shadowColor: const Color(0xFF00A876).withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                darkTheme: darkTheme,
                themeMode: mode,
                locale: locale,
                supportedLocales: const [Locale('en'), Locale('ar')],
                localizationsDelegates: const [
                  _AppLocalizationsDelegate(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
              home: const MainShell(),
              routes: {
                '/qibla': (_) => const QiblaScreen(),
                '/tasbih': (_) => const TasbihScreen(),
                '/duas': (_) => const DuasScreen(),
                '/quran': (_) => const QuranScreen(),
                '/calendar': (_) => const CalendarScreen(),
                '/names': (_) => const NamesScreen(),
              },
              );
            });
          },
        ),
      ),
    );
  }
}

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static final List<Widget> _pages = const <Widget>[
    HomeScreen(),
    PrayerTimesScreen(),
    QuranScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    
    return BlocBuilder<NavCubit, int>(
      builder: (context, index) {
        return Scaffold(
          body: _pages[index],
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            destinations: <NavigationDestination>[
              NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: s.t('home')),
              NavigationDestination(icon: const Icon(Icons.access_time_outlined), selectedIcon: const Icon(Icons.access_time_filled), label: s.t('prayer')),
              NavigationDestination(icon: const Icon(Icons.menu_book_outlined), selectedIcon: const Icon(Icons.menu_book), label: s.t('quran')),
              NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings), label: s.t('settings')),
            ],
            onDestinationSelected: (i) => context.read<NavCubit>().setIndex(i),
          ),
        );
      },
    );
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<S> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<S> load(Locale locale) async => S(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
