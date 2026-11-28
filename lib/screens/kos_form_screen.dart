
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/kos.dart';
import '../providers/kos_provider.dart';

class KosFormScreen extends StatefulWidget {
  final Kos? kos;

  const KosFormScreen({super.key, this.kos});

  @override
  State<KosFormScreen> createState() => _KosFormScreenState();
}

class _KosFormScreenState extends State<KosFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _namaController;
  late final TextEditingController _alamatController;
  late final TextEditingController _areaController;
  late final TextEditingController _hargaController;
  late final TextEditingController _kamarController;
  late final TextEditingController _kontakController;

  late String _jenis;
  late List<String> _fasilitas;

  bool _isSaving = false;

  bool get _isEditing => widget.kos != null;

  int get _jumlahKamar {
    return int.tryParse(_kamarController.text.trim()) ?? 0;
  }

  bool get _isFull => _jumlahKamar == 0;

  @override
  void initState() {
    super.initState();

    final kos = widget.kos;

    _namaController = TextEditingController(
      text: kos?.namaKos ?? '',
    );

    _alamatController = TextEditingController(
      text: kos?.alamatLengkap ?? '',
    );

    _areaController = TextEditingController(
      text: kos?.area ?? '',
    );

    _hargaController = TextEditingController(
      text: kos?.hargaBulanan.toString() ?? '',
    );

    _kamarController = TextEditingController(
      text: kos?.jumlahKamar.toString() ?? '',
    );

    _kontakController = TextEditingController(
      text: kos?.nomorKontak ?? '',
    );

    _jenis = kos?.jenis ?? kJenisOptions.first;
    _fasilitas = List<String>.from(kos?.fasilitas ?? []);

    _kamarController.addListener(_onJumlahKamarChanged);
  }

  void _onJumlahKamarChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _kamarController.removeListener(_onJumlahKamarChanged);

    _namaController.dispose();
    _alamatController.dispose();
    _areaController.dispose();
    _hargaController.dispose();
    _kamarController.dispose();
    _kontakController.dispose();

    super.dispose();
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kolom wajib diisi';
    }

    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Harga wajib diisi';
    }

    final number = int.tryParse(value.trim());

    if (number == null || number <= 0) {
      return 'Harga harus berupa angka lebih dari 0';
    }

    return null;
  }

  String? _validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Jumlah kamar wajib diisi';
    }

    final number = int.tryParse(value.trim());

    if (number == null || number < 0) {
      return 'Jumlah kamar harus berupa angka minimal 0';
    }

    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fasilitas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu fasilitas'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final data = {
      'nama_kos': _namaController.text.trim(),
      'alamat_lengkap': _alamatController.text.trim(),
      'area': _areaController.text.trim(),
      'jenis': _jenis,
      'harga_bulanan': int.parse(_hargaController.text.trim()),
      'jumlah_kamar': int.parse(_kamarController.text.trim()),
      'fasilitas': _fasilitas,
      'nomor_kontak': _kontakController.text.trim(),
    };

    try {
      final provider = context.read<KosProvider>();

      if (_isEditing) {
        await provider.updateKos(
          widget.kos!.id,
          data,
        );
      } else {
        await provider.addKos(data);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Data kos berhasil diperbarui'
                : 'Kos berhasil ditambahkan',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan kos: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator ?? _validateRequired,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildRoomStatus() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isFull
            ? Colors.red.withValues(alpha: 0.08)
            : Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _isFull ? Colors.red : Colors.green,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isFull ? Icons.cancel_outlined : Icons.check_circle_outline,
            color: _isFull ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _isFull
                  ? 'Status Kos: Penuh'
                  : 'Status Kos: Tersedia ($_jumlahKamar kamar)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _isFull ? Colors.red : Colors.green,
              ),
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
        title: Text(
          _isEditing ? 'Edit Kos' : 'Tambah Kos',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(
              _namaController,
              'Nama Kos',
            ),

            _buildTextField(
              _alamatController,
              'Alamat Lengkap',
            ),

            _buildTextField(
              _areaController,
              'Area',
            ),

            DropdownButtonFormField<String>(
              initialValue: _jenis,
              decoration: const InputDecoration(
                labelText: 'Jenis Kos',
                border: OutlineInputBorder(),
              ),
              items: kJenisOptions.map((jenis) {
                return DropdownMenuItem<String>(
                  value: jenis,
                  child: Text(jenis),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _jenis = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            _buildTextField(
              _hargaController,
              'Harga Bulanan',
              keyboardType: TextInputType.number,
              validator: _validatePrice,
            ),

            _buildTextField(
              _kamarController,
              'Jumlah Kamar',
              keyboardType: TextInputType.number,
              validator: _validateNumber,
            ),

            _buildRoomStatus(),

            _buildTextField(
              _kontakController,
              'Nomor Kontak',
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 8),

            const Text(
              'Fasilitas',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            ...kFasilitasOptions.map((fasilitas) {
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(fasilitas),
                value: _fasilitas.contains(fasilitas),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _fasilitas.add(fasilitas);
                    } else {
                      _fasilitas.remove(fasilitas);
                    }
                  });
                },
              );
            }),

            const SizedBox(height: 20),

            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _isEditing
                            ? 'Simpan Perubahan'
                            : 'Tambah Kos',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
