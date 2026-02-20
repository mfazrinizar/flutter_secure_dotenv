# flutter_secure_dotenv Example

A fully working Flutter app demonstrating the **hardcoded key + gitignore**
approach for managing encrypted environment variables with
[flutter_secure_dotenv](https://pub.dev/packages/flutter_secure_dotenv).

## Quick Start

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Create your `.env` file

A sample `.env` is already included. For a real project, add your secrets:

```dotenv
API_BASE_URL=https://api.example.com
API_WEB_SOCKET_URL=wss://api.example.com/socket
```

### 3. Create `lib/env.dart` from the template

```bash
cp lib/env.example.dart lib/env.dart
```

### 4. Run `build_runner`

```bash
dart run build_runner build
```

This generates two files:

- `lib/env.g.dart` — your `.env` values encrypted as a byte array
- `encryption_key.json` — the key and IV used for encryption

### 5. Copy the key into `lib/env.dart`

Open `encryption_key.json`:

```json
{
  "ENCRYPTION_KEY": "base64-encoded-key...",
  "IV": "base64-encoded-iv..."
}
```

Paste `ENCRYPTION_KEY` and `IV` into the constants in `lib/env.dart`:

```dart
static const _encryptionKey = 'base64-encoded-key...';
static const _iv = 'base64-encoded-iv...';
```

### 6. Delete `encryption_key.json`

```bash
rm encryption_key.json
```

### 7. Run the app

```bash
flutter run
```

The app displays the decrypted environment variables in a simple Material UI.

## Verify with Dart CLI

You can verify decryption without running the full Flutter app:

```bash
dart run bin/verify.dart
```

## Project Structure

```
example/
├── .env                  # Sample environment variables
├── .gitignore            # Ignores lib/env.dart, lib/env.g.dart, encryption_key.json
├── build.yaml            # Generator configuration (OUTPUT_FILE)
├── pubspec.yaml          # Flutter app dependencies
├── bin/
│   └── verify.dart       # CLI verification script
└── lib/
    ├── main.dart         # Flutter app UI
    ├── env.example.dart  # Committed template — copy to env.dart
    ├── env.dart          # Real env file with encryption key (GITIGNORED)
    └── env.g.dart        # Generated encrypted values (GITIGNORED)
```

## Important Notes

- **`lib/env.dart` is gitignored** — it contains the encryption key and must
  never be committed. Only `lib/env.example.dart` is checked in.
- **`encryption_key.json` is temporary** — delete it after copying the key
  into `lib/env.dart`.
- **Don't rebuild after pasting the key** — `env.g.dart` is already encrypted
  with the matching key from the same build run. Rebuilding generates a new
  random key that won't match.
- For production, build with `flutter build apk --obfuscate --split-debug-info=debug-info`
  to make the key harder to extract from the binary.

## Security

The encryption key lives in the compiled binary. `--obfuscate` makes it harder
to find but not impossible. This approach is a **speed bump against casual
leaks**, not a fully cryptographic guarantee. For truly sensitive secrets, use a
server-fetched key — see the package [SECURITY.md](../SECURITY.md).
