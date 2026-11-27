
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/kos.dart';
import '../utils/contact_helper.dart';

class KosDetailScreen extends StatelessWidget {
  final Kos kos;

  const KosDetailScreen({
    super.key,
    required this.kos,
  });

  Future<void> _openWhatsApp(BuildContext context) async {
    try {
      final success = await ContactHelper.openWhatsApp(kos.nomorKontak);

      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WhatsApp tidak dapat dibuka. Silakan salin nomor.'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuka WhatsApp.'),
          ),
        );
      }
    }
  }

  Future<void> _makePhoneCall(BuildContext context) async {
    try {
      final success = await ContactHelper.makePhoneCall(kos.nomorKontak);

      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aplikasi telepon tidak dapat dibuka.'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuka aplikasi telepon.'),
          ),
        );
      }
    }
  }

  Future<void> _copyPhoneNumber(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: ContactHelper.normalizePhone(kos.nomorKontak)),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor kontak berhasil disalin.'),
        ),
      );
    }
  }

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

            Text('Harga: Rp${kos.hargaBulanan} / bulan'),
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
                  .map(
                    (fasilitas) => Chip(
                      label: Text(fasilitas),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 24),

            const Text(
              'Nomor Kontak',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              kos.nomorKontak,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openWhatsApp(context),
                icon: const Icon(Icons.chat),
                label: const Text('Hubungi via WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(14),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copyPhoneNumber(context),
                    icon: const Icon(Icons.copy),
                    label: const Text('Salin Nomor'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _makePhoneCall(context),
                    icon: const Icon(Icons.call),
                    label: const Text('Telepon'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
