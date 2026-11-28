# KosFinder

KosFinder adalah aplikasi mobile berbasis Flutter untuk membantu pengguna menemukan informasi tempat kos dan membantu pemilik kos mengelola data kos secara mandiri. Aplikasi menggunakan Supabase sebagai backend untuk autentikasi dan penyimpanan data.

## Fitur Utama

### Pengguna
- Melihat daftar tempat kos.
- Mencari kos berdasarkan nama, alamat, atau area.
- Memfilter kos berdasarkan harga, jenis, dan fasilitas.
- Melihat detail informasi kos.
- Menghubungi pemilik kos.

### Pemilik Kos
- Registrasi dan login akun.
- Menambahkan data kos.
- Mengubah informasi kos.
- Menghapus data kos.
- Mengelola jumlah kamar.
- Melihat status kos tersedia atau penuh.
- Melihat dashboard statistik total kos, kos tersedia, dan kos penuh.

### Keamanan
- Menggunakan Supabase Authentication.
- Menggunakan Row Level Security (RLS) untuk membatasi akses data.
- Pemilik hanya dapat mengelola data kos miliknya sendiri.

## Teknologi

- Flutter dan Dart
- Supabase Authentication
- Supabase PostgreSQL
- Supabase Row Level Security (RLS)
- Provider untuk state management

## Persyaratan

- Flutter SDK sesuai kompatibilitas proyek.
- Dart SDK.
- Android Studio atau Visual Studio Code.
- Akun dan proyek Supabase yang aktif.
- Perangkat Android atau emulator.

## Cara Menjalankan Aplikasi

1. Clone repository:

   ```bash
   git clone https://github.com/SapnaMaharani/kosfinder.git
   ```

2. Masuk ke folder proyek:

   ```bash
   cd kosfinder
   ```

3. Instal dependensi:

   ```bash
   flutter pub get
   ```

4. Siapkan konfigurasi Supabase dari Supabase Dashboard:
   - Project URL
   - Publishable key (atau anon key lama yang masih didukung)

5. Jalankan aplikasi:

   ```bash
   flutter run --dart-define=SUPABASE_URL=URL_SUPABASE \
   --dart-define=SUPABASE_ANON_KEY=SUPABASE_PUBLISHABLE_KEY
   ```

Ganti nilai konfigurasi dengan milik proyek Supabase yang digunakan.

## Build APK Release

Untuk membuat APK release:

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=URL_SUPABASE \
  --dart-define=SUPABASE_ANON_KEY=SUPABASE_PUBLISHABLE_KEY
```

File APK dihasilkan pada:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Pengujian

Jalankan analisis kode:

```bash
flutter analyze
```

Jalankan pengujian otomatis:

```bash
flutter test
```

## Batasan Versi 0.1.0

- Aplikasi berfokus pada pencarian dan pengelolaan informasi tempat kos.
- Pengelolaan data dilakukan oleh pemilik yang telah login.
- Aplikasi belum menyediakan sistem pembayaran kos secara langsung.
- Aplikasi belum menyediakan pemesanan dan transaksi kos secara langsung.
- Ketersediaan kos bergantung pada informasi yang diperbarui oleh pemilik.

## Versi

**KosFinder v0.1.0**

Repository: https://github.com/SapnaMaharani/kosfinder
