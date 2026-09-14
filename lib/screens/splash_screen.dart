import 'dart:async';

import 'package:flutter/material.dart';

import '../admin/admin_login.dart';
import '../utils/app_colors.dart';
import 'role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.isAdmin});

  final bool isAdmin;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _navigationTimer = Timer(const Duration(seconds: 2), _openNextScreen);
  }

  void _openNextScreen() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => widget.isAdmin
            ? const AdminLoginScreen()
            : const RoleSelectionScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _fadeController,
                curve: Curves.easeIn,
              ),
              child: Image.asset(
                'assets/logo.jpeg',
                width: 230,
                height: 230,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
