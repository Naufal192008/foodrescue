import '../../services/api_service.dart';

class AdminAuthService {
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    // Panggil mock API (menggunakan .env untuk kredensial)
    final response = await ApiService.login(email, password);

    // Validasi role
    if (response['role'] != 'superAdmin' && response['role'] != 'admin') {
      throw Exception('Anda bukan admin');
    }

    return response;
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