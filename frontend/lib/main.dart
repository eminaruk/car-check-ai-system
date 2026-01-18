import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import './screens/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkMode') ?? false;
  final localeCode = prefs.getString('locale') ?? 'en';
  final locale = Locale(localeCode);
  runApp(MyApp(initialThemeMode: isDark ? ThemeMode.dark : ThemeMode.light, initialLocale: locale));
}

class MyApp extends StatefulWidget {
  final ThemeMode initialThemeMode;
  final Locale initialLocale;

  const MyApp({super.key, required this.initialThemeMode, required this.initialLocale});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
    _locale = widget.initialLocale;
  }

  void _changeTheme(ThemeMode mode) async {
    setState(() {
      _themeMode = mode;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', mode == ThemeMode.dark);
  }

  void _changeLocale(Locale locale) async {
    setState(() {
      _locale = locale;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return ThemeNotifier(
      themeMode: _themeMode,
      onThemeChanged: _changeTheme,
      locale: _locale,
      onLocaleChanged: _changeLocale,
      child: MaterialApp(
        title: 'Car Check AI',
        debugShowCheckedModeBanner: false,
        locale: _locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('es'),
          Locale('it'),
          Locale('fr'),
          Locale('de'),
          Locale('tr'),
          Locale('pt'),
          Locale('nl'),
          Locale('ru'),
          Locale('pl'),
          Locale('zh'),
          Locale('ja'),
          Locale('ko'),
          Locale('sv'),
          Locale('no'),
          Locale('da'),
          Locale('cs'),
          Locale('hu'),
        ],
        themeMode: _themeMode,
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2196F3),
            secondary: Color(0xFF03A9F4),
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF2196F3),
            secondary: Color(0xFF03A9F4),
          ),
          useMaterial3: true,
        ),
        home: const MainLayout(),
      ),
    );
  }
}

class ThemeNotifier extends InheritedWidget {
  final ThemeMode themeMode;
  final Function(ThemeMode) onThemeChanged;
  final Locale locale;
  final Function(Locale) onLocaleChanged;

  const ThemeNotifier({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
    required this.locale,
    required this.onLocaleChanged,
    required super.child,
  });

  static ThemeNotifier? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeNotifier>();
  }

  @override
  bool updateShouldNotify(ThemeNotifier oldWidget) {
    return themeMode != oldWidget.themeMode || locale != oldWidget.locale;
  }
}
