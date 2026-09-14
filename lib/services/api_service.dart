import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://139.190.96.203:8091/api';

  // ===== TOKEN MANAGEMENT =====
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // ===== LOGIN =====
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
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

  // ===== GET FOODS =====
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

  // ===== GET USERS (ADMIN) =====
  static Future<List<Map<String, dynamic>>> getUsers(String? token) async {
    if (!_isValidToken(token)) {
      throw ApiException('Unauthorized: Token tidak valid', 401);
    }
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {'id': 'U001', 'name': 'Budi Santoso', 'email': 'budi@email.com'},
      {'id': 'U002', 'name': 'Alya Putri', 'email': 'alya@email.com'},
    ];
  }

  // ===== DELETE PRODUCT (ADMIN) =====
  static Future<void> deleteProduct(String? token, String productId) async {
    if (!_isValidToken(token)) {
      throw ApiException('Unauthorized: Token tidak valid', 401);
    }
    if (!token!.contains('admin')) {
      throw ApiException(
          'Forbidden: Hanya admin yang bisa menghapus produk', 403);
    }
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // ===== HELPER =====
  static bool _isValidToken(String? token) {
    return token != null && token.isNotEmpty;
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}