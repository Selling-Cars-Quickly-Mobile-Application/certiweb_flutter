import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class PasswordHash {
  static String salt([int length = 16]) {
    final rnd = Random.secure();
    final bytes = List<int>.generate(length, (_) => rnd.nextInt(256));
    return base64Url.encode(bytes);
  }

  static String hash(String password, String salt) {
    final bytes = utf8.encode('$salt$password');
    return sha256.convert(bytes).toString();
  }
}