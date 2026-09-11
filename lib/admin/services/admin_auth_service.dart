class AdminAuthService {
  static const _adminEmail = 'admin@foodrescue.id';

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (email != _adminEmail || password != 'Admin@2024!') {
      throw Exception('Email atau password salah');
    }
    return {
      'email': email,
      'name': 'Super Admin',
      'role': 'superAdmin',
      'token': 'token_${DateTime.now().millisecondsSinceEpoch}',
    };
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