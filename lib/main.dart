import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ShiftFilterApp());
}

class ShiftFilterApp extends StatefulWidget {
  const ShiftFilterApp({super.key});

  @override
  State<ShiftFilterApp> createState() => _ShiftFilterAppState();
}

class _ShiftFilterAppState extends State<ShiftFilterApp> {
  late AppProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = AppProvider();
  }

  @override
  Widget build(BuildContext context) {
    return AppProviderScope(
      provider: _provider,
      child: ListenableBuilder(
        listenable: _provider,
        builder: (context, _) {
          return MaterialApp(
            title: 'Shift Filter',
            debugShowCheckedModeBanner: false,
            themeMode: _provider.themeMode,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    const primary = Color(0xFF2563EB);
    const secondary = Color(0xFF7C3AED);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        secondary: secondary,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFFF1F5F9),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    const primary = Color(0xFF3B82F6);
    const secondary = Color(0xFF8B5CF6);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        secondary: secondary,
        brightness: Brightness.dark,
        surface: const Color(0xFF0F172A),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF1E293B),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
