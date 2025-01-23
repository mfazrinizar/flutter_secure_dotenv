import 'package:flutter_secure_dotenv/flutter_secure_dotenv.dart';

void main() {
  // Example usage of DotEnvGen
  final dotenv =
      DotEnvGen(filename: 'custom.env', fieldRename: FieldRename.snake);
  print('DotEnvGen filename: ${dotenv.filename}');
  print('DotEnvGen fieldRename: ${dotenv.fieldRename}');

  // Example usage of AESCBCEncrypter
  final key = Uint8List.fromList(List.generate(32, (i) => i)); // 256-bit key
  final iv = Uint8List.fromList(List.generate(16, (i) => i)); // 128-bit IV
  final text = 'Hello, World!';

  // Encrypt the text
  final encrypted = AESCBCEncrypter.aesCbcEncrypt(key, iv, text);
  print('Encrypted text: $encrypted');

  // Decrypt the text
  final decrypted = AESCBCEncrypter.aesCbcDecrypt(key, iv, encrypted);
  print('Decrypted text: $decrypted');

  // Generate random bytes
  final randomBytes = AESCBCEncrypter.generateRandomBytes(16);
  print('Random bytes: $randomBytes');
}
