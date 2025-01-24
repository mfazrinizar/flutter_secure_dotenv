import 'package:flutter_secure_dotenv/flutter_secure_dotenv.dart';

part 'env.g.dart';

@DotEnvGen(
  filename: '.env',
  fieldRename: FieldRename.screamingSnake,
)
abstract class Env {
  static Env create() {
    String encryptionKey = const String.fromEnvironment(
        "APP_ENCRYPTION_KEY"); // On build, change with your generated encryption key (use dart-define for String.fromEnvironment)
    String iv = const String.fromEnvironment(
        "APP_IV_KEY"); // On build, change with your generated iv (use dart-define for String.fromEnvironment)
    return Env(encryptionKey, iv);
  }

  const factory Env(String encryptionKey, String iv) = _$Env;

  const Env._();

  @FieldKey(defaultValue: "")
  String get apiBaseUrl;

  @FieldKey(defaultValue: "")
  String get apiWebSocketUrl;
}
