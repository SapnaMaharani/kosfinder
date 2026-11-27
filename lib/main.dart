import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    runApp(const _KosFinderConfigErrorApp());
    return;
  }

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseAnonKey,
  );

  runApp(const KosFinderApp());
}

/// Widget root yang dijalankan saat konfigurasi Supabase tersedia.
class KosFinderApp extends StatelessWidget {
  const KosFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KosFinder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const _PlaceholderScreen(),
    );
  }
}

/// Layar sementara — konten nyata akan ditambahkan pada T02 dan seterusnya.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KosFinder')),
      body: const Center(
        child: Text('KosFinder siap digunakan.'),
      ),
    );
  }
}

/// Widget root yang ditampilkan saat SUPABASE_URL atau SUPABASE_ANON_KEY
/// tidak dikonfigurasi melalui --dart-define.
class _KosFinderConfigErrorApp extends StatelessWidget {
  const _KosFinderConfigErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KosFinder',
      home: Scaffold(
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Konfigurasi Supabase tidak ditemukan.\n'
              'Jalankan aplikasi dengan:\n\n'
              'flutter run \\\n'
              '  --dart-define=SUPABASE_URL=<url> \\\n'
              '  --dart-define=SUPABASE_ANON_KEY=<key>',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
