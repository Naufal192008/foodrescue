import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  // Ambil dari .env (Secrets Management)
  static String get _adminEmail => dotenv.env['ADMIN_EMAIL'] ?? '';
  static String get _adminPassword => dotenv.env['ADMIN_PASSWORD'] ?? '';
  static String get _validTokenPrefix =>
      dotenv.env['VALID_TOKEN_PREFIX'] ?? 'token_';

  /// Simulasi API login - mengembalikan token
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (email != _adminEmail || password != _adminPassword) {
      throw ApiException('Email atau password salah', 401);
    }

    final token =
        '${_validTokenPrefix}_${DateTime.now().millisecondsSinceEpoch}';

    return {
      'email': email,
      'token': token,
      'role': 'superAdmin',
      'name': 'Super Admin',
    };
  }

  /// Simulasi API get users - memerlukan token
  static Future<List<Map<String, dynamic>>> getUsers(String? token) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!_isValidToken(token)) {
      throw ApiException('Unauthorized: Token tidak valid', 401);
    }

    return [
      {'id': 'U001', 'name': 'Budi Santoso', 'email': 'budi@email.com'},
      {'id': 'U002', 'name': 'Alya Putri', 'email': 'alya@email.com'},
    ];
  }

  /// Simulasi API delete product - memerlukan role admin
  static Future<void> deleteProduct(String? token, String productId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!_isValidToken(token)) {
      throw ApiException('Unauthorized: Token tidak valid', 401);
    }

    // Cek role admin (simulasi: token admin punya prefix 'admin_')
    if (!token!.contains('admin')) {
      throw ApiException(
          'Forbidden: Hanya admin yang bisa menghapus produk', 403);
    }
  }

  static bool _isValidToken(String? token) {
    return token != null &&
        token.isNotEmpty &&
        token.startsWith(_validTokenPrefix);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}