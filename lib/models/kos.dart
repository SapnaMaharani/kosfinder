/// Daftar pilihan jenis kos yang valid sesuai PRD.
const List<String> kJenisOptions = ['putra', 'putri', 'campur'];

/// Daftar pilihan fasilitas yang valid sesuai PRD.
const List<String> kFasilitasOptions = [
  'AC',
  'WiFi',
  'kamar mandi dalam',
  'parkir',
];

/// Model data untuk satu entri kos.
///
/// Memetakan baris dari tabel `public.kos` di Supabase.
class Kos {
  final String id;
  final String ownerId;
  final String namaKos;
  final String alamatLengkap;
  final String area;
  final String jenis;
  final int hargaBulanan;
  final int jumlahKamar;
  final List<String> fasilitas;
  final String nomorKontak;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Kos({
    required this.id,
    required this.ownerId,
    required this.namaKos,
    required this.alamatLengkap,
    required this.area,
    required this.jenis,
    required this.hargaBulanan,
    required this.jumlahKamar,
    required this.fasilitas,
    required this.nomorKontak,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Apakah kos ini penuh (jumlah kamar tersisa = 0).
  bool get isFull => jumlahKamar == 0;

  /// Membuat objek [Kos] dari Map JSON (respons Supabase).
  factory Kos.fromJson(Map<String, dynamic> json) {
    return Kos(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      namaKos: json['nama_kos'] as String,
      alamatLengkap: json['alamat_lengkap'] as String,
      area: json['area'] as String,
      jenis: json['jenis'] as String,
      hargaBulanan: (json['harga_bulanan'] as num).toInt(),
      jumlahKamar: (json['jumlah_kamar'] as num).toInt(),
      fasilitas: (json['fasilitas'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      nomorKontak: json['nomor_kontak'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Mengubah objek [Kos] menjadi Map JSON untuk dikirim ke Supabase.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'nama_kos': namaKos,
      'alamat_lengkap': alamatLengkap,
      'area': area,
      'jenis': jenis,
      'harga_bulanan': hargaBulanan,
      'jumlah_kamar': jumlahKamar,
      'fasilitas': fasilitas,
      'nomor_kontak': nomorKontak,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'Kos(id: $id, namaKos: $namaKos, jenis: $jenis)';
}
