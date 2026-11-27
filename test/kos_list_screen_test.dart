
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/kos_list_screen.dart';

// Fake repository untuk pengujian tanpa koneksi Supabase asli.
class FakeKosRepository extends KosRepository {
  final List<Kos> data;
  final bool shouldFail;
  final Duration delay;

  FakeKosRepository({
    this.data = const [],
    this.shouldFail = false,
    this.delay = Duration.zero,
  }) : super(
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
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }

    if (shouldFail) {
      throw Exception('Koneksi gagal');
    }

    return data;
  }
}

// Membuat data kos untuk kebutuhan pengujian.
Kos createKos({
  required String nama,
  required int jumlahKamar,
}) {
  return Kos(
    id: nama,
    ownerId: 'owner-001',
    namaKos: nama,
    alamatLengkap: 'Jl. Melati No. 1',
    area: 'Singaraja',
    jenis: 'putri',
    hargaBulanan: 850000,
    jumlahKamar: jumlahKamar,
    fasilitas: const ['WiFi', 'AC'],
    nomorKontak: '081234567890',
    createdAt: DateTime.utc(2024),
    updatedAt: DateTime.utc(2024),
  );
}

// Membuat aplikasi pengujian dengan repository palsu.
Widget createTestApp(FakeKosRepository repository) {
  return ChangeNotifierProvider(
    create: (_) => KosProvider(repository: repository),
    child: const MaterialApp(
      home: KosListScreen(),
    ),
  );
}

void main() {
  group('KosListScreen', () {
    // Pengujian 1: Daftar kos berhasil ditampilkan.
    testWidgets(
      'menampilkan daftar kos dari repository',
      (tester) async {
        final repository = FakeKosRepository(
          data: [
            createKos(
              nama: 'Kos Melati',
              jumlahKamar: 3,
            ),
          ],
        );

        await tester.pumpWidget(createTestApp(repository));
        await tester.pumpAndSettle();

        expect(find.text('KosFinder'), findsOneWidget);
        expect(find.text('Kos Melati'), findsOneWidget);
        expect(
          find.text('Kamar tersedia: 3'),
          findsOneWidget,
        );
      },
    );

    // Pengujian 2: Kos penuh menampilkan label Penuh.
    testWidgets(
      'menampilkan label Penuh jika kamar nol',
      (tester) async {
        final repository = FakeKosRepository(
          data: [
            createKos(
              nama: 'Kos Sejahtera',
              jumlahKamar: 0,
            ),
          ],
        );

        await tester.pumpWidget(createTestApp(repository));
        await tester.pumpAndSettle();

        expect(find.text('Kos Sejahtera'), findsOneWidget);
        expect(find.text('Penuh'), findsOneWidget);

        expect(
          find.text('Kamar tersedia: 0 (Penuh)'),
          findsOneWidget,
        );
      },
    );

    // Pengujian 3: Data kosong.
    testWidgets(
      'menampilkan pesan ketika data kosong',
      (tester) async {
        final repository = FakeKosRepository();

        await tester.pumpWidget(createTestApp(repository));
        await tester.pumpAndSettle();

        expect(
          find.text('Belum ada data kos tersedia.'),
          findsOneWidget,
        );
      },
    );

    // Pengujian 4: Loading saat data sedang dimuat.
    testWidgets(
      'menampilkan loading saat data dimuat',
      (tester) async {
        final repository = FakeKosRepository(
          data: [
            createKos(
              nama: 'Kos Melati',
              jumlahKamar: 3,
            ),
          ],
          delay: const Duration(seconds: 2),
        );

        await tester.pumpWidget(createTestApp(repository));
        await tester.pump();

        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
        );

        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        expect(find.text('Kos Melati'), findsOneWidget);
      },
    );

    // Pengujian 5: Error koneksi dan tombol coba lagi.
    testWidgets(
      'menampilkan pesan error dan tombol coba lagi',
      (tester) async {
        final repository = FakeKosRepository(
          shouldFail: true,
        );

        await tester.pumpWidget(createTestApp(repository));
        await tester.pumpAndSettle();

        expect(
          find.text('Gagal memuat daftar kos.'),
          findsOneWidget,
        );

        expect(
          find.text('Coba Lagi'),
          findsOneWidget,
        );
      },
    );
  });
}
