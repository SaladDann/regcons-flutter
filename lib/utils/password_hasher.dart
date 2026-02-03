import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class PasswordHasher {
  static String generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Encode(saltBytes);
  }

  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verifyPassword(
      String inputPassword,
      String storedHash,
      String storedSalt,
      ) {
    final hash = hashPassword(inputPassword, storedSalt);
    return hash == storedHash;
  }

  static String generateSessionToken() {
    final random = Random.secure();
    final tokenBytes = List<int>.generate(64, (_) => random.nextInt(256));
    return base64UrlEncode(tokenBytes);
  }
}