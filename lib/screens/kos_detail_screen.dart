
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
      final success = await ContactHelper.openWhatsApp(
        kos.nomorKontak,
      );

      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'WhatsApp tidak dapat dibuka. Silakan salin nomor.',
            ),
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
      final success = await ContactHelper.makePhoneCall(
        kos.nomorKontak,
      );

      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Aplikasi telepon tidak dapat dibuka.',
            ),
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
      ClipboardData(
        text: ContactHelper.normalizePhone(kos.nomorKontak),
      ),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor kontak berhasil disalin.'),
        ),
      );
    }
  }

  Widget _buildRoomStatus(BuildContext context) {
    final isFull = kos.isFull;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isFull
            ? Colors.red.withValues(alpha: 0.08)
            : Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFull ? Colors.red : Colors.green,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isFull
                ? Icons.cancel_outlined
                : Icons.check_circle_outline,
            color: isFull ? Colors.red : Colors.green,
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFull ? 'Kos Penuh' : 'Kos Tersedia',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isFull ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isFull
                      ? 'Saat ini tidak ada kamar tersedia.'
                      : '${kos.jumlahKamar} kamar masih tersedia.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformation(
    String label,
    String value, {
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 21, color: Colors.grey[700]),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 20),

            _buildRoomStatus(context),

            const SizedBox(height: 24),

            const Text(
              'Informasi Kos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            _buildInformation(
              'Area',
              kos.area,
              icon: Icons.location_on_outlined,
            ),

            _buildInformation(
              'Jenis Kos',
              kos.jenis,
              icon: Icons.home_outlined,
            ),

            _buildInformation(
              'Alamat Lengkap',
              kos.alamatLengkap,
              icon: Icons.map_outlined,
            ),

            _buildInformation(
              'Harga Bulanan',
              'Rp${kos.hargaBulanan} / bulan',
              icon: Icons.payments_outlined,
            ),

            const Divider(height: 32),

            const Text(
              'Fasilitas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            if (kos.fasilitas.isEmpty)
              const Text('Belum ada fasilitas.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kos.fasilitas.map((fasilitas) {
                  return Chip(
                    avatar: const Icon(
                      Icons.check_circle_outline,
                      size: 18,
                    ),
                    label: Text(fasilitas),
                  );
                }).toList(),
              ),

            const SizedBox(height: 28),

            const Text(
              'Informasi Kontak',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _buildInformation(
              'Nomor Kontak Pemilik',
              kos.nomorKontak,
              icon: Icons.phone_outlined,
            ),

            const SizedBox(height: 12),

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

            const SizedBox(height: 10),

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
