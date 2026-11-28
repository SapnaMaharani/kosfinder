
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

// Finder khusus kolom pencarian.
Finder get searchTextField => find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.hintText ==
              'Cari nama, alamat, atau area kos...',
      description: 'Kolom pencarian kos',
    );

// Finder khusus nama kos pada daftar.
Finder kosName(String name) {
  return find.byWidgetPredicate(
    (widget) => widget is Text && widget.data == name,
    description: 'Nama kos $name',
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

  group('Kos Search Test', () {
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
            nama: 'Kos Harmoni',
            alamat: 'Jl. Sudirman No. 10',
            area: 'Denpasar',
          ),
          createSearchKos(
            nama: 'Kos Sejahtera',
            alamat: 'Jl. Merdeka No. 5',
            area: 'Singaraja',
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

      expect(kosName('Kos Melati'), findsOneWidget);
      expect(kosName('Kos Harmoni'), findsNothing);
      expect(kosName('Kos Sejahtera'), findsNothing);
    });

    // TEST 2: Pencarian berdasarkan alamat.
    testWidgets('mencari kos berdasarkan alamat', (tester) async {
      await tester.pumpWidget(createSearchTestApp(repository));
      await tester.pumpAndSettle();

      await tester.enterText(searchTextField, 'Jl. Sudirman');
      await tester.pumpAndSettle();

      expect(kosName('Kos Harmoni'), findsOneWidget);
      expect(kosName('Kos Melati'), findsNothing);
      expect(kosName('Kos Sejahtera'), findsNothing);
    });

    // TEST 3: Pencarian berdasarkan area.
    testWidgets('mencari kos berdasarkan area', (tester) async {
      await tester.pumpWidget(createSearchTestApp(repository));
      await tester.pumpAndSettle();

      await tester.enterText(searchTextField, 'Singaraja');
      await tester.pumpAndSettle();

      final provider = Provider.of<KosProvider>(
        tester.element(find.byType(KosListScreen)),
        listen: false,
      );

      final hasilPencarian =
          provider.kosList.map((kos) => kos.namaKos).toList();

      expect(hasilPencarian, contains('Kos Melati'));
      expect(hasilPencarian, contains('Kos Sejahtera'));
      expect(hasilPencarian, isNot(contains('Kos Harmoni')));
    });

    // TEST 4: Pencarian tidak membedakan huruf besar dan kecil.
    testWidgets(
      'pencarian tidak membedakan huruf besar dan kecil',
      (tester) async {
        await tester.pumpWidget(createSearchTestApp(repository));
        await tester.pumpAndSettle();

        await tester.enterText(searchTextField, 'SINGARAJA');
        await tester.pumpAndSettle();

        final provider = Provider.of<KosProvider>(
          tester.element(find.byType(KosListScreen)),
          listen: false,
        );

        final hasilPencarian =
            provider.kosList.map((kos) => kos.namaKos).toList();

        expect(hasilPencarian, contains('Kos Melati'));
        expect(hasilPencarian, contains('Kos Sejahtera'));
        expect(hasilPencarian, isNot(contains('Kos Harmoni')));
      },
    );

    // TEST 5: Kos tidak ditemukan.
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

        expect(kosName('Kos Melati'), findsNothing);
        expect(kosName('Kos Harmoni'), findsNothing);
        expect(kosName('Kos Sejahtera'), findsNothing);
      },
    );
  });
}
