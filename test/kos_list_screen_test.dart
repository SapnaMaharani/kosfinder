
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/kos_list_screen.dart';

// Fake repository untuk pengujian tanpa koneksi database.
class SearchFakeKosRepository extends KosRepository {
  final List<Kos> data;

  SearchFakeKosRepository({required this.data})
      : super(
          client: SupabaseClient(
            'https://example.supabase.co',
            'test-anon-key',
            authOptions: const AuthClientOptions(
              autoRefreshToken: false,
            ),
          ),
        );

  @override
  Future<List<Kos>> getPublicKos() async {
    return data;
  }
}

// Membuat data kos untuk pengujian.
Kos createSearchKos({
  required String nama,
  required String alamat,
  required String area,
}) {
  return Kos(
    id: nama,
    ownerId: 'owner-1',
    namaKos: nama,
    alamatLengkap: alamat,
    area: area,
    jenis: 'putri',
    hargaBulanan: 850000,
    jumlahKamar: 3,
    fasilitas: ['WiFi', 'Parkir'],
    nomorKontak: '081234567890',
    createdAt: DateTime.utc(2024),
    updatedAt: DateTime.utc(2024),
  );
}

// Widget aplikasi untuk pengujian.
Widget createSearchTestApp(SearchFakeKosRepository repository) {
  return ChangeNotifierProvider(
    create: (_) => KosProvider(repository: repository),
    child: const MaterialApp(
      home: KosListScreen(),
    ),
  );
}

// Finder kolom pencarian.
Finder get searchTextField => find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.hintText ==
              'Cari nama, alamat, atau area kos...',
      description: 'Kolom pencarian kos',
    );

// Mengambil Provider dari widget.
KosProvider getKosProvider(WidgetTester tester) {
  return Provider.of<KosProvider>(
    tester.element(find.byType(KosListScreen)),
    listen: false,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});

    await Supabase.initialize(
      url: 'https://example.supabase.co',
      publishableKey: 'test-anon-key',
    );
  });

  group('Kos List Screen Test', () {
    late SearchFakeKosRepository repository;

    setUp(() {
      repository = SearchFakeKosRepository(
        data: [
          createSearchKos(
            nama: 'Kos Melati',
            alamat: 'Jl. Melati No. 1',
            area: 'Singaraja',
          ),
          createSearchKos(
            nama: 'Kos Sejahtera',
            alamat: 'Jl. Merdeka No. 5',
            area: 'Singaraja',
          ),
          createSearchKos(
            nama: 'Kos Harmoni',
            alamat: 'Jl. Sudirman No. 10',
            area: 'Denpasar',
          ),
        ],
      );
    });

    // TEST 1: Pencarian berdasarkan nama.
    testWidgets('mencari kos berdasarkan nama', (tester) async {
      await tester.pumpWidget(createSearchTestApp(repository));
      await tester.pumpAndSettle();

      await tester.enterText(searchTextField, 'Kos Melati');
      await tester.pumpAndSettle();

      final provider = getKosProvider(tester);
      final hasil = provider.kosList.map((kos) => kos.namaKos).toList();

      expect(hasil, ['Kos Melati']);
    });

    // TEST 2: Pencarian berdasarkan alamat lengkap.
    testWidgets('mencari kos berdasarkan alamat lengkap',
        (tester) async {
      await tester.pumpWidget(createSearchTestApp(repository));
      await tester.pumpAndSettle();

      await tester.enterText(
        searchTextField,
        'Jl. Sudirman No. 10',
      );
      await tester.pumpAndSettle();

      final provider = getKosProvider(tester);
      final hasil = provider.kosList.map((kos) => kos.namaKos).toList();

      expect(hasil, ['Kos Harmoni']);
    });

    // TEST 3: Pencarian berdasarkan area.
    testWidgets('mencari kos berdasarkan area', (tester) async {
      await tester.pumpWidget(createSearchTestApp(repository));
      await tester.pumpAndSettle();

      await tester.enterText(searchTextField, 'Singaraja');
      await tester.pumpAndSettle();

      final provider = getKosProvider(tester);
      final hasil = provider.kosList.map((kos) => kos.namaKos).toList();

      expect(hasil, contains('Kos Melati'));
      expect(hasil, contains('Kos Sejahtera'));
      expect(hasil, isNot(contains('Kos Harmoni')));
      expect(hasil.length, 2);
    });

    // TEST 4: Pencarian tidak membedakan huruf besar dan kecil.
    testWidgets(
      'pencarian tidak membedakan huruf besar dan kecil',
      (tester) async {
        await tester.pumpWidget(createSearchTestApp(repository));
        await tester.pumpAndSettle();

        await tester.enterText(searchTextField, 'SINGARAJA');
        await tester.pumpAndSettle();

        final provider = getKosProvider(tester);
        final hasil =
            provider.kosList.map((kos) => kos.namaKos).toList();

        expect(hasil, contains('Kos Melati'));
        expect(hasil, contains('Kos Sejahtera'));
        expect(hasil, isNot(contains('Kos Harmoni')));
        expect(hasil.length, 2);
      },
    );

    // TEST 5: Menampilkan pesan jika kos tidak ditemukan.
    testWidgets(
      'menampilkan pesan jika kos tidak ditemukan',
      (tester) async {
        await tester.pumpWidget(createSearchTestApp(repository));
        await tester.pumpAndSettle();

        await tester.enterText(searchTextField, 'Kos Bandung');
        await tester.pumpAndSettle();

        expect(
          find.text('Kos tidak ditemukan.'),
          findsOneWidget,
        );

        final provider = getKosProvider(tester);
        expect(provider.kosList, isEmpty);
      },
    );
  });
}
