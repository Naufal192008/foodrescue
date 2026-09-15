import '../../services/api_service.dart';

class AdminAuthService {
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await ApiService.login(email, password);
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Login admin gagal');
    }

    final envelope = Map<String, dynamic>.from(response['data'] ?? {});
    final data = Map<String, dynamic>.from(envelope['user'] ?? envelope);
    // SECURITY: never trust a client-side role; require the backend claim.
    final role = data['role'];
    if (role != 'superAdmin' && role != 'admin') {
      throw Exception('Anda bukan admin');
    }

    return data;
  }

  static bool isStrongPassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }
}
