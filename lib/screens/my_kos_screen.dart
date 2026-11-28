import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/kos.dart';
import '../providers/kos_provider.dart';
import 'kos_form_screen.dart';

class MyKosScreen extends StatefulWidget {
  const MyKosScreen({super.key});

  @override
  State<MyKosScreen> createState() => _MyKosScreenState();
}

class _MyKosScreenState extends State<MyKosScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<KosProvider>().loadMyKos();
      }
    });
  }

  Future<void> _openForm({Kos? kos}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => KosFormScreen(kos: kos)),
    );
  }

  Future<void> _deleteKos(Kos kos) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Kos'),
          content: Text('Apakah kamu yakin ingin menghapus ${kos.namaKos}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await context.read<KosProvider>().deleteKos(kos.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Kos berhasil dihapus')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menghapus kos: $e')));
    }
  }

  Widget _buildStatistics(List<Kos> kosList) {
    final total = kosList.length;
    final penuh = kosList.where((kos) => kos.isFull).length;
    final tersedia = total - penuh;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistik Kos Saya',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total Kos',
                  value: total.toString(),
                  icon: Icons.home_work,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  title: 'Tersedia',
                  value: tersedia.toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  title: 'Penuh',
                  value: penuh.toString(),
                  icon: Icons.block,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kos Saya')),
      body: Consumer<KosProvider>(
        builder: (context, provider, child) {
          if (provider.isOwnerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.ownerErrorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      provider.ownerErrorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: provider.loadMyKos,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final kosList = provider.myKosList;

          return RefreshIndicator(
            onRefresh: provider.loadMyKos,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _buildStatistics(kosList),

                if (kosList.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Column(
                      children: [
                        Icon(
                          Icons.home_work_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Kamu belum memiliki data kos.',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text('Tekan tombol + untuk menambahkan kos.'),
                      ],
                    ),
                  )
                else
                  ...kosList.map(
                    (kos) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _MyKosCard(
                        kos: kos,
                        onEdit: () => _openForm(kos: kos),
                        onDelete: () => _deleteKos(kos),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kos'),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyKosCard extends StatelessWidget {
  final Kos kos;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MyKosCard({
    required this.kos,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    kos.namaKos,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(kos.isFull ? 'Penuh' : 'Tersedia'),
                  backgroundColor: kos.isFull ? Colors.redAccent : Colors.green,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${kos.area} • ${kos.jenis}'),
            const SizedBox(height: 4),
            Text(kos.alamatLengkap),
            const SizedBox(height: 8),
            Text(
              'Rp${kos.hargaBulanan} / bulan',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text('Kamar tersedia: ${kos.jumlahKamar}'),
            const SizedBox(height: 4),
            Text('Fasilitas: ${kos.fasilitas.join(', ')}'),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.delete),
                  label: const Text('Hapus'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
