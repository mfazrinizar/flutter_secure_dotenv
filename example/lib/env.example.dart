// ──────────────────────────────────────────────────────────────────────
// env.example.dart — TEMPLATE (committed to git)
//
// Copy this file to  env.dart  (same directory) and fill in the real
// key/IV. The real env.dart is GITIGNORED — it must never be committed.
// ──────────────────────────────────────────────────────────────────────
//
// Steps:
//  1. Copy:        cp lib/env.example.dart lib/env.dart
//  2. Build:       dart run build_runner build
//  3. Copy key:    open encryption_key.json, paste ENCRYPTION_KEY and IV
//                  into the constants in lib/env.dart.
//  4. Delete:      rm encryption_key.json
//  5. Use it:      import 'env.dart' in your app code and call Env.create().
//
// For maximum security, use a server-fetched key at runtime.
// See the package SECURITY.md for details.
// ──────────────────────────────────────────────────────────────────────

import 'package:flutter_secure_dotenv/flutter_secure_dotenv.dart';

part 'env.g.dart';

@DotEnvGen(filename: '.env', fieldRename: FieldRename.screamingSnake)
abstract class Env {
  // ── Replace these placeholders with real values from encryption_key.json ──
  static const _encryptionKey = 'PASTE_BASE64_ENCRYPTION_KEY_HERE';
  static const _iv = 'PASTE_BASE64_IV_HERE';

  /// Creates an [Env] instance using the hardcoded encryption key.
  static Env create() {
    return Env(_encryptionKey, _iv);
  }

  const factory Env(String encryptionKey, String iv) = _$Env;

  const Env._();

  @FieldKey(defaultValue: '')
  String get apiBaseUrl;

  @FieldKey(defaultValue: '')
  String get apiWebSocketUrl;
}
