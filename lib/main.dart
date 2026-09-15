import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'providers/like_provider.dart';
import 'admin/services/admin_data_service.dart';
import 'screens/splash_screen.dart';
import 'utils/app_colors.dart';

// =========================================================
// ENV CONFIG - dibaca dari --dart-define saat build
// Untuk lokal: jalankan dengan --dart-define
// Contoh:
// flutter run --dart-define=SUPABASE_URL=xxx --dart-define=SUPABASE_ANON_KEY=yyy
// =========================================================
class Env {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static bool get isValid =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Validasi env sebelum app jalan
  if (!Env.isValid) {
    debugPrint('WARNING: SUPABASE_URL / SUPABASE_ANON_KEY belum di-set.');
  } else {
    debugPrint('Env loaded: ${Env.supabaseUrl}');
  }

  runApp(const FoodRescueApp());
}

class FoodRescueApp extends StatelessWidget {
  const FoodRescueApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isAdmin =
        Uri.base.path.contains('admin') || Uri.base.fragment.contains('admin');

    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      scaffoldBackgroundColor: AppColors.background,
    );

    if (kReleaseMode) {
      ErrorWidget.builder = (FlutterErrorDetails details) {
        return const Center(
          child: Text('Terjadi kesalahan. Silakan coba lagi.'),
        );
      };
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AdminDataService()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => LikeProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: isAdmin ? 'FoodRescue Admin' : 'FoodRescue',
        theme: baseTheme.copyWith(
          textTheme: GoogleFonts.plusJakartaSansTextTheme(baseTheme.textTheme),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            backgroundColor: AppColors.background,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            fillColor: Colors.white,
            filled: true,
          ),
        ),
        home: SplashScreen(isAdmin: isAdmin),
      ),
    );
  }
}