
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/kos.dart';
import '../providers/kos_provider.dart';
import 'kos_detail_screen.dart';
import 'about_screen.dart';

class KosListScreen extends StatefulWidget {
  const KosListScreen({super.key});

  @override
  State<KosListScreen> createState() => _KosListScreenState();
}

class _KosListScreenState extends State<KosListScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<KosProvider>().loadKos();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KosFinder'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Tentang Aplikasi',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<KosProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.kosList.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null &&
              provider.kosList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.wifi_off,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Gagal memuat daftar kos.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => provider.loadKos(),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: provider.searchKos,
                  decoration: InputDecoration(
                    hintText: 'Cari nama, alamat, atau area kos...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              provider.searchKos('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: provider.kosList.isEmpty
                    ? Center(
                        child: Text(
                          provider.searchQuery.isNotEmpty
                              ? 'Kos tidak ditemukan.'
                              : 'Belum ada data kos tersedia.',
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: provider.loadKos,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.kosList.length,
                          itemBuilder: (context, index) {
                            final kos = provider.kosList[index];
                            return _KosCard(kos: kos);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _KosCard extends StatelessWidget {
  final Kos kos;

  const _KosCard({required this.kos});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KosDetailScreen(kos: kos),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 12),
              Text(
                'Rp${kos.hargaBulanan} / bulan',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Kamar tersedia: ${kos.jumlahKamar}'
                '${kos.isFull ? ' (Penuh)' : ''}',
              ),
              const SizedBox(height: 8),
              Text('Fasilitas: ${kos.fasilitas.join(', ')}'),
            ],
          ),
        ),
      ),
    );
  }
}
