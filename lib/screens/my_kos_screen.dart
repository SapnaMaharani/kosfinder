
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
      MaterialPageRoute(
        builder: (_) => KosFormScreen(kos: kos),
      ),
    );
  }

  Future<void> _deleteKos(Kos kos) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Kos'),
          content: Text(
            'Apakah kamu yakin ingin menghapus ${kos.namaKos}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kos berhasil dihapus'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus kos: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kos Saya'),
      ),
      body: Consumer<KosProvider>(
        builder: (context, provider, child) {
          if (provider.isOwnerLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
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

          if (provider.myKosList.isEmpty) {
            return RefreshIndicator(
              onRefresh: provider.loadMyKos,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 150),
                  Icon(
                    Icons.home_work_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Kamu belum memiliki data kos.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Tekan tombol + untuk menambahkan kos.',
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadMyKos,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.myKosList.length,
              itemBuilder: (context, index) {
                final kos = provider.myKosList[index];

                return _MyKosCard(
                  kos: kos,
                  onEdit: () => _openForm(kos: kos),
                  onDelete: () => _deleteKos(kos),
                );
              },
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
                if (kos.isFull)
                  const Chip(
                    label: Text('Penuh'),
                    backgroundColor: Colors.redAccent,
                    labelStyle: TextStyle(color: Colors.white),
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
