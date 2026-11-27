
import 'package:flutter/material.dart';

import '../models/kos.dart';

class KosDetailScreen extends StatelessWidget {
  final Kos kos;

  const KosDetailScreen({
    super.key,
    required this.kos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kos'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kos.namaKos,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text('Area: ${kos.area}'),
            const SizedBox(height: 8),
            Text('Jenis: ${kos.jenis}'),
            const SizedBox(height: 8),
            Text('Alamat: ${kos.alamatLengkap}'),
            const SizedBox(height: 8),
            Text(
              'Harga: Rp${kos.hargaBulanan} / bulan',
            ),
            const SizedBox(height: 8),
            Text('Kamar tersedia: ${kos.jumlahKamar}'),
            const SizedBox(height: 8),
            Text(
              'Status: ${kos.isFull ? 'Penuh' : 'Tersedia'}',
              style: TextStyle(
                color: kos.isFull ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Fasilitas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: kos.fasilitas
                  .map((fasilitas) => Chip(
                        label: Text(fasilitas),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nomor Kontak',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(kos.nomorKontak),
          ],
        ),
      ),
    );
  }
}
