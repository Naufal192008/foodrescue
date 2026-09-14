import 'dart:convert';
import 'package:crypto/crypto.dart';

class SecurityUtils {
  /// Hash password menggunakan SHA-256
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifikasi password dengan hash yang tersimpan
  static bool verifyPassword(String password, String storedHash) {
    return hashPassword(password) == storedHash;
  }
}