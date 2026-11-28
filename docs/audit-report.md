# Audit Report – KosFinder Versi 1

**Tanggal pemeriksaan:** 28 November 2026  
**Acuan:** `docs/PRD.md`, `AGENTS.md`, dan hasil pemeriksaan project yang tersedia.

## 1. Tujuan

Laporan ini mendokumentasikan pemeriksaan awal kesesuaian implementasi KosFinder terhadap PRD Versi 1 dan aturan kerja pada `AGENTS.md`. Pemeriksaan dilakukan tanpa mengubah kode aplikasi maupun konfigurasi database.

## 2. Ringkasan Hasil

| Area pemeriksaan | Hasil | Catatan |
|---|---|---|
| Analisis statis Flutter | Lulus | `flutter analyze` menghasilkan `No issues found!` |
| Pengujian otomatis | Lulus | `flutter test` menghasilkan `18` tes lulus |
| Konfigurasi Supabase di `lib/main.dart` | Sesuai pada file yang diperiksa | URL dan publishable/anon key dibaca melalui `String.fromEnvironment`; aplikasi menampilkan layar konfigurasi jika nilainya kosong |
| Pencarian pola nama secret | Tidak ditemukan | Pencarian pada file `.dart`, `.sql`, `.yaml`, `.yml`, dan `.json` tidak menghasilkan kecocokan untuk `service_role`, `SUPABASE_SECRET_KEY`, atau `secretKey`; ini bukan audit menyeluruh seluruh kemungkinan lokasi rahasia |
| Policy RLS tabel `public.kos` | Sesuai secara definisi | Empat policy ditemukan: SELECT publik, INSERT milik sendiri, UPDATE milik sendiri, DELETE milik sendiri |
| Status RLS tabel `public.kos` | Aktif | `rowsecurity = true` |
| Struktur kolom tabel | Sebagian sesuai | Kolom wajib terdeteksi `NOT NULL`; `owner_id` memiliki default `auth.uid()`; `fasilitas` `NOT NULL` dengan default array kosong |
| Constraint database | Ditemukan | Constraint nama/alamat/area tidak kosong, jenis valid, harga positif, jumlah kamar non-negatif, format kontak, fasilitas baku, foreign key pemilik, dan primary key |

## 3. Temuan Terperinci

### 3.1 Analisis dan pengujian otomatis

- `flutter analyze`: **Lulus**, output `No issues found!`.
- `flutter test`: **Lulus**, output `18 tests passed`.

Hasil ini menunjukkan tidak ada masalah yang dilaporkan oleh analyzer dan seluruh tes otomatis yang tersedia pada saat pemeriksaan berhasil. Hasil tersebut tidak membuktikan seluruh skenario manual pada PRD telah diuji.

### 3.2 Konfigurasi Supabase dan pemeriksaan secret

Pada `lib/main.dart`, konfigurasi dibaca menggunakan:

- `String.fromEnvironment('SUPABASE_URL')`
- `String.fromEnvironment('SUPABASE_ANON_KEY')`

Aplikasi memeriksa apakah kedua nilai kosong sebelum menginisialisasi Supabase. Ini sesuai dengan aturan konfigurasi `--dart-define` dalam `AGENTS.md`.

Pencarian pola nama secret pada file `.dart`, `.sql`, `.yaml`, `.yml`, dan `.json` yang tidak berada di folder build, `.dart_tool`, atau `.git` tidak menemukan kecocokan. Pemeriksaan ini terbatas pada pola dan ekstensi tersebut; bukan bukti bahwa semua file atau seluruh riwayat Git bebas rahasia.

### 3.3 Row Level Security

Hasil query `pg_policies` untuk `public.kos`:

| Policy | Operasi | Definisi yang terlihat | Penilaian |
|---|---|---|---|
| `kos_select_public` | SELECT | `qual = true` | Akses baca publik |
| `kos_insert_own` | INSERT | `with_check = (auth.uid() = owner_id)` | Membatasi insert pada pemilik yang login |
| `kos_update_own` | UPDATE | `qual` dan `with_check` = `(auth.uid() = owner_id)` | Membatasi baris yang dapat diubah dan nilai baris hasil perubahan |
| `kos_delete_own` | DELETE | `qual = (auth.uid() = owner_id)` | Membatasi penghapusan pada pemilik yang login |

Query `pg_tables` menunjukkan `rowsecurity = true` untuk tabel `kos`.

**Batas verifikasi:** definisi policy dan status RLS sudah diperiksa. Penolakan request lintas pemilik di backend perlu dibuktikan dengan pengujian langsung menggunakan dua akun dan pemeriksaan bahwa data pemilik lain tidak berubah.

### 3.4 Struktur kolom dan constraint

Hasil pemeriksaan kolom menunjukkan `id`, `owner_id`, `nama_kos`, `alamat_lengkap`, `area`, `jenis`, `harga_bulanan`, `jumlah_kamar`, `fasilitas`, `nomor_kontak`, `created_at`, dan `updated_at` memiliki `is_nullable = NO`.

`owner_id` memiliki default `auth.uid()`. `fasilitas` memiliki default array kosong, tetapi kolomnya tetap `NOT NULL`. Hal ini dapat mendukung fasilitas opsional jika aplikasi menyimpan array kosong (`[]`) ketika tidak ada fasilitas dipilih.

Constraint yang ditemukan:

- `kos_nama_kos_not_empty`
- `kos_alamat_lengkap_not_empty`
- `kos_area_not_empty`
- `kos_jenis_valid`
- `kos_harga_bulanan_positive`
- `kos_jumlah_kamar_non_negative`
- `kos_nomor_kontak_format`
- `kos_fasilitas_allowed`
- `kos_owner_id_fkey`
- `kos_pkey`

Definisi constraint harga, jumlah kamar, jenis, kontak, dan fasilitas terlihat sejalan dengan aturan data PRD. Pengujian negatif langsung ke database tetap perlu dilakukan untuk membuktikan constraint menolak nilai yang tidak valid.

## 4. Hal yang Masih Perlu Diverifikasi

Bagian berikut belum dapat dinyatakan lulus hanya berdasarkan bukti pemeriksaan di atas:

1. Filter jenis dan fasilitas baku dengan logika AND, termasuk kombinasi bersama kata kunci dan rentang harga.
2. Penanganan internet mati pada daftar, pencarian/filter, autentikasi, dan detail; pastikan tidak terjadi crash.
3. Perilaku tombol WhatsApp pada perangkat tanpa aplikasi WhatsApp serta alternatif salin nomor/telepon.
4. Pemeriksaan respons GET publik untuk memastikan email akun, token, dan metadata autentikasi tidak terekspos.
5. Pengujian negatif database untuk harga `<= 0`, jumlah kamar `< 0`, format kontak tidak valid, dan request tanpa token valid.
6. Pengujian lintas pemilik melalui request backend/API dengan manipulasi ID, serta verifikasi data pemilik lain tetap utuh.
7. Pengukuran performa daftar dan filter menggunakan 100 data pada jaringan 4G dengan target maksimal 3 detik.
8. Pengukuran alur pencari untuk memastikan opsi kontak tercapai dalam maksimal 3 ketukan.
9. Pemeriksaan kesesuaian seluruh implementasi terhadap `docs/ARCHITECTURE.md` dan status task pada `docs/TASKS.md`.
10. Uji aplikasi pada perangkat/emulator Android sesuai Definition of Done dalam `AGENTS.md`.

## 5. Kesimpulan

Pemeriksaan awal menunjukkan analyzer dan 18 tes otomatis lulus. Konfigurasi Supabase pada `lib/main.dart`, empat policy RLS, status RLS aktif, struktur kolom, dan constraint database yang diperiksa menunjukkan kesesuaian awal dengan beberapa ketentuan PRD dan `AGENTS.md`.

Namun, audit Prompt 13 **belum dapat dinyatakan selesai sepenuhnya** karena skenario manual, pemeriksaan privasi respons publik, pengujian negatif backend, performa, dan pemeriksaan arsitektur masih perlu dilengkapi. Tidak ada perubahan kode atau database yang dilakukan selama pemeriksaan ini.

## 6. Status

**Status audit: Pemeriksaan awal selesai; verifikasi lanjutan masih diperlukan.**

Laporan ini hanya mencatat hasil yang telah terlihat atau dijalankan. Skenario yang belum diuji tidak ditandai lulus.
