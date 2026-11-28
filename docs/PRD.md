# Test Plan – KosFinder Versi 1

## 1. Tujuan Pengujian

Pengujian dilakukan untuk memastikan seluruh fitur KosFinder berjalan sesuai Acceptance Criteria (AC) pada `docs/PRD.md`, termasuk skenario normal, kondisi gagal, validasi input, dan keamanan akses data.

## 2. Tabel Pengujian

| ID | AC terkait | Langkah Pengujian | Hasil yang Diharapkan | Hasil Nyata | Lulus |
|---|---|---|---|---|---|
| TC-01 | US01-AC1 | Buka daftar kos tanpa login ketika data tersedia, termasuk kos dengan jumlah kamar 0. | Daftar menampilkan nama, area, jenis, harga, fasilitas, dan badge Penuh untuk kamar 0. | | |
| TC-02 | US01-AC2 | Buka daftar kos ketika database tidak memiliki data kos. | Tampil state kosong informatif tanpa error atau crash. | | |
| TC-03 | US01-AC3 | Matikan koneksi internet, kemudian buka atau muat ulang daftar kos. | Tampil pesan gagal memuat tanpa aplikasi crash. | | |
| TC-04 | US02-AC1 | Cari kos berdasarkan nama, alamat lengkap, dan area. | Hanya kos yang sesuai kata kunci yang ditampilkan. | | |
| TC-05 | US02-AC1 | Masukkan harga minimum dan maksimum. | Hanya kos dengan harga dalam rentang yang dipilih ditampilkan. | | |
| TC-06 | US02-AC1 | Pilih jenis putra, putri, atau campur. | Hanya kos dengan jenis yang dipilih ditampilkan. | | |
| TC-07 | US02-AC1 | Pilih satu atau beberapa fasilitas baku. | Hanya kos yang memiliki semua fasilitas terpilih ditampilkan (logika AND). | | |
| TC-08 | US02-AC1 | Gunakan kata kunci dan beberapa filter secara bersamaan. | Hasil memenuhi seluruh kriteria pencarian dan filter. | | |
| TC-09 | US02-AC2 | Gunakan kata kunci atau filter yang tidak menghasilkan kos yang cocok. | Tampil pesan tidak ada hasil. | | |
| TC-10 | US02-AC3 | Matikan internet, kemudian jalankan pencarian atau filter yang membutuhkan permintaan data. | Tampil pesan gagal memuat tanpa crash. | | |
| TC-11 | US03-AC1 | Pilih salah satu kos dan buka halaman detail. | Detail menampilkan informasi kos, jumlah kamar/status, fasilitas, nomor kontak, dan tombol WhatsApp. Nomor 08 dinormalisasi menjadi 62 saat membuka WhatsApp. | | |
| TC-12 | US03-AC2 | Uji tombol WhatsApp pada perangkat tanpa aplikasi WhatsApp atau ketika WhatsApp tidak dapat dibuka. | Tersedia alternatif salin nomor atau panggilan telepon tanpa crash. | | |
| TC-13 | US03-AC3 | Matikan internet, kemudian coba membuka detail kos yang memerlukan pemuatan data. | Tampil pesan gagal memuat tanpa crash. | | |
| TC-14 | US04-AC1 | Daftarkan akun pemilik menggunakan email dan password valid, kemudian lakukan login. | Jika konfirmasi email aktif, pengguna diminta mengonfirmasi email. Jika tidak aktif atau sudah terkonfirmasi, sesi aktif dan pengguna dapat mengelola kos. | | |
| TC-15 | US04-AC2 | Uji form auth dengan input kosong, email tidak valid, password salah, email belum terkonfirmasi (jika berlaku), dan kondisi internet mati. | Permintaan ditolak dengan pesan error yang jelas tanpa crash. | | |
| TC-16 | US05-AC1 | Login sebagai pemilik, isi seluruh kolom wajib dengan data valid dan fasilitas opsional, kemudian simpan. | Data tersimpan dengan owner_id sesuai pengguna yang login dan langsung tampil pada daftar publik. | | |
| TC-17 | US05-AC2 | Coba menambah kos dengan kolom wajib kosong. | Form menolak penyimpanan dan menampilkan pesan validasi. | | |
| TC-18 | US05-AC2 | Masukkan harga 0 atau negatif. | Form dan constraint database menolak penyimpanan. | | |
| TC-19 | US05-AC2 | Masukkan jumlah kamar negatif. | Form dan constraint database menolak penyimpanan. | | |
| TC-20 | US05-AC2 | Masukkan nomor kontak yang tidak diawali 08 atau +62. | Form dan constraint database menolak penyimpanan. | | |
| TC-21 | US05-AC2 | Coba mengirim request tambah kos tanpa token autentikasi yang valid. | RLS backend menolak penyimpanan. | | |
| TC-22 | US06-AC1 | Ubah informasi kos milik sendiri, termasuk jumlah kamar menjadi 0 atau mengosongkan fasilitas. | Data berhasil diperbarui dan perubahan status Penuh tampil pada daftar publik. | | |
| TC-23 | US06-AC1 | Hapus kos milik sendiri melalui aplikasi. | Data terhapus permanen dari database dan tidak lagi tampil pada daftar publik. | | |
| TC-24 | US06-AC2 | Login sebagai pemilik yang belum memiliki kos, kemudian buka halaman Kos Saya. | Tampil state kosong informatif. | | |
| TC-25 | US06-AC3 | Login sebagai Pemilik A, kemudian coba mengubah atau menghapus data milik Pemilik B. | RLS menolak operasi, data Pemilik B tetap utuh, dan aplikasi menampilkan pesan akses ditolak. | | |
| TC-26 | NFR Keamanan | Periksa hasil GET publik melalui respons API atau JSON. | Data listing dan kontak yang dipublikasikan tersedia tanpa email akun atau token pemilik. | | |
| TC-27 | NFR Performa | Uji pemuatan daftar dan filter menggunakan 100 data kos pada jaringan 4G. | Daftar dan hasil filter tampil dalam waktu maksimal 3 detik. | | |
| TC-28 | NFR Kemudahan Pakai | Mulai dari halaman daftar tanpa login, lalu buka detail dan opsi kontak. | Pengguna mencapai opsi kontak dalam maksimal 3 ketukan. | | |

## 3. Catatan Pengujian

- Kolom **Hasil Nyata** diisi setelah pengujian dilakukan pada aplikasi.
- Kolom **Lulus** diisi `Ya` jika hasil aktual sesuai harapan, atau `Tidak` jika belum sesuai.
- Pengujian yang belum dilakukan tidak boleh ditandai lulus.
- Pengujian keamanan harus mencakup pemeriksaan kebijakan RLS di backend, bukan hanya tampilan aplikasi.
- Pengujian performa dilakukan menggunakan 100 data kos dan jaringan 4G.

## 4. Ringkasan Hasil Pengujian

| Keterangan | Jumlah |
|---|---:|
| Total kasus pengujian | 28 |
| Lulus | |
| Tidak lulus | |
| Belum diuji | |
