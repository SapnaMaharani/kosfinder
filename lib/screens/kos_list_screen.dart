
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/kos.dart';
import '../providers/kos_provider.dart';
import '../services/auth_service.dart';
import 'about_screen.dart';
import 'kos_detail_screen.dart';
import 'login_screen.dart';
import 'my_kos_screen.dart';

class KosListScreen extends StatefulWidget {
  const KosListScreen({super.key});

  @override
  State<KosListScreen> createState() => _KosListScreenState();
}

class _KosListScreenState extends State<KosListScreen> {
  final TextEditingController _searchController =
      TextEditingController();
  final TextEditingController _minPriceController =
      TextEditingController();
  final TextEditingController _maxPriceController =
      TextEditingController();

  final AuthService _authService = AuthService();

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
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    try {
      await _authService.logout();

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil logout')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout gagal: $e')),
      );
    }
  }

  Future<void> _openLogin() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );

    if (mounted) setState(() {});
  }

  Future<void> _openMyKos() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MyKosScreen(),
      ),
    );

    if (mounted) {
      await context.read<KosProvider>().loadKos();
    }
  }

  void _applyPriceFilter(KosProvider provider) {
    final minText = _minPriceController.text.trim();
    final maxText = _maxPriceController.text.trim();

    final minPrice =
        minText.isEmpty ? null : int.tryParse(minText);
    final maxPrice =
        maxText.isEmpty ? null : int.tryParse(maxText);

    if ((minText.isNotEmpty && minPrice == null) ||
        (maxText.isNotEmpty && maxPrice == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan harga dalam angka yang valid.'),
        ),
      );
      return;
    }

    if ((minPrice != null && minPrice < 0) ||
        (maxPrice != null && maxPrice < 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harga tidak boleh negatif.'),
        ),
      );
      return;
    }

    if (minPrice != null &&
        maxPrice != null &&
        minPrice > maxPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Harga minimum tidak boleh melebihi maksimum.',
          ),
        ),
      );
      return;
    }

    provider.setPriceFilter(
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  void _resetFilters(KosProvider provider) {
    _searchController.clear();
    _minPriceController.clear();
    _maxPriceController.clear();

    provider.searchKos('');
    provider.resetFilters();
    provider.resetPriceFilter();

    setState(() {});
  }

  Widget _buildTypeAndFacilityFilter(KosProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: ExpansionTile(
          leading: const Icon(Icons.tune),
          title: const Text(
            'Filter Jenis dan Fasilitas',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jenis Kos',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String?>(
                    isExpanded: true,
                    value: provider.jenisFilter,
                    hint: const Text('Semua jenis kos'),
                    items: const [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Semua jenis'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'putra',
                        child: Text('Putra'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'putri',
                        child: Text('Putri'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'campur',
                        child: Text('Campur'),
                      ),
                    ],
                    onChanged: provider.setJenisFilter,
                  ),
                  const Divider(),
                  const Text(
                    'Fasilitas',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...[
                    'AC',
                    'WiFi',
                    'kamar mandi dalam',
                    'parkir',
                  ].map(
                    (facility) => CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(facility),
                      value: provider.selectedFacilities
                          .contains(facility),
                      onChanged: (_) {
                        provider.toggleFacility(facility);
                      },
                    ),
                  ),
                  const Text(
                    'Jika memilih beberapa fasilitas, '
                    'kos harus memiliki semuanya.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceFilter(KosProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.filter_alt_outlined),
              SizedBox(width: 8),
              Text(
                'Filter Harga Bulanan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga Minimum',
                    hintText: 'Contoh: 500000',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _maxPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga Maksimum',
                    hintText: 'Contoh: 1000000',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _applyPriceFilter(provider),
                  icon: const Icon(Icons.search),
                  label: const Text('Terapkan Filter'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => _resetFilters(provider),
                child: const Text('Reset'),
              ),
            ],
          ),
          if (provider.minPrice != null ||
              provider.maxPrice != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Filter aktif: '
                '${provider.minPrice == null ? 'Tanpa batas minimum' : 'Rp${provider.minPrice}'}'
                ' - '
                '${provider.maxPrice == null ? 'Tanpa batas maksimum' : 'Rp${provider.maxPrice}'}',
                style: const TextStyle(
                  color: Colors.indigo,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('KosFinder'),
        centerTitle: true,
        actions: [
          if (user == null)
            IconButton(
              icon: const Icon(Icons.login),
              tooltip: 'Login',
              onPressed: _openLogin,
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.home_work_outlined),
              tooltip: 'Kos Saya',
              onPressed: _openMyKos,
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: _logout,
            ),
          ],
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Tentang Aplikasi',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AboutScreen(),
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
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  8,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: provider.searchKos,
                  decoration: InputDecoration(
                    hintText:
                        'Cari nama, alamat, atau area kos...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              provider.searchKos('');
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              _buildPriceFilter(provider),
              _buildTypeAndFacilityFilter(provider),
              Expanded(
                child: provider.kosList.isEmpty
                    ? Center(
                        child: Text(
                          provider.searchQuery.isNotEmpty ||
                                  provider.minPrice != null ||
                                  provider.maxPrice != null ||
                                  provider.jenisFilter != null ||
                                  provider.selectedFacilities.isNotEmpty
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
              builder: (_) => KosDetailScreen(kos: kos),
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
                    )
                  else
                    const Chip(
                      label: Text('Tersedia'),
                      backgroundColor: Colors.green,
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
                kos.isFull
                    ? 'Kamar tersedia: Penuh'
                    : 'Kamar tersedia: ${kos.jumlahKamar}',
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
