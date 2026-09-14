<<<<<<< HEAD
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
=======
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://139.190.96.203:8091/api';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Email atau password salah'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server'};
    }
  }

  static Future<List<dynamic>> getFoods() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/foods'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
>>>>>>> 8e12a9f9ec6abf94a5e703b3a39ba5c0400d9447
