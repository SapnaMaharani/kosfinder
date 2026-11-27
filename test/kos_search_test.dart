
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/kos_list_screen.dart';

// Fake repository untuk pengujian tanpa koneksi database
class SearchFakeKosRepository extends KosRepository {
  final List<Kos> data;

  SearchFakeKosRepository({required this.data})
      : super(
          client: SupabaseClient(
            'https://example.supabase.co',
            'test-anon-key',
          ),
        );

  @override
  Future<List<Kos>> getPublicKos() async {
    return data;
  }
}

// Data kos untuk pengujian
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

// Widget aplikasi untuk pengujian
Widget createSearchTestApp(SearchFakeKosRepository repository) {
  return ChangeNotifierProvider(
    create: (_) => KosProvider(repository: repository)..loadKos(),
    child: const MaterialApp(
      home: KosListScreen(),
    ),
  );
}

void main() {
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

    // Pengujian 1: Pencarian berdasarkan nama
    testWidgets('mencari kos berdasarkan nama', (tester) async {
      await tester.pumpWidget(createSearchTestApp(repository));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'Kos Melati',
      );
      await tester.pumpAndSettle();

      expect(find.text('Kos Melati'), findsNWidgets(2));
      expect(find.text('Kos Harmoni'), findsNothing);
      expect(find.text('Kos Sejahtera'), findsNothing);
    });

    // Pengujian 2: Pencarian berdasarkan alamat
    testWidgets('mencari kos berdasarkan alamat', (tester) async {
      await tester.pumpWidget(createSearchTestApp(repository));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'Jl. Sudirman',
      );
      await tester.pumpAndSettle();

      expect(find.text('Kos Harmoni'), findsOneWidget);
      expect(find.text('Kos Melati'), findsNothing);
      expect(find.text('Kos Sejahtera'), findsNothing);
    });

    // Pengujian 3: Pencarian berdasarkan area
    testWidgets('mencari kos berdasarkan area', (tester) async {
      await tester.pumpWidget(createSearchTestApp(repository));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'Singaraja',
      );
      await tester.pumpAndSettle();

      expect(find.text('Kos Melati'), findsOneWidget);
      expect(find.text('Kos Sejahtera'), findsOneWidget);
      expect(find.text('Kos Harmoni'), findsNothing);
    });

    // Pengujian 4: Pencarian tidak membedakan huruf besar dan kecil
    testWidgets(
      'pencarian tidak membedakan huruf besar dan kecil',
      (tester) async {
        await tester.pumpWidget(createSearchTestApp(repository));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField),
          'SINGARAJA',
        );
        await tester.pumpAndSettle();

        expect(find.text('Kos Melati'), findsOneWidget);
        expect(find.text('Kos Sejahtera'), findsOneWidget);
        expect(find.text('Kos Harmoni'), findsNothing);
      },
    );

    // Pengujian 5: Kos tidak ditemukan
    testWidgets(
      'menampilkan pesan jika kos tidak ditemukan',
      (tester) async {
        await tester.pumpWidget(createSearchTestApp(repository));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField),
          'Kos Bandung',
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Kos tidak ditemukan.'),
          findsOneWidget,
        );
        expect(find.text('Kos Melati'), findsNothing);
        expect(find.text('Kos Harmoni'), findsNothing);
        expect(find.text('Kos Sejahtera'), findsNothing);
      },
    );
  });
}
