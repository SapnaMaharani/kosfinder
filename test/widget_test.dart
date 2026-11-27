
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';

void main() {
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
      expect(kos.area, 'Sleman');
      expect(kos.jenis, 'putri');
      expect(kos.hargaBulanan, 800000);
      expect(kos.jumlahKamar, 3);
      expect(kos.fasilitas, ['AC', 'WiFi']);
      expect(kos.nomorKontak, '081234567890');
    });

    test('fasilitas tidak tersedia menjadi list kosong', () {
      final json = Map<String, dynamic>.from(sampleJson)
        ..remove('fasilitas');

      final kos = Kos.fromJson(json);

      expect(kos.fasilitas, isEmpty);
    });

    test('fasilitas kosong diterima', () {
      final json = Map<String, dynamic>.from(sampleJson)
        ..['fasilitas'] = <dynamic>[];

      final kos = Kos.fromJson(json);

      expect(kos.fasilitas, isEmpty);
    });
  });

  group('Kos.isFull', () {
    Kos makeKos(int jumlahKamar) {
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

    test('true ketika jumlah kamar nol', () {
      expect(makeKos(0).isFull, isTrue);
    });

    test('false ketika kamar masih tersedia', () {
      expect(makeKos(1).isFull, isFalse);
      expect(makeKos(5).isFull, isFalse);
    });
  });

  group('Kos.toJson', () {
    test('data dapat dikembalikan melalui fromJson', () {
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

      final restored = Kos.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.namaKos, original.namaKos);
      expect(restored.hargaBulanan, original.hargaBulanan);
      expect(restored.fasilitas, original.fasilitas);
      expect(restored.isFull, original.isFull);
    });
  });

  group('Konstanta', () {
    test('jenis kos sesuai PRD', () {
      expect(kJenisOptions, ['putra', 'putri', 'campur']);
    });

    test('fasilitas kos sesuai PRD', () {
      expect(
        kFasilitasOptions,
        ['AC', 'WiFi', 'kamar mandi dalam', 'parkir'],
      );
    });
  });
}
