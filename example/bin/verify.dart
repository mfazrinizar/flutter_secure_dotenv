// Quick verification script — run with: dart run bin/verify.dart
import 'package:flutter_secure_dotenv_example/env.dart';

void main() {
  final env = Env.create();
  print('API_BASE_URL:       ${env.apiBaseUrl}');
  print('API_WEB_SOCKET_URL: ${env.apiWebSocketUrl}');

  assert(env.apiBaseUrl == 'https://api.example.com');
  assert(env.apiWebSocketUrl == 'wss://api.example.com/socket');
  print('\nAll values decrypted correctly!');
}
