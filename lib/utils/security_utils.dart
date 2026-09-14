import 'dart:convert';
import 'package:crypto/crypto.dart';

class SecurityUtils {
  // SECURITY: This hash is only for debug demo fixtures. Production passwords
  // must be hashed and verified on the backend with Argon2id/bcrypt/scrypt.
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verifyPassword(String password, String storedHash) {
    return hashPassword(password) == storedHash;
  }

  // SECURITY: Client validation improves UX; the backend must enforce it too.
  static bool isStrongPassword(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }
}
