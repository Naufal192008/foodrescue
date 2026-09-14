import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // SECURITY: API wajib HTTPS. Jangan masukkan URL HTTP atau rahasia ke source code.
  static final Uri? _baseUri = _readBaseUri();
  static const _secureStorage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  static Uri? _readBaseUri() {
    final value = dotenv.env['API_BASE_URL']?.trim();
    if (value == null || value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    return uri != null && uri.scheme == 'https' ? uri : null;
  }

  static Uri _endpoint(String path) {
    final base = _baseUri;
    if (base == null) {
      throw const ApiException('API belum dikonfigurasi dengan HTTPS', 503);
    }
    return base.resolve(path.replaceFirst(RegExp(r'^/'), ''));
  }

  // SECURITY: JWT disimpan di secure storage, bukan SharedPreferences.
  static Future<void> saveToken(String token) async {
    if (token.trim().isEmpty) throw const ApiException('Token kosong', 401);
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return _secureStorage.read(key: _tokenKey);
  }

  static Future<void> clearToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        _endpoint('/login'),
        // SECURITY: credential traffic is sent only over TLS.
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is! Map<String, dynamic> || data['token'] is! String) {
          return {
            'success': false,
            'message': 'Respons autentikasi tidak valid'
          };
        }
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Email atau password salah'};
      }
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (_) {
      return {'success': false, 'message': 'Gagal terhubung ke server'};
    }
  }

  // ===== GET FOODS =====
  static Future<List<dynamic>> getFoods() async {
    try {
      final token = await getToken();
      final response = await http.get(
        _endpoint('/foods'),
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

  static Future<List<Map<String, dynamic>>> getUsers(String? token) async {
    final response = await http.get(
      _endpoint('/admin/users'),
      headers: _authHeaders(token),
    );
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw ApiException('Akses admin ditolak', response.statusCode);
    }
    if (response.statusCode != 200) {
      throw ApiException('Gagal mengambil pengguna', response.statusCode);
    }
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['data'] ?? data);
  }

  static Future<void> deleteProduct(String? token, String productId) async {
    if (productId.trim().isEmpty) {
      throw const ApiException('ID produk tidak valid', 400);
    }
    final response = await http.delete(
      _endpoint('/admin/products/${Uri.encodeComponent(productId)}'),
      headers: _authHeaders(token),
    );
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw ApiException('Akses admin ditolak', response.statusCode);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Produk gagal dihapus', response.statusCode);
    }
  }

  // SECURITY: role/permission wajib diverifikasi backend; token bukan bukti role.
  static Map<String, String> _authHeaders(String? token) {
    if (token == null || token.trim().isEmpty) {
      throw const ApiException('Sesi tidak valid', 401);
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
