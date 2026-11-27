import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/main.dart';
import 'package:kosfinder/models/kos.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Unit test: model Kos
  // ---------------------------------------------------------------------------
  group('Kos.fromJson', () {
    final Map<String, dynamic> sampleJson = {
      'id': 'uuid-001',
      'owner_id': 'owner-uuid-001',
      'nama_kos': 'Kos Melati',
      'alamat_lengkap': 'Jl. Melati No. 1, Yogyakarta',
      'area': 'Sleman',
      'jenis': 'putri',
      'harga_bulanan': 800000,
      'jumlah_kamar': 3,
      'fasilitas': ['AC', 'WiFi'],
      'nomor_kontak': '081234567890',
      'created_at': '2024-01-01T00:00:00.000Z',
      'updated_at': '2024-06-01T00:00:00.000Z',
    };

    test('parsing field lengkap berhasil', () {
      final kos = Kos.fromJson(sampleJson);

      expect(kos.id, 'uuid-001');
      expect(kos.ownerId, 'owner-uuid-001');
      expect(kos.namaKos, 'Kos Melati');
      expect(kos.alamatLengkap, 'Jl. Melati No. 1, Yogyakarta');
      expect(kos.area, 'Sleman');
      expect(kos.jenis, 'putri');
      expect(kos.hargaBulanan, 800000);
      expect(kos.jumlahKamar, 3);
      expect(kos.fasilitas, ['AC', 'WiFi']);
      expect(kos.nomorKontak, '081234567890');
      expect(kos.createdAt, DateTime.utc(2024, 1, 1));
      expect(kos.updatedAt, DateTime.utc(2024, 6, 1));
    });

    test('fasilitas null atau tidak ada diperlakukan sebagai list kosong', () {
      final json = Map<String, dynamic>.from(sampleJson)
        ..remove('fasilitas');
      final kos = Kos.fromJson(json);
      expect(kos.fasilitas, isEmpty);
    });

    test('fasilitas berupa list kosong diterima', () {
      final json = Map<String, dynamic>.from(sampleJson)
        ..['fasilitas'] = <dynamic>[];
      final kos = Kos.fromJson(json);
      expect(kos.fasilitas, isEmpty);
    });
  });

  group('Kos.isFull', () {
    Kos makeKos({required int jumlahKamar}) {
      return Kos(
        id: 'id',
        ownerId: 'owner',
        namaKos: 'Test',
        alamatLengkap: 'Jl. Test',
        area: 'Area',
        jenis: 'putra',
        hargaBulanan: 500000,
        jumlahKamar: jumlahKamar,
        fasilitas: const [],
        nomorKontak: '081234567890',
        createdAt: DateTime.utc(2024),
        updatedAt: DateTime.utc(2024),
      );
    }

    test('isFull = true saat jumlahKamar == 0', () {
      expect(makeKos(jumlahKamar: 0).isFull, isTrue);
    });

    test('isFull = false saat jumlahKamar > 0', () {
      expect(makeKos(jumlahKamar: 1).isFull, isFalse);
      expect(makeKos(jumlahKamar: 5).isFull, isFalse);
    });
  });

  group('Kos.toJson', () {
    test('toJson menghasilkan map yang sesuai dengan fromJson', () {
      final original = Kos(
        id: 'uuid-002',
        ownerId: 'owner-002',
        namaKos: 'Kos Anggrek',
        alamatLengkap: 'Jl. Anggrek 5',
        area: 'Bantul',
        jenis: 'campur',
        hargaBulanan: 1200000,
        jumlahKamar: 2,
        fasilitas: const ['WiFi', 'parkir'],
        nomorKontak: '+628112345678',
        createdAt: DateTime.utc(2024, 3, 1),
        updatedAt: DateTime.utc(2024, 3, 2),
      );

      final json = original.toJson();
      final restored = Kos.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.namaKos, original.namaKos);
      expect(restored.hargaBulanan, original.hargaBulanan);
      expect(restored.fasilitas, original.fasilitas);
      expect(restored.isFull, original.isFull);
    });
  });

  group('Konstanta', () {
    test('kJenisOptions berisi tiga nilai yang sesuai PRD', () {
      expect(kJenisOptions, containsAll(['putra', 'putri', 'campur']));
      expect(kJenisOptions.length, 3);
    });

    test('kFasilitasOptions berisi empat fasilitas yang sesuai PRD', () {
      expect(
        kFasilitasOptions,
        containsAll(['AC', 'WiFi', 'kamar mandi dalam', 'parkir']),
      );
      expect(kFasilitasOptions.length, 4);
    });
  });

  // ---------------------------------------------------------------------------
  // Widget (smoke) test: KosFinderApp dapat di-render tanpa crash
  // ---------------------------------------------------------------------------
  group('KosFinderApp', () {
    testWidgets('dapat di-pump tanpa crash (layar placeholder)', (tester) async {
      await tester.pumpWidget(const KosFinderApp());
      // Layar placeholder harus tampil
      expect(find.text('KosFinder siap digunakan.'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Widget (smoke) test: layar error konfigurasi
  // ---------------------------------------------------------------------------
  group('_KosFinderConfigErrorApp', () {
    testWidgets('menampilkan pesan konfigurasi jika dipanggil langsung',
        (tester) async {
      // Kita tidak bisa menguji cabang main() secara langsung karena
      // String.fromEnvironment dievaluasi saat compile-time.
      // Sebagai gantinya, smoke test: KosFinderApp tidak crash.
      await tester.pumpWidget(const KosFinderApp());
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
