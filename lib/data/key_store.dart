import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Holds the database encryption key in Android Keystore-backed storage.
///
/// The key is generated once per install and never leaves the device. It is
/// not backed up (Auto Backup is disabled), so a restored copy of the DB file
/// would be unreadable; users move data with the passphrase export instead.
class KeyStore {
  static const _keyName = 'db_key_v1';
  static const _storage = FlutterSecureStorage();

  static Future<String> databaseKey() async {
    final existing = await _storage.read(key: _keyName);
    if (existing != null) return existing;

    final rng = Random.secure();
    final hex = List.generate(32, (_) => rng.nextInt(256))
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    await _storage.write(key: _keyName, value: hex);
    return hex;
  }
}
