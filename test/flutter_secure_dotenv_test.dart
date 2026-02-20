import 'dart:convert';

import 'package:flutter_secure_dotenv/flutter_secure_dotenv.dart';
import 'package:test/test.dart';

void main() {
  // ── DotEnvGen Tests ──────────────────────────────────────────────────────

  group('DotEnvGen', () {
    test('default values', () {
      final dotenv = DotEnvGen();
      expect(dotenv.filename, '.env');
      expect(dotenv.fieldRename, FieldRename.screamingSnake);
    });

    test('custom values', () {
      final dotenv = DotEnvGen(
        filename: 'custom.env',
        fieldRename: FieldRename.snake,
      );
      expect(dotenv.filename, 'custom.env');
      expect(dotenv.fieldRename, FieldRename.snake);
    });

    test('all FieldRename values are accessible', () {
      for (final rename in FieldRename.values) {
        final dotenv = DotEnvGen(fieldRename: rename);
        expect(dotenv.fieldRename, rename);
      }
    });
  });

  // ── FieldKey Tests ───────────────────────────────────────────────────────

  group('FieldKey', () {
    test('default construction', () {
      const key = FieldKey();
      expect(key.name, isNull);
      expect(key.defaultValue, isNull);
    });

    test('with name', () {
      const key = FieldKey(name: 'MY_KEY');
      expect(key.name, 'MY_KEY');
      expect(key.defaultValue, isNull);
    });

    test('with default value', () {
      const key = FieldKey(defaultValue: 42);
      expect(key.name, isNull);
      expect(key.defaultValue, 42);
    });

    test('with both name and default value', () {
      const key = FieldKey(name: 'PORT', defaultValue: 8080);
      expect(key.name, 'PORT');
      expect(key.defaultValue, 8080);
    });

    test('default value can be non-int types', () {
      const stringKey = FieldKey(defaultValue: 'hello');
      expect(stringKey.defaultValue, 'hello');

      const boolKey = FieldKey(defaultValue: true);
      expect(boolKey.defaultValue, true);

      const doubleKey = FieldKey(defaultValue: 3.14);
      expect(doubleKey.defaultValue, 3.14);
    });
  });

  // ── AESCBCEncrypter Tests ────────────────────────────────────────────────

  group('AESCBCEncrypter', () {
    // Standard test vectors
    final key128 =
        Uint8List.fromList(List.generate(16, (i) => i)); // 128-bit key
    final key192 =
        Uint8List.fromList(List.generate(24, (i) => i)); // 192-bit key
    final key256 =
        Uint8List.fromList(List.generate(32, (i) => i)); // 256-bit key
    final iv = Uint8List.fromList(List.generate(16, (i) => i)); // 128-bit IV

    group('encrypt and decrypt round-trip', () {
      test('with 128-bit key', () {
        const text = 'Hello, World!';
        final encrypted = AESCBCEncrypter.aesCbcEncrypt(key128, iv, text);
        final decrypted = AESCBCEncrypter.aesCbcDecrypt(key128, iv, encrypted);
        expect(decrypted, text);
      });

      test('with 192-bit key', () {
        const text = 'Hello, World!';
        final encrypted = AESCBCEncrypter.aesCbcEncrypt(key192, iv, text);
        final decrypted = AESCBCEncrypter.aesCbcDecrypt(key192, iv, encrypted);
        expect(decrypted, text);
      });

      test('with 256-bit key', () {
        const text = 'Hello, World!';
        final encrypted = AESCBCEncrypter.aesCbcEncrypt(key256, iv, text);
        final decrypted = AESCBCEncrypter.aesCbcDecrypt(key256, iv, encrypted);
        expect(decrypted, text);
      });

      test('with empty string', () {
        const text = '';
        final encrypted = AESCBCEncrypter.aesCbcEncrypt(key256, iv, text);
        final decrypted = AESCBCEncrypter.aesCbcDecrypt(key256, iv, encrypted);
        expect(decrypted, text);
      });

      test('with long text', () {
        final text = 'A' * 10000;
        final encrypted = AESCBCEncrypter.aesCbcEncrypt(key256, iv, text);
        final decrypted = AESCBCEncrypter.aesCbcDecrypt(key256, iv, encrypted);
        expect(decrypted, text);
      });

      test('with special characters', () {
        const text = '!@#\$%^&*()_+-=[]{}|;:\'",.<>?/~`\n\t\r';
        final encrypted = AESCBCEncrypter.aesCbcEncrypt(key256, iv, text);
        final decrypted = AESCBCEncrypter.aesCbcDecrypt(key256, iv, encrypted);
        expect(decrypted, text);
      });

      test('with unicode characters', () {
        const text = '你好世界 🌍 مرحبا العالم こんにちは世界';
        final encrypted = AESCBCEncrypter.aesCbcEncrypt(key256, iv, text);
        final decrypted = AESCBCEncrypter.aesCbcDecrypt(key256, iv, encrypted);
        expect(decrypted, text);
      });

      test('with JSON content', () {
        final jsonContent = jsonEncode({
          'API_KEY': 'sk-1234567890',
          'SECRET': 'my-super-secret',
          'DEBUG': 'true',
          'PORT': '3000',
        });
        final encrypted =
            AESCBCEncrypter.aesCbcEncrypt(key256, iv, jsonContent);
        final decrypted = AESCBCEncrypter.aesCbcDecrypt(key256, iv, encrypted);
        expect(decrypted, jsonContent);
        expect(jsonDecode(decrypted), isA<Map>());
      });

      test('with text exactly one block long (16 bytes)', () {
        const text = '0123456789ABCDEF'; // exactly 16 bytes ASCII
        final encrypted = AESCBCEncrypter.aesCbcEncrypt(key256, iv, text);
        final decrypted = AESCBCEncrypter.aesCbcDecrypt(key256, iv, encrypted);
        expect(decrypted, text);
      });

      test('with text exactly two blocks long (32 bytes)', () {
        const text = '0123456789ABCDEF0123456789ABCDEF'; // 32 bytes
        final encrypted = AESCBCEncrypter.aesCbcEncrypt(key256, iv, text);
        final decrypted = AESCBCEncrypter.aesCbcDecrypt(key256, iv, encrypted);
        expect(decrypted, text);
      });
    });

    group('encryption produces ciphertext', () {
      test('ciphertext differs from plaintext', () {
        const text = 'Hello, World!';
        final encrypted = AESCBCEncrypter.aesCbcEncrypt(key256, iv, text);
        final plainBytes = Uint8List.fromList(utf8.encode(text));
        expect(encrypted, isNot(equals(plainBytes)));
      });

      test('ciphertext length is a multiple of block size', () {
        const text = 'Hello';
        final encrypted = AESCBCEncrypter.aesCbcEncrypt(key256, iv, text);
        expect(encrypted.length % 16, 0);
      });

      test('different keys produce different ciphertext', () {
        const text = 'Hello, World!';
        final encrypted1 = AESCBCEncrypter.aesCbcEncrypt(key128, iv, text);
        final encrypted2 = AESCBCEncrypter.aesCbcEncrypt(key256, iv, text);
        expect(encrypted1, isNot(equals(encrypted2)));
      });

      test('different IVs produce different ciphertext', () {
        const text = 'Hello, World!';
        final iv2 = Uint8List.fromList(List.generate(16, (i) => i + 100));
        final encrypted1 = AESCBCEncrypter.aesCbcEncrypt(key256, iv, text);
        final encrypted2 = AESCBCEncrypter.aesCbcEncrypt(key256, iv2, text);
        expect(encrypted1, isNot(equals(encrypted2)));
      });

      test('same inputs produce same ciphertext (deterministic)', () {
        const text = 'Hello, World!';
        final encrypted1 = AESCBCEncrypter.aesCbcEncrypt(key256, iv, text);
        final encrypted2 = AESCBCEncrypter.aesCbcEncrypt(key256, iv, text);
        expect(encrypted1, equals(encrypted2));
      });
    });

    group('invalid key lengths', () {
      test('encrypt rejects 10-byte key', () {
        final invalidKey = Uint8List.fromList(List.generate(10, (i) => i));
        expect(
          () => AESCBCEncrypter.aesCbcEncrypt(invalidKey, iv, 'test'),
          throwsArgumentError,
        );
      });

      test('encrypt rejects 0-byte key', () {
        final emptyKey = Uint8List(0);
        expect(
          () => AESCBCEncrypter.aesCbcEncrypt(emptyKey, iv, 'test'),
          throwsArgumentError,
        );
      });

      test('encrypt rejects 15-byte key', () {
        final invalidKey = Uint8List.fromList(List.generate(15, (i) => i));
        expect(
          () => AESCBCEncrypter.aesCbcEncrypt(invalidKey, iv, 'test'),
          throwsArgumentError,
        );
      });

      test('encrypt rejects 33-byte key', () {
        final invalidKey = Uint8List.fromList(List.generate(33, (i) => i));
        expect(
          () => AESCBCEncrypter.aesCbcEncrypt(invalidKey, iv, 'test'),
          throwsArgumentError,
        );
      });

      test('decrypt rejects invalid key length', () {
        final encrypted = AESCBCEncrypter.aesCbcEncrypt(key256, iv, 'test');
        final invalidKey = Uint8List.fromList(List.generate(10, (i) => i));
        expect(
          () => AESCBCEncrypter.aesCbcDecrypt(invalidKey, iv, encrypted),
          throwsArgumentError,
        );
      });
    });

    group('invalid IV lengths', () {
      test('encrypt rejects 10-byte IV', () {
        final invalidIv = Uint8List.fromList(List.generate(10, (i) => i));
        expect(
          () => AESCBCEncrypter.aesCbcEncrypt(key256, invalidIv, 'test'),
          throwsArgumentError,
        );
      });

      test('encrypt rejects 0-byte IV', () {
        final emptyIv = Uint8List(0);
        expect(
          () => AESCBCEncrypter.aesCbcEncrypt(key256, emptyIv, 'test'),
          throwsArgumentError,
        );
      });

      test('encrypt rejects 32-byte IV', () {
        final longIv = Uint8List.fromList(List.generate(32, (i) => i));
        expect(
          () => AESCBCEncrypter.aesCbcEncrypt(key256, longIv, 'test'),
          throwsArgumentError,
        );
      });

      test('decrypt rejects invalid IV length', () {
        final encrypted = AESCBCEncrypter.aesCbcEncrypt(key256, iv, 'test');
        final invalidIv = Uint8List.fromList(List.generate(10, (i) => i));
        expect(
          () => AESCBCEncrypter.aesCbcDecrypt(key256, invalidIv, encrypted),
          throwsArgumentError,
        );
      });
    });

    group('invalid ciphertext', () {
      test('decrypt rejects non-block-aligned ciphertext', () {
        final invalidCiphertext = Uint8List.fromList([1, 2, 3, 4, 5]);
        expect(
          () => AESCBCEncrypter.aesCbcDecrypt(key256, iv, invalidCiphertext),
          throwsArgumentError,
        );
      });
    });

    group('padding', () {
      test('pad produces correct length', () {
        final input = Uint8List.fromList([1, 2, 3, 4, 5]);
        final padded = AESCBCEncrypter.pad(input, 16);
        expect(padded.length % 16, 0);
        expect(padded.length, 16);
      });

      test('pad and unpad round-trip', () {
        final input = Uint8List.fromList([1, 2, 3, 4, 5]);
        final padded = AESCBCEncrypter.pad(input, 16);
        final unpadded = AESCBCEncrypter.unpad(padded);
        expect(unpadded, equals(input));
      });

      test('pad full block adds extra block', () {
        final input = Uint8List.fromList(List.generate(16, (i) => i));
        final padded = AESCBCEncrypter.pad(input, 16);
        expect(padded.length, 32); // PKCS7 adds a full padding block
      });

      test('pad and unpad with different block-boundary sizes', () {
        for (var size = 0; size <= 32; size++) {
          final input = Uint8List.fromList(List.generate(size, (i) => i % 256));
          final padded = AESCBCEncrypter.pad(input, 16);
          expect(padded.length % 16, 0);
          final unpadded = AESCBCEncrypter.unpad(padded);
          expect(unpadded, equals(input));
        }
      });
    });

    group('generateRandomBytes', () {
      test('generates correct number of bytes', () {
        for (final n in [1, 16, 32, 64, 128, 256]) {
          final bytes = AESCBCEncrypter.generateRandomBytes(n);
          expect(bytes.length, n);
        }
      });

      test('generates different output on subsequent calls', () {
        final bytes1 = AESCBCEncrypter.generateRandomBytes(32);
        final bytes2 = AESCBCEncrypter.generateRandomBytes(32);
        // Statistically near-impossible for two random 32-byte values to match
        expect(bytes1, isNot(equals(bytes2)));
      });

      test('generated key works for encryption', () {
        final randomKey = AESCBCEncrypter.generateRandomBytes(32);
        final randomIv = AESCBCEncrypter.generateRandomBytes(16);
        const text = 'Test with random key';
        final encrypted =
            AESCBCEncrypter.aesCbcEncrypt(randomKey, randomIv, text);
        final decrypted =
            AESCBCEncrypter.aesCbcDecrypt(randomKey, randomIv, encrypted);
        expect(decrypted, text);
      });
    });

    group('cross-key decryption failure', () {
      test('decrypting with wrong key does not produce original text', () {
        const text = 'Secret data';
        final encrypted = AESCBCEncrypter.aesCbcEncrypt(key256, iv, text);
        // Decryption with wrong key should either throw or produce garbage
        try {
          final wrongKey =
              Uint8List.fromList(List.generate(32, (i) => 255 - i));
          final result = AESCBCEncrypter.aesCbcDecrypt(wrongKey, iv, encrypted);
          expect(result, isNot(equals(text)));
        } catch (_) {
          // Expected — wrong key may cause a padding error
        }
      });
    });
  });

  // ── FieldRename Enum Tests ───────────────────────────────────────────────

  group('FieldRename', () {
    test('has all expected values', () {
      expect(FieldRename.values, hasLength(5));
      expect(FieldRename.values, contains(FieldRename.none));
      expect(FieldRename.values, contains(FieldRename.kebab));
      expect(FieldRename.values, contains(FieldRename.snake));
      expect(FieldRename.values, contains(FieldRename.pascal));
      expect(FieldRename.values, contains(FieldRename.screamingSnake));
    });

    test('enum names match', () {
      expect(FieldRename.none.name, 'none');
      expect(FieldRename.kebab.name, 'kebab');
      expect(FieldRename.snake.name, 'snake');
      expect(FieldRename.pascal.name, 'pascal');
      expect(FieldRename.screamingSnake.name, 'screamingSnake');
    });
  });
}
