import 'package:flutter/material.dart';
import 'env.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_secure_dotenv Example',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const EnvDemoPage(),
    );
  }
}

class EnvDemoPage extends StatefulWidget {
  const EnvDemoPage({super.key});

  @override
  State<EnvDemoPage> createState() => _EnvDemoPageState();
}

class _EnvDemoPageState extends State<EnvDemoPage> {
  late final Env _env;
  String? _error;

  @override
  void initState() {
    super.initState();
    try {
      _env = Env.create();
    } catch (e) {
      _error = e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Dotenv Demo'),
      ),
      body: _error != null ? _buildError() : _buildEnvTable(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Failed to load env:\n$_error',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildEnvTable() {
    final entries = <MapEntry<String, String>>[
      MapEntry('API_BASE_URL', _env.apiBaseUrl),
      MapEntry('API_WEB_SOCKET_URL', _env.apiWebSocketUrl),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Decrypted Environment Variables',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'These values were encrypted at build time and decrypted at runtime '
          'using flutter_secure_dotenv.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        ...entries.map(
          (e) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title:
                  Text(e.key, style: const TextStyle(fontFamily: 'monospace')),
              subtitle: Text(e.value),
            ),
          ),
        ),
      ],
    );
  }
}
