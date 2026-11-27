
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/kos_provider.dart';
import 'repositories/kos_repository.dart';
import 'screens/kos_list_screen.dart';

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

class KosFinderApp extends StatelessWidget {
  const KosFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KosProvider(
        repository: KosRepository(),
      ),
      child: MaterialApp(
        title: 'KosFinder',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
          ),
          useMaterial3: true,
        ),
        home: const KosListScreen(),
      ),
    );
  }
}

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
