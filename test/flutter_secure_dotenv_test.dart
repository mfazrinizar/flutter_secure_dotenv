import 'package:flutter_secure_dotenv/flutter_secure_dotenv.dart';
import 'package:test/test.dart';

void main() {
  group('DotEnvGen Tests', () {
    test('Default values', () {
      final dotenv = DotEnvGen();
      expect(dotenv.filename, '.env');
      expect(dotenv.fieldRename, FieldRename.screamingSnake);
    });

    test('Custom values', () {
      final dotenv =
          DotEnvGen(filename: 'custom.env', fieldRename: FieldRename.snake);
      expect(dotenv.filename, 'custom.env');
      expect(dotenv.fieldRename, FieldRename.snake);
    });
  });

  group('AESCBCEncrypter Tests', () {
    final key = Uint8List.fromList(List.generate(32, (i) => i)); // 256-bit key
    final iv = Uint8List.fromList(List.generate(16, (i) => i)); // 128-bit IV
    final text = 'Hello, World!';

    test('AES CBC Encrypt and Decrypt', () {
      final encrypted = AESCBCEncrypter.aesCbcEncrypt(key, iv, text);
      final decrypted = AESCBCEncrypter.aesCbcDecrypt(key, iv, encrypted);
      expect(decrypted, text);
    });

    test('AES CBC Encrypt with invalid key length', () {
      final invalidKey =
          Uint8List.fromList(List.generate(10, (i) => i)); // Invalid key length
      expect(
        () => AESCBCEncrypter.aesCbcEncrypt(invalidKey, iv, text),
        throwsArgumentError,
      );
    });

    test('AES CBC Encrypt with invalid IV length', () {
      final invalidIv =
          Uint8List.fromList(List.generate(10, (i) => i)); // Invalid IV length
      expect(
        () => AESCBCEncrypter.aesCbcEncrypt(key, invalidIv, text),
        throwsArgumentError,
      );
    });

    test('AES CBC Decrypt with invalid key length', () {
      final encrypted = AESCBCEncrypter.aesCbcEncrypt(key, iv, text);
      final invalidKey =
          Uint8List.fromList(List.generate(10, (i) => i)); // Invalid key length
      expect(
        () => AESCBCEncrypter.aesCbcDecrypt(invalidKey, iv, encrypted),
        throwsArgumentError,
      );
    });

    test('AES CBC Decrypt with invalid IV length', () {
      final encrypted = AESCBCEncrypter.aesCbcEncrypt(key, iv, text);
      final invalidIv =
          Uint8List.fromList(List.generate(10, (i) => i)); // Invalid IV length
      expect(
        () => AESCBCEncrypter.aesCbcDecrypt(key, invalidIv, encrypted),
        throwsArgumentError,
      );
    });

    test('Generate random bytes', () {
      final randomBytes = AESCBCEncrypter.generateRandomBytes(16);
      expect(randomBytes.length, 16);
    });
  });
}
