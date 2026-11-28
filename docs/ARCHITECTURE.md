
# Arsitektur Aplikasi: KosFinder (Versi 1)

Dokumen ini mengacu pada `docs/PRD.md` dan `AGENTS.md` dengan pendekatan paling sederhana untuk Flutter (Android) dan Supabase.

## 1. Pola & Komponen Aplikasi (`Screen – Provider – Repository – Supabase`)

Aliran data bersifat satu arah: **Screen** merender UI dan meneruskan aksi pengguna ke **Provider**, **Provider** mengelola state (`loading`, data, error koneksi/validasi) dan memanggil **Repository**, **Repository** melakukan query/mutasi ke **SupabaseClient** (`Auth` & `PostgreSQL`), lalu hasil dikembalikan ke **Provider** untuk memperbarui **Screen**.

| Lapisan | Komponen | Tugas Utama | User Story |
|---|---|---|---|
| **Screen** | `KosListScreen` | Daftar kos publik tanpa login, pencarian teks (`nama_kos`, `alamat_lengkap`, `area`), filter harga min–maks, jenis, & fasilitas (**AND**), badge **Penuh** (`kamar == 0`), state kosong/offline. | `US01`, `US02` |
| **Screen** | `KosDetailScreen` | Detail lengkap kos (termasuk placeholder bawaan bila perlu), tombol buka WhatsApp (normalisasi `08` → `62`), alternatif salin nomor & telepon, penanganan offline. | `US03` |
| **Screen** | `OwnerAuthScreen` | Form registrasi & login email + password pemilik (termasuk info konfirmasi email bila aktif di Supabase). | `US04` |
| **Screen** | `OwnerDashboardScreen` | Daftar kos milik pemilik yang login, akses tambah/edit, dialog konfirmasi hapus permanen, dan logout. | `US05`, `US06` |
| **Screen** | `KosFormScreen` | Form tambah & ubah kos (validasi kolom wajib, harga `> 0`, kamar `>= 0`, kontak `08`/`+62`, 4 fasilitas opsional). | `US05`, `US06` |
| **Screen** | `AboutScreen` | Menampilkan informasi aplikasi dan identitas `<NIM> - <NAMA>` (aturan `AGENTS.md`). | — |
| **Provider** | `KosProvider` | Menyimpan state daftar publik, filter aktif, daftar kos pemilik, status loading/error jaringan/RLS, dan memanggil `KosRepository`. | `US01`, `US02`, `US03`, `US05`, `US06` |
| **Provider** | `AuthProvider` | Mengelola state sesi pemilik (`currentUser`, loading, error auth) dan memanggil `AuthRepository`. | `US04`, `US05`, `US06` |
| **Repository** | `KosRepository` | Abstraksi query publik (list, search `ilike`, filter `gte`/`lte`, `eq`, `contains` array fasilitas), detail by ID, serta `insert`/`update`/`delete` ke tabel `kos`. | `US01`, `US02`, `US03`, `US05`, `US06` |
| **Repository** | `AuthRepository` | Pembungkus `supabase.auth` (`signUp`, `signInWithPassword`, `signOut`, stream status sesi). | `US04` |
| **Supabase** | `Supabase.instance.client` | Klien backend tunggal untuk autentikasi (`Supabase Auth`) dan akses tabel `public.kos` (`PostgREST` + `RLS`). | `US01`–`US06` |

## 2. Daftar Layar dan Alur Navigasi

1. **Pencari Kos (Tanpa Login):**
   - `KosListScreen` (layar awal) → ketuk kartu kos → `KosDetailScreen` → ketuk **Chat WhatsApp** (buka `wa.me/62...`) atau alternatif **Salin Nomor** / **Telepon**.
2. **Pemilik Kos:**
   - `KosListScreen` (ikon **Kelola Kos**) → jika belum login masuk `OwnerAuthScreen` → login berhasil masuk `OwnerDashboardScreen`.
   - `OwnerDashboardScreen` → tombol **Tambah** / **Edit** → `KosFormScreen` → simpan → kembali ke `OwnerDashboardScreen` (daftar diperbarui).
   - `OwnerDashboardScreen` → tombol **Hapus** → dialog konfirmasi → hapus permanen.
3. **Tentang Aplikasi:**
   - `KosListScreen` (ikon **About**) → `AboutScreen`.

## 3. Rencana Database & Aturan Akses (`supabase/migrations/001_init.sql`)

Hanya menggunakan satu tabel `public.kos` agar sederhana dan sesuai scope v1:

| Kolom | Tipe Data | Keterangan & Constraint |
|---|---|---|
| `id` | `uuid` (PK) | `default gen_random_uuid()` |
| `owner_id` | `uuid` (FK) | `not null default auth.uid()`, relasi ke `auth.users(id) on delete cascade` |
| `nama_kos` | `text` | `not null`, wajib tidak kosong |
| `alamat_lengkap` | `text` | `not null`, wajib tidak kosong |
| `area` | `text` | `not null`, wajib tidak kosong |
| `jenis` | `text` | `not null`, `check (jenis in ('putra', 'putri', 'campur'))` |
| `harga_bulanan` | `bigint` | `not null`, tipe angka bulat, `check (harga_bulanan > 0)` |
| `jumlah_kamar` | `integer` | `not null`, `check (jumlah_kamar >= 0)` (`0` = **Penuh**) |
| `fasilitas` | `text[]` | `not null default '{}'`, opsional (boleh kosong), subset dari `{'AC', 'WiFi', 'kamar mandi dalam', 'parkir'}` |
| `nomor_kontak` | `text` | `not null`, `check (nomor_kontak ~ '^(\+62\|08)[0-9]+$')` |
| `created_at` | `timestamptz` | `not null default now()` |
| `updated_at` | `timestamptz` | `not null default now()` |

**Aturan Akses (Row Level Security):**
- **Melihat (`SELECT`):** Semua pengguna (`anon` & `authenticated`) boleh membaca seluruh baris `public.kos`. Tidak ada kolom kredensial/email pemilik di tabel ini sehingga privasi akun terjaga.
- **Menambah (`INSERT`):** Hanya pengguna terautentikasi (`authenticated`) dengan syarat `auth.uid() = owner_id`.
- **Mengubah (`UPDATE`) & Menghapus (`DELETE`):** Hanya pemilik sah (`authenticated` dengan `auth.uid() = owner_id`). Permintaan lintas pemilik ditolak langsung oleh PostgreSQL/RLS.

## 4. Konfigurasi Supabase (`--dart-define`)

URL dan anon key **tidak** ditulis di kode maupun repository. Keduanya disuntikkan saat run/build dan dibaca di `lib/main.dart`:
- `const supabaseUrl = String.fromEnvironment('SUPABASE_URL');`
- `const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');`
- Contoh jalankan lokal:
  `flutter run --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co --dart-define=SUPABASE_ANON_KEY=<anon-key>`
- `service_role` key tidak pernah dimasukkan ke aplikasi klien.

## 5. Cara Rilis (Build APK & GitHub Release)

1. Pastikan `flutter analyze` bersih dan `flutter test` lulus.
2. Build APK release dengan konfigurasi `--dart-define`:
   `flutter build apk --release --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<anon-key>`
3. Uji berkas `build/app/outputs/flutter-apk/app-release.apk` pada perangkat Android.
4. Buat tag versi (mis. `v1.0.0`) lalu buat **GitHub Release** di repositori dengan melampirkan `app-release.apk` dan catatan rilis (tanpa melampirkan kredensial/file `.env`).

## 6. Package yang Dibutuhkan

| Package | Alasan Penggunaan | User Story |
|---|---|---|
| `provider` | State management (`ChangeNotifierProvider`) sesuai `AGENTS.md` untuk memisahkan state UI dari repository. | `US01`–`US06` |
| `supabase_flutter` | Klien resmi Flutter untuk Supabase Auth (daftar/login pemilik) dan query/filter/CRUD PostgreSQL dengan sesi JWT untuk RLS. | `US01`–`US06` |
| `url_launcher` | Membuka WhatsApp (`https://wa.me/62...`) dan dialer telepon (`tel:...`) sebagai alternatif saat WhatsApp tidak tersedia. | `US03` |

*Catatan: Salin nomor menggunakan `Clipboard` bawaan Flutter (`flutter/services.dart`) dan ikon menggunakan Material Icons bawaan sehingga tidak perlu package tambahan lain.*

## 7. Keputusan Teknis (ADR Mini)

### K1: Otorisasi menggunakan Row Level Security (RLS) Supabase
**Alasan:** Hak akses data harus ditegakkan langsung pada backend agar pemilik hanya dapat mengelola kos miliknya sendiri.

**Konsekuensi:** Operasi tambah, ubah, dan hapus harus mengikuti policy RLS, serta pengujian akses dilakukan menggunakan dua akun pemilik berbeda.

### K2: Arsitektur menggunakan pola Screen – Provider – Repository
**Alasan:** Pemisahan tanggung jawab membuat tampilan, pengelolaan state, dan akses database lebih terstruktur.

**Konsekuensi:** Screen berkomunikasi melalui Provider, sedangkan operasi database dilakukan melalui Repository.

### K3: Provider digunakan untuk pengelolaan state
**Alasan:** Provider dipilih sebagai state management agar perubahan data dan status aplikasi dapat dikelola secara terpusat.

**Konsekuensi:** Pengelolaan state menggunakan ChangeNotifier dan Provider tanpa menambahkan framework state management lain.

### K4: Supabase digunakan sebagai backend utama
**Alasan:** Supabase menyediakan autentikasi dan database PostgreSQL dalam satu layanan sehingga sesuai dengan kebutuhan KosFinder versi pertama.

**Konsekuensi:** Data kos disimpan pada tabel `public.kos`, sedangkan autentikasi pemilik menggunakan Supabase Auth.

### K5: Konfigurasi Supabase menggunakan --dart-define
**Alasan:** URL dan anon key tidak boleh ditulis langsung di dalam kode sumber atau repository.

**Konsekuensi:** Nilai konfigurasi diberikan ketika menjalankan atau membangun aplikasi, sedangkan `service_role` key tidak boleh digunakan pada aplikasi klien.

### K6: Integrasi WhatsApp dan telepon menggunakan url_launcher
**Alasan:** Aplikasi dapat mengarahkan pengguna ke layanan WhatsApp dan telepon tanpa perlu membangun sistem komunikasi sendiri.

**Konsekuensi:** WhatsApp menggunakan tautan `wa.me` dan telepon menggunakan skema `tel:`, sedangkan fungsi salin nomor menggunakan Clipboard bawaan Flutter.
