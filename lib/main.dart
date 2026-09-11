import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'admin/admin_login.dart';
import 'providers/cart_provider.dart';
import 'providers/like_provider.dart';
import 'screens/main_navigation.dart';
import 'utils/app_colors.dart';

void main() {
  runApp(const FoodRescueApp());
}

class FoodRescueApp extends StatelessWidget {
  const FoodRescueApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isAdmin = Uri.base.path.contains('admin') ||
        Uri.base.fragment.contains('admin');

    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      scaffoldBackgroundColor: AppColors.background,
    );

    return MultiProvider(
      providers: [
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
        home: isAdmin
            ? AdminLoginScreen()
            : const MainNavigation(
                username: 'Budi Santoso',
                name: 'Budi Santoso',
                email: 'budi.santoso@email.com',
              ),
      ),
    );
  }
}