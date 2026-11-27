# AGENTS.md — KosFinder

Panduan kerja agen pengembang untuk proyek **KosFinder**. Gunakan file ini bersama dokumen acuan proyek sebelum merencanakan atau mengubah kode.

## 1. Konteks Proyek

- **Deskripsi:** KosFinder adalah aplikasi pencarian dan pengelolaan kos berbasis **Flutter (Android)** dengan backend **Supabase** (Auth & PostgreSQL).
- **Dokumen Acuan:**
  - `docs/PRD.md` (kebutuhan produk, user stories `US01`–`US06`, acceptance criteria, NFR, dan batasan v1)
  - `docs/ARCHITECTURE.md` (arsitektur aplikasi dan skema database/RLS)
  - `docs/TASKS.md` (daftar dan rincian ID task implementasi)
- **Ringkasan Scope Versi 1 (`docs/PRD.md`):**
  - **Pengguna:** Pencari Kos (tanpa login, akses baca & kontak WhatsApp `08` -> `62` / alternatif salin & telepon) dan Pemilik Kos (registrasi/login email + password via Supabase Auth dengan konfirmasi email sesuai konfigurasi proyek; CRUD kos milik sendiri). Tidak ada peran admin.
  - **Aturan Data:** Kolom wajib (`nama kos`, `alamat lengkap`, `area`, `jenis`: `putra`/`putri`/`campur`, `harga bulanan > 0`, `jumlah kamar >= 0` dengan status **Penuh** saat `0`, `nomor kontak` format `08`/`+62`) dan `fasilitas` opsional (`AC`, `WiFi`, `kamar mandi dalam`, `parkir`; filter logika **AND**). Pencarian teks mencocokkan `nama kos`, `alamat lengkap`, dan `area`.
  - **Di Luar Scope v1:** Login pencari, bookmark/favorit, verifikasi identitas/moderasi admin, booking/pembayaran online, chat dalam aplikasi, ulasan/rating, rekomendasi AI, upload/URL foto, peta/GPS, serta mode offline/cache lokal.

## 2. Cara Kerja Agen

- Kerjakan **satu task dalam satu permintaan**.
- Jangan mengubah file di luar cakupan task yang diminta.
- Buat rencana terlebih dahulu sebelum melakukan perubahan besar.
- Selalu pilih solusi yang paling sederhana, langsung, dan mudah dirawat (hindari over-engineering dan penambahan fitur di luar PRD).
- Jangan menambahkan package/dependency baru ke `pubspec.yaml` tanpa persetujuan pengguna terlebih dahulu.

## 3. Teknologi

- **Frontend:** Flutter (target Android)
- **State Management:** Provider
- **Backend:** Supabase (Supabase Auth dan PostgreSQL dengan Row Level Security)

## 4. Keamanan

- Jangan menulis API key, secret, kredensial, atau password secara hardcoded di dalam kode sumber maupun repository. URL Supabase dan anon key harus dibaca melalui konfigurasi `--dart-define` sesuai dokumen arsitektur. Jangan pernah memasukkan secret atau service_role key ke aplikasi klien.
- Jangan pernah menggunakan Supabase `service_role` key di aplikasi klien Flutter.
- Hak akses wajib ditegakkan di backend menggunakan **Row Level Security (RLS)** dan constraint PostgreSQL (mis. `auth.uid() = owner_id` untuk `INSERT`/`UPDATE`/`DELETE`, serta validasi harga, jumlah kamar, dan format kontak), bukan sekadar menyembunyikan tombol di UI.
- Endpoint baca publik tidak boleh mengekspos data akun privat pemilik (email login, token, atau metadata autentikasi).

## 5. Git

- Terapkan aturan **satu task satu commit**.
- Pesan commit wajib mencantumkan **ID task** dari `docs/TASKS.md` (mis. `T01: Inisialisasi struktur proyek`).

## 6. Definition of Done

Suatu task implementasi dianggap selesai apabila seluruh poin berikut terpenuhi:
- `flutter analyze` bersih tanpa error maupun warning baru.
- `flutter test` lulus untuk seluruh pengujian yang relevan.
- Aplikasi berhasil dijalankan pada device/emulator Android yang tersedia.
- Laporkan secara jujur bagian mana saja yang belum diuji beserta alasannya.

## 7. Halaman About

- Halaman About wajib menampilkan identitas mahasiswa dengan format `<NIM> - <NAMA>`.
- Jangan mengarang atau menebak identitas; gunakan placeholder `<NIM> - <NAMA>` sampai data resmi diberikan oleh pengguna.
