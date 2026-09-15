import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // SECURITY: Production wajib HTTPS. Dev lokal boleh HTTP ke localhost.
  static final Uri? _baseUri = _readBaseUri();
  static const _secureStorage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';
  static const Duration _timeout = Duration(seconds: 30);

  static Uri? _readBaseUri() {
    final value = dotenv.env['API_BASE_URL']?.trim();
    if (value == null || value.isEmpty) return null;

    final uri = Uri.tryParse(value);
    if (uri == null || uri.host.isEmpty) return null;

    // SECURITY: Production WAJIB HTTPS
    if (kReleaseMode) {
      if (uri.scheme != 'https') return null;
      return uri;
    }

    // Dev: izinkan HTTP ke localhost/emulator saja
    if (uri.scheme == 'https') return uri;
    if (uri.scheme == 'http') {
      final host = uri.host;
      final isLocal = host == 'localhost' ||
          host == '127.0.0.1' ||
          host == '10.0.2.2' ||
          host.startsWith('192.168.') ||
          host.startsWith('10.');
      return isLocal ? uri : null;
    }

    return null;
  }

  static Uri _endpoint(String path) {
    final base = _baseUri;
    if (base == null) {
      throw const ApiException('API belum dikonfigurasi. Cek file .env', 503);
    }
    return base.resolve(path.replaceFirst(RegExp(r'^/'), ''));
  }

  // ============================================
  // TOKEN MANAGEMENT
  // ============================================
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

  // ============================================
  // LOGIN
  // ============================================
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        _endpoint('/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Response BE: {"success": true, "data": {"token": "...", "user": {...}}}
        final token = data['data']?['token'] ?? data['token'];
        if (token is! String || token.isEmpty) {
          return {'success': false, 'message': 'Respons autentikasi tidak valid'};
        }
        await saveToken(token);
        return {'success': true, 'data': data['data'] ?? data};
      }

      // Error handling
      try {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Login gagal'};
      } catch (_) {
        return {'success': false, 'message': 'Email atau password salah'};
      }
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server'};
    }
  }

  // ============================================
  // REGISTER
  // ============================================
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
    bool store = false,
    String? storeName,
    String? storeAddress,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
        'email': email,
        'password': password,
      };
      if (phone != null && phone.isNotEmpty) body['phone'] = phone;
      if (address != null && address.isNotEmpty) body['address'] = address;
      if (store) {
        if (storeName != null && storeName.isNotEmpty) {
          body['store_name'] = storeName;
        }
        if (storeAddress != null && storeAddress.isNotEmpty) {
          body['store_address'] = storeAddress;
        }
      }

      final response = await http.post(
        _endpoint(store ? '/register/store' : '/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': data['data'] ?? data};
      }
      return {'success': false, 'message': data['message'] ?? 'Registrasi gagal'};
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (_) {
      return {'success': false, 'message': 'Gagal terhubung ke server'};
    }
  }

  // ============================================
  // GET FOODS
  // ============================================
  static Future<List<dynamic>> getFoods() async {
    try {
      final token = await getToken();
      final response = await http.get(
        _endpoint('/foods'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ============================================
  // ADMIN — USERS
  // ============================================
  static Future<List<Map<String, dynamic>>> getUsers(String? token) async {
    final response = await http.get(
      _endpoint('/admin/users'),
      headers: _authHeaders(token),
    ).timeout(_timeout);

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw ApiException('Akses admin ditolak', response.statusCode);
    }
    if (response.statusCode != 200) {
      throw ApiException('Gagal mengambil pengguna', response.statusCode);
    }
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['data'] ?? data);
  }

  // ============================================
  // ADMIN — DELETE PRODUCT
  // ============================================
  static Future<void> deleteProduct(String? token, String productId) async {
    if (productId.trim().isEmpty) {
      throw const ApiException('ID produk tidak valid', 400);
    }
    final response = await http.delete(
      _endpoint('/admin/products/${Uri.encodeComponent(productId)}'),
      headers: _authHeaders(token),
    ).timeout(_timeout);

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw ApiException('Akses admin ditolak', response.statusCode);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Produk gagal dihapus', response.statusCode);
    }
  }

  // ============================================
  // COMMUNITY (BARU)
  // ============================================
  static Future<Map<String, dynamic>> getCommunityPosts({
    String? type,
    String status = 'open',
  }) async {
    try {
      final token = await getToken();
      final queryParams = <String, String>{'status': status};
      if (type != null) queryParams['type'] = type;

      final uri = _endpoint('/community/posts').replace(
        queryParameters: queryParams,
      );
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data'] ?? []};
      }
      return {'success': false, 'message': data['message'] ?? 'Gagal memuat'};
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (_) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> claimCommunityPost(String postId) async {
    try {
      final token = await getToken();
      final response = await http.post(
        _endpoint('/community/posts/$postId/claim'),
        headers: _authHeaders(token),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': data['data'], 'message': data['message']};
      }
      return {'success': false, 'message': data['message'] ?? 'Gagal klaim'};
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (_) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> createCommunityPost(
      Map<String, dynamic> body) async {
    try {
      final token = await getToken();
      final response = await http.post(
        _endpoint('/store/community'),
        headers: _authHeaders(token),
        body: jsonEncode(body),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message'] ?? 'Gagal buat'};
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (_) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  // ============================================
  // HELPERS
  // ============================================
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