# flutter_secure_dotenv

Introducing `flutter_secure_dotenv` for Flutter and Dart: Enhancing Security for Your Secrets ✨🔒

`flutter_secure_dotenv` takes the security of your sensitive data in dotenv files to the next level. Unlike other dotenv packages that may leave your secrets vulnerable, `flutter_secure_dotenv` prioritizes reliability and protection. Through advanced encryption, robust key management, and efficient secret decryption, `flutter_secure_dotenv` ensures your secrets remain confidential and inaccessible to unauthorized users. Experience enhanced security and peace of mind with `flutter_secure_dotenv` for your Flutter and Dart projects. 🛡️💼

This package continues the discontinued `secure_dotenv` package, providing the same level of security and more.

Upgrade to `flutter_secure_dotenv` today and bid farewell to insecure and flawed dotenv packages. Our carefully crafted solution addresses vulnerabilities. With `flutter_secure_dotenv`, your sensitive data remains under tight control, shielded from potential leaks and prying eyes. Embrace the gold standard of dotenv security by choosing `flutter_secure_dotenv` for your Flutter and Dart development. 🚀✨

#### Platform Support

| Android | iOS | MacOS | Web | Linux | Windows |
| :-----: | :-: | :---: | :-: | :---: | :-----: |
|   ✅    | ✅  |  ✅   | ✅  |  ✅   |   ✅    |

## Installing

To use the `flutter_secure_dotenv` package, you need to add it as a dependency in your Dart project's `pubspec.yaml` file along with the `build_runner` and `flutter_secure_dotenv_generator` packages as dev dependencies:

```yaml
dependencies:
  flutter_secure_dotenv: ^2.0.0

dev_dependencies:
  build_runner: ^2.4.14
  flutter_secure_dotenv_generator: ^2.0.0
```

Then, run the following command to fetch the packages:

```shell
$ dart pub get
```

## ⚠️ Security Notice: Encryption Key Management

> **NEVER** ship `encryption_key.json` or any key file inside your app bundle. A JSON file in the APK/IPA is plaintext — extractable with a simple `unzip`, no decompilation needed. The JSON file from `OUTPUT_FILE` is a **temporary transfer mechanism**: copy the key into your gitignored `env.dart`, then delete the JSON immediately, or GITIGNORE it.

**Recommended approach — hardcode in gitignored `env.dart`:**

```dart
// ✅ env.dart (GITIGNORED — never committed to source control)
//    Copy values from the temporary encryption_key.json, then delete it.
static const _encryptionKey = 'base64-key-from-encryption_key.json';
static const _iv = 'base64-iv-from-encryption_key.json';

static Env create() => Env(_encryptionKey, _iv);
```

> **The honest trade-off**: The key IS in the compiled binary. `--obfuscate` makes it significantly harder to find but not impossible. Without a server, this is a fundamental limitation of all client-side secret management — not specific to this package. For maximum protection, fetch the key from a server at runtime.

**Most secure approach — server-fetched key + `flutter_secure_storage`:**

```dart
// ✅ Key never exists in the binary — fetched from server on first launch
static Future<Env> create() async {
  const storage = FlutterSecureStorage();
  var key = await storage.read(key: 'env_encryption_key');
  var iv = await storage.read(key: 'env_iv');

  if (key == null || iv == null) {
    final keys = await fetchKeysFromServer(); // your secure HTTPS call
    key = keys['ENCRYPTION_KEY']!;
    iv = keys['IV']!;
    await storage.write(key: 'env_encryption_key', value: key);
    await storage.write(key: 'env_iv', value: iv);
  }

  return Env(key, iv);
}
```

For a complete security analysis, see [SECURITY.md](SECURITY.md).

## Usage

To generate Dart classes from a `.env` file using the `flutter_secure_dotenv` package, follow the steps below:

1. Create `env.example.dart` (committed to git as a template) and `.gitignore` entries:

```gitignore
# .gitignore
lib/env.dart
lib/env.g.dart
encryption_key.json
.env*
```

2. Define your environment class in `env.example.dart`:

```dart
import 'package:flutter_secure_dotenv/flutter_secure_dotenv.dart';

part 'env.g.dart';

@DotEnvGen(
  filename: '.env',
  fieldRename: FieldRename.screamingSnake,
)
abstract class Env {
  // Replace with real values from encryption_key.json, then delete the JSON.
  static const _encryptionKey = 'PASTE_BASE64_ENCRYPTION_KEY_HERE';
  static const _iv = 'PASTE_BASE64_IV_HERE';

  static Env create() => Env(_encryptionKey, _iv);

  const factory Env(String encryptionKey, String iv) = _$Env;

  const Env._();

  // Declare your environment variables as abstract getters
  String get apiKey;

  @FieldKey(defaultValue: 1)
  int get version;

  @FieldKey(name: 'DEBUG_MODE', defaultValue: 'false')
  String get debugMode;
}
```

3. Copy the template to create your real `env.dart`:

```shell
$ cp lib/env.example.dart lib/env.dart
```

4. Generate the encrypted env and a temporary key file:

NOTE: Encryption keys must be 128, 192, or 256 bits long.

```shell
# Auto-generate random key/IV and output to a temporary file
$ dart run build_runner build \
    --define flutter_secure_dotenv_generator:flutter_secure_dotenv=OUTPUT_FILE=encryption_key.json
```

Or provide your own key and IV:

```shell
$ dart run build_runner build \
    --define flutter_secure_dotenv_generator:flutter_secure_dotenv=ENCRYPTION_KEY=Your_Base64_Key \
    --define flutter_secure_dotenv_generator:flutter_secure_dotenv=IV=Your_Base64_IV \
    --define flutter_secure_dotenv_generator:flutter_secure_dotenv=OUTPUT_FILE=encryption_key.json
```

If you don't need encryption at all:

```shell
$ dart run build_runner build
```

5. Copy the key values from `encryption_key.json` into your `env.dart`, then **delete the JSON file**:

```shell
# Open encryption_key.json, copy ENCRYPTION_KEY and IV into env.dart, then:
$ rm encryption_key.json
```

> The JSON file is a **temporary transfer mechanism** only. It should never be shipped in your app or committed to git.

6. Use the generated class in your code:

```dart
void main() {
  final env = Env.create();
  print(env.apiKey);
  print(env.version);
  print(env.debugMode);
}
```

7. Build release with obfuscation:

```shell
$ flutter build apk --obfuscate --split-debug-info=build/debug-info
```

## Annotations

### DotEnvGen

The `@DotEnvGen` annotation configures the behavior of the code generation process. It has the following parameters:

- `filename` (optional): Specifies the name of the `.env` file. Default value is `.env`.
- `fieldRename` (optional): Specifies the automatic field renaming behavior. Default value is `FieldRename.screamingSnake`.

### FieldKey

The `@FieldKey` annotation is used to specify additional information for individual environment variables. It has the following parameters:

- `name` (optional): Specifies the key name for the environment variable. If not provided, the default key name is derived from the field name based on the `fieldRename` behavior; see FieldRename Enum for more information.
- `defaultValue` (optional): Specifies a default value for the environment variable if it is not found in the `.env` file.

### FieldRename Enum

The `FieldRename` enum defines the automatic field renaming behavior. It has the following values:

- `none`: Uses the field name without changes.
- `kebab`: Encodes a field named `kebabCase` with a key `kebab-case`.
- `snake`: Encodes a field named `snakeCase` with a key `snake_case`.
- `pascal`: Encodes a field named `pascalCase` with a key `PascalCase`.
- `screamingSnake`: Encodes a field named `screamingSnakeCase` with a key `SCREAMING_SNAKE_CASE`.

## Generated Code

The `flutter_secure_dotenv` package generates the required code based on your annotations and the provided `.env` file. Below is an example of the generated code:

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'example.dart';

// **************************************************************************
// FlutterSecureDotEnvAnnotationGenerator
// **************************************************************************

class _$Env extends Env {
  const _$Env(this._encryptionKey, this._iv) : super._();

  final String _encryptionKey;
  final String _iv;
  static final Uint8List _encryptedValues = Uint8List.fromList([81, 83,...]);
  @override
  String get name => _get('name');

  @override
  int get version => _get('version');

  @override
  e.Test? get test => _get(
        'test',
        fromString: e.Test.values.byName,
      );

  @override
  e.Test get test2 => _get(
        'TEST_2',
        fromString: e.Test.values.byName,
      );

  @override
  String get blah => _get('blah');

  // Code for decrypting the values and retrieving the environment variables
  T _get<T>(
    String key, {
    T Function(String)? fromString,
  }) {
    ...
  }
}
```

## Enum Support

The `flutter_secure_dotenv` package also supports decoding enum values from the encrypted `.env` file. Here is an example of an enum and how it can be decoded:

```dart
enum Test {
  a,
  b,
}
```

Make sure to import the enum file in your code:

```dart
import 'enum.dart' as e;
```

Then, you can define a getter in your environment class as follows:

```dart
e.Test get test2;
```

This setup will ensure that the encrypted value is correctly decrypted and converted to the enum type.

## Limitations

- The `flutter_secure_dotenv` package relies on the `build_runner` tool to generate the required code. Therefore, you need to run `dart run build_runner build` whenever changes are made to the environment class or the `.env` file.
- It is important to keep the encryption key secure and never commit it to version control or expose it in any way. See the [Security Notice](#️-security-notice-encryption-key-management) section above and [SECURITY.md](SECURITY.md) for guidance.
- The package currently supports encryption using the Advanced Encryption Standard (AES) algorithm in Cipher Block Chaining (CBC) mode. Other encryption algorithms and modes may be supported in the future.
- Because we started using pointycastle now we only support CBC for now, but we will add support for other modes in the future. If you need another mode, please open an issue.

## Conclusion

The `flutter_secure_dotenv` package simplifies the process of generating Dart classes from a `.env` file while encrypting sensitive values. By using this package, you can ensure that your environment variables are securely stored and accessed in your Dart application.

Rotate your secrets — make sure the old ones are not valid anymore. If you have any questions or feedback, please feel free to open an issue.

## Features and Bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/mfazrinizar/flutter_secure_dotenv/issues
