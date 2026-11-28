# Test Plan – KosFinder Versi 1

## 1. Tujuan Pengujian
Memastikan fitur KosFinder sesuai Acceptance Criteria (AC) pada `docs/PRD.md`, termasuk skenario normal, kondisi gagal, validasi input, dan keamanan akses data.

## 2. Tabel Pengujian

| ID | AC terkait | Langkah Pengujian | Hasil yang Diharapkan | Hasil Nyata | Lulus |
|---|---|---|---|---|---|
| TC-01 | US01-AC1 | Buka daftar kos tanpa login ketika data tersedia, termasuk kamar 0. | Nama, area, jenis, harga, fasilitas, dan badge Penuh ditampilkan. | | |
| TC-02 | US01-AC2 | Buka daftar saat database belum memiliki data kos. | State kosong informatif tampil tanpa error/crash. | | |
| TC-03 | US01-AC3 | Matikan internet lalu muat daftar kos. | Pesan gagal memuat tampil tanpa crash. | | |
| TC-04 | US02-AC1 | Cari berdasarkan nama kos. | Hanya hasil yang sesuai ditampilkan. | | |
| TC-05 | US02-AC1 | Cari berdasarkan alamat lengkap. | Hanya hasil yang sesuai ditampilkan. | | |
| TC-06 | US02-AC1 | Cari berdasarkan area. | Hanya hasil yang sesuai ditampilkan. | | |
| TC-07 | US02-AC1 | Masukkan harga minimum dan maksimum. | Hanya kos dalam rentang harga ditampilkan. | | |
| TC-08 | US02-AC1 | Pilih jenis putra, putri, atau campur. | Hanya kos dengan jenis terpilih ditampilkan. | | |
| TC-09 | US02-AC1 | Pilih satu fasilitas baku, misalnya WiFi. | Hanya kos yang memiliki fasilitas tersebut ditampilkan. | | |
| TC-10 | US02-AC1 | Pilih beberapa fasilitas sekaligus. | Hanya kos yang memiliki semua fasilitas terpilih (AND) ditampilkan. | | |
| TC-11 | US02-AC1 | Gabungkan kata kunci, harga, jenis, dan fasilitas. | Hasil memenuhi seluruh kriteria. | | |
| TC-12 | US02-AC2 | Gunakan kata kunci/filter yang tidak cocok dengan data. | Pesan tidak ada hasil tampil. | | |
| TC-13 | US02-AC3 | Matikan internet lalu jalankan pencarian/filter. | Pesan gagal memuat tampil tanpa crash. | | |
| TC-14 | US03-AC1 | Buka detail salah satu kos. | Detail lengkap, status kamar, fasilitas, kontak, dan tombol WhatsApp tampil; nomor 08 dinormalisasi menjadi 62. | | |
| TC-15 | US03-AC2 | Uji WhatsApp saat aplikasi tidak tersedia/tidak dapat dibuka. | Alternatif salin nomor atau telepon tersedia tanpa crash. | | |
| TC-16 | US03-AC3 | Matikan internet lalu buka detail yang membutuhkan pemuatan data. | Pesan gagal memuat tampil tanpa crash. | | |
| TC-17 | US04-AC1 | Daftar dan login dengan email/password valid. | Jika konfirmasi email aktif, pengguna diminta konfirmasi; jika tidak, sesi aktif dan halaman kelola kos terbuka. | | |
| TC-18 | US04-AC2 | Submit form auth dengan input kosong/email tidak valid. | Submit ditolak dengan pesan validasi jelas. | | |
| TC-19 | US04-AC2 | Login dengan password salah/email belum terkonfirmasi (jika berlaku). | Login ditolak dengan pesan jelas tanpa crash. | | |
| TC-20 | US04-AC2 | Matikan internet lalu submit form auth. | Permintaan gagal dengan pesan jelas tanpa crash. | | |
| TC-21 | US05-AC1 | Login, isi kolom wajib valid, pilih fasilitas opsional, lalu simpan. | Data tersimpan dengan `owner_id = auth.uid()` dan langsung tayang. | | |
| TC-22 | US05-AC2 | Simpan kos dengan kolom wajib kosong. | UI menolak penyimpanan dan menampilkan validasi. | | |
| TC-23 | US05-AC2/NFR Keamanan | Masukkan harga 0 atau negatif. | UI dan constraint database menolak penyimpanan. | | |
| TC-24 | US05-AC2/NFR Keamanan | Masukkan jumlah kamar negatif. | UI dan constraint database menolak penyimpanan. | | |
| TC-25 | US05-AC2/NFR Keamanan | Masukkan kontak bukan berawalan 08 atau +62. | UI dan constraint database menolak penyimpanan. | | |
| TC-26 | US05-AC2 | Kirim request tambah kos tanpa token autentikasi valid. | RLS backend menolak penyimpanan. | | |
| TC-27 | US06-AC1 | Ubah kos sendiri, termasuk kamar menjadi 0 atau fasilitas dikosongkan. | Data diperbarui; badge Penuh tampil jika kamar 0; fasilitas boleh kosong. | | |
| TC-28 | US06-AC1 | Hapus kos sendiri melalui aplikasi. | Data terhapus permanen dari database dan daftar publik. | | |
| TC-29 | US06-AC2 | Login sebagai pemilik tanpa kos lalu buka Kos Saya. | State kosong informatif tampil. | | |
| TC-30 | US06-AC3/NFR Keamanan | Pemilik A mencoba mengubah/menghapus kos Pemilik B, termasuk manipulasi ID request. | RLS menolak; data B tetap utuh dan aplikasi menampilkan akses ditolak. | | |
| TC-31 | NFR Privasi | Periksa JSON dari GET publik. | Hanya data listing dan kontak publik yang dikirim; tanpa email/token pemilik. | | |
| TC-32 | NFR Performa | Uji daftar dan filter dengan 100 data pada jaringan 4G. | Daftar dan filter tampil maksimal 3 detik. | | |
| TC-33 | NFR Kemudahan Pakai | Dari daftar tanpa login, buka detail dan opsi kontak. | Opsi kontak dicapai maksimal 3 ketukan. | | |
| TC-34 | NFR Keandalan | Uji layar dan fitur yang membutuhkan koneksi dalam mode airplane. | Aplikasi tidak crash dan menampilkan penanganan gagal koneksi. | | |

## 3. Catatan
- Isi **Hasil Nyata** setelah skenario benar-benar dijalankan.
- Isi **Lulus** dengan `Ya` atau `Tidak` berdasarkan hasil aktual.
- Skenario yang belum diuji harus dibiarkan kosong.
- Pengujian keamanan harus memeriksa RLS backend, bukan hanya UI.
- Pengujian performa membutuhkan 100 data kos dan jaringan 4G.
- Uji WhatsApp pada perangkat dengan dan tanpa aplikasi WhatsApp jika memungkinkan.

## 4. Ringkasan
| Keterangan | Jumlah |
|---|---:|
| Total kasus pengujian | 34 |
| Lulus | |
| Tidak lulus | |
| Belum diuji | 34 |
