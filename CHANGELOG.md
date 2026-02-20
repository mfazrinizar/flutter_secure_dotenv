## 2.0.0

- **BREAKING**: Updated `pointycastle` dependency from `^3.9.1` to `^4.0.0`.
- **Security**: Removed insecure `String.fromEnvironment()` / `--dart-define` pattern from examples (addresses [#2](https://github.com/mfazrinizar/flutter_secure_dotenv/issues/2)).
- Added `SECURITY.md` with detailed encryption key management guidance.
- Updated README with security warnings and recommended key provisioning approaches.
- Updated `lints` to `^6.1.0`, `test` to `^1.29.0`.
- Enhanced test coverage from 8 to 43 tests (padding, random byte generation, edge cases).
- Added fully working Flutter example app with hardcoded key + gitignore approach.
- Added 100% `public_member_api_docs` coverage.
- Made `AESCBCEncrypter` non-instantiable (static-only utility class).
- Added library-level dartdoc comments.
- Added GitHub Actions CI workflow.
- Added `CONTRIBUTING.md`.

## 1.0.1

- Refactor README and example.

## 1.0.0

- Initial version.
- Update dependencies and refactor from discontinued secure_dotenv.
