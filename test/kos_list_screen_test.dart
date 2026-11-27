
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/kos_list_screen.dart';

class SearchFakeKosRepository extends KosRepository {
  final List<Kos> data;

  SearchFakeKosRepository({required this.data})
      : super(
          client: SupabaseClient(
            'https://example.supabase.co',
            'test-key',
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

Kos createSearchKos({
  required String nama,
  required String alamat,
  required String area,
}) {
  return Kos(
    id: nama,
    ownerId: 'owner-001',
    namaKos: nama,
    alamatLengkap: alamat,
    area: area,
    jenis: 'putri',
    hargaBulanan: 850000,
    jumlahKamar: 3,
    fasilitas: const ['WiFi', 'AC'],
    nomorKontak: '081234567890',
    createdAt: DateTime.utc(2024),
    updatedAt: DateTime.utc(2024),
  );
}

Widget createSearchTestApp(SearchFakeKosRepository repository) {
  return ChangeNotifierProvider(
    create: (_) => KosProvider(repository: repository),
    child: const MaterialApp(
      home: KosListScreen(),
    ),
  );
}

void main() {
  group('Kos Search Test', () {
    final kosData = [
      createSearchKos(
        nama: 'Kos Melati',
        alamat: 'Jl. Pendidikan No. 10',
        area: 'Singaraja',
      ),
      createSearchKos(
        nama: 'Kos Sejahtera',
        alamat: 'Jl. Udayana No. 25',
        area: 'Singaraja',
      ),
      createSearchKos(
        nama: 'Kos Harmoni',
        alamat: 'Jl. Ahmad Yani No. 15',
        area: 'Denpasar',
      ),
    ];

    // Pengujian 1: Pencarian berdasarkan nama kos.
    testWidgets(
      'mencari kos berdasarkan nama',
      (tester) async {
        final repository = SearchFakeKosRepository(
          data: kosData,
        );

        await tester.pumpWidget(
          createSearchTestApp(repository),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField),
          'Kos Melati',
        );
        await tester.pumpAndSettle();

        expect(find.text('Kos Melati'), findsNWidgets(2));
        expect(find.text('Kos Sejahtera'), findsNothing);
        expect(find.text('Kos Harmoni'), findsNothing);
      },
    );

    // Pengujian 2: Pencarian berdasarkan alamat.
    testWidgets(
      'mencari kos berdasarkan alamat lengkap',
      (tester) async {
        final repository = SearchFakeKosRepository(
          data: kosData,
        );

        await tester.pumpWidget(
          createSearchTestApp(repository),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField),
          'Udayana',
        );
        await tester.pumpAndSettle();

        expect(find.text('Kos Sejahtera'), findsOneWidget);
        expect(find.text('Kos Melati'), findsNothing);
      },
    );

    // Pengujian 3: Pencarian berdasarkan area.
    testWidgets(
      'mencari kos berdasarkan area',
      (tester) async {
        final repository = SearchFakeKosRepository(
          data: kosData,
        );

        await tester.pumpWidget(
          createSearchTestApp(repository),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField),
          'Singaraja',
        );
        await tester.pumpAndSettle();

        expect(find.text('Kos Melati'), findsOneWidget);
        expect(find.text('Kos Sejahtera'), findsOneWidget);
        expect(find.text('Kos Harmoni'), findsNothing);
      },
    );

    // Pengujian 4: Pencarian tidak membedakan huruf besar dan kecil.
    testWidgets(
      'pencarian tidak membedakan huruf besar dan kecil',
      (tester) async {
        final repository = SearchFakeKosRepository(
          data: kosData,
        );

        await tester.pumpWidget(
          createSearchTestApp(repository),
        );
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

    // Pengujian 5: Pesan ketika hasil pencarian kosong.
    testWidgets(
      'menampilkan pesan jika kos tidak ditemukan',
      (tester) async {
        final repository = SearchFakeKosRepository(
          data: kosData,
        );

        await tester.pumpWidget(
          createSearchTestApp(repository),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField),
          'Bandung',
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Kos tidak ditemukan.'),
          findsOneWidget,
        );
      },
    );
  });
}
