import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class PasswordService {
  static String createSalt() {
    final random = Random.secure();
    return base64UrlEncode(
      List<int>.generate(16, (_) => random.nextInt(256)),
    );
  }

  static String hash(String password, String salt) {
    return sha256.convert(utf8.encode('$salt:$password')).toString();
  }
}
