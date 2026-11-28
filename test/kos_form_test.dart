
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/screens/kos_detail_screen.dart';

Kos createLocationKos() {
  return Kos(
    id: 'kos-1',
    ownerId: 'owner-1',
    namaKos: 'Kos Melati',
    alamatLengkap: 'Jl. Melati No. 10, Singaraja',
    area: 'Singaraja',
    jenis: 'putri',
    hargaBulanan: 850000,
    jumlahKamar: 3,
    fasilitas: ['WiFi'],
    nomorKontak: '081234567890',
    createdAt: DateTime.utc(2024),
    updatedAt: DateTime.utc(2024),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('US05-AC3 - Kejelasan Lokasi Kos', () {
    testWidgets(
      'US05-AC3: area dan alamat lengkap tampil pada detail kos',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: KosDetailScreen(
              kos: createLocationKos(),
            ),
          ),
        );

        expect(find.text('Area'), findsOneWidget);
        expect(find.text('Singaraja'), findsOneWidget);

        expect(
          find.text('Alamat Lengkap'),
          findsOneWidget,
        );

        expect(
          find.text('Jl. Melati No. 10, Singaraja'),
          findsOneWidget,
        );
      },
    );
  });
}
