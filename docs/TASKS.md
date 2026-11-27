
# Daftar Task Implementasi KosFinder (Vertical Slices)

Acuan: `docs/PRD.md`, `docs/ARCHITECTURE.md`, dan `AGENTS.md`. Setiap slice menghasilkan aplikasi yang dapat dijalankan dan diuji (`flutter analyze`, `flutter test`, serta run di device Android).

## Slice 1: Daftar dan Detail Kos

| ID | Tujuan | Story & AC | File yang Boleh Diubah | Cara Menguji | Status |
|---|---|---|---|---|---|
| T01 | Minta persetujuan pengguna terlebih dahulu sebelum memasang package (`provider`, `supabase_flutter`, `url_launcher`) ke `pubspec.yaml`; setup konfigurasi `--dart-define` Supabase di `main.dart` dan buat model `Kos`. | `US01-AC1`, `US03-AC1` | `pubspec.yaml`, `lib/main.dart`, `lib/models/kos.dart`, `test/widget_test.dart` | `flutter analyze && flutter test test/widget_test.dart` dan jalankan app shell dengan `--dart-define` di Android setelah package disetujui & terpasang. | DONE |
| T02 | Buat `KosRepository`, `KosProvider`, dan `KosListScreen` untuk memuat daftar kos publik tanpa login termasuk badge **Penuh** saat `jumlah_kamar == 0`, state kosong, dan error koneksi. | `US01` (`US01-AC1`, `US01-AC2`, `US01-AC3`) | `lib/repositories/kos_repository.dart`, `lib/providers/kos_provider.dart`, `lib/screens/kos_list_screen.dart`, `lib/main.dart`, `test/kos_list_screen_test.dart` | `flutter analyze && flutter test test/kos_list_screen_test.dart` serta uji buka daftar kos di device (normal, kamar `0` tampil **Penuh**, kosong, airplane mode). | DONE |
| T03 | Buat `KosDetailScreen` (info lengkap, status **Penuh** saat kamar `0`, tombol WhatsApp normalisasi `08`→`62`, alternatif salin/telepon, error offline) dan `AboutScreen` (`<NIM> - <NAMA>`). | `US03` (`US03-AC1`, `US03-AC2`, `US03-AC3`) | `lib/screens/kos_detail_screen.dart`, `lib/screens/about_screen.dart`, `lib/utils/contact_helper.dart`, `lib/screens/kos_list_screen.dart`, `lib/main.dart`, `test/kos_detail_test.dart` | `flutter analyze && flutter test test/kos_detail_test.dart` serta uji ketuk kos (termasuk status **Penuh**), buka WhatsApp/salin/telepon, dan buka About di Android. | TODO |

## Slice 2: Pencarian dan Filter

| ID | Tujuan | Story & AC | File yang Boleh Diubah | Cara Menguji | Status |
|---|---|---|---|---|---|
| T04 | Implementasi pencarian teks bebas yang mencocokkan `nama_kos`, `alamat_lengkap`, dan `area` pada daftar kos publik. | `US02` (`US02-AC1`, `US02-AC2`, `US02-AC3`) | `lib/repositories/kos_repository.dart`, `lib/providers/kos_provider.dart`, `lib/screens/kos_list_screen.dart`, `test/kos_search_test.dart` | `flutter analyze && flutter test test/kos_search_test.dart` serta uji cari kata kunci cocok, kosong, dan offline di Android. | TODO |
| T05 | Implementasi filter harga bulanan (min–maks), `jenis` (`putra`/`putri`/`campur`), dan 4 fasilitas opsional logika **AND**. | `US02` (`US02-AC1`, `US02-AC2`, `US02-AC3`) | `lib/repositories/kos_repository.dart`, `lib/providers/kos_provider.dart`, `lib/screens/kos_list_screen.dart`, `test/kos_filter_test.dart` | `flutter analyze && flutter test test/kos_filter_test.dart` serta uji kombinasi filter AND, hasil kosong, dan reset filter di Android. | TODO |

## Slice 3: Login Pemilik

| ID | Tujuan | Story & AC | File yang Boleh Diubah | Cara Menguji | Status |
|---|---|---|---|---|---|
| T06 | Implementasi `AuthRepository` dan `AuthProvider` untuk registrasi, login, dan logout pemilik via Supabase Auth (mengikuti konfigurasi konfirmasi email proyek bila aktif, tanpa mewajibkannya di luar PRD). | `US04` (`US04-AC1`, `US04-AC2`) | `lib/repositories/auth_repository.dart`, `lib/providers/auth_provider.dart`, `lib/main.dart`, `test/auth_provider_test.dart` | `flutter analyze && flutter test test/auth_provider_test.dart` dengan skenario sukses, input/kredensial salah, dan offline (serta konfirmasi email hanya bila aktif di proyek). | TODO |
| T07 | Buat `OwnerAuthScreen` dan hubungkan navigasi akun pemilik dari `KosListScreen` agar pemilik dapat login/mendaftar secara end-to-end. | `US04` (`US04-AC1`, `US04-AC2`) | `lib/screens/owner_auth_screen.dart`, `lib/screens/kos_list_screen.dart`, `lib/main.dart`, `test/owner_auth_screen_test.dart` | `flutter analyze && flutter test test/owner_auth_screen_test.dart` serta uji daftar, login, dan pesan error di perangkat Android. | TODO |

## Slice 4: Tambah, Ubah, dan Hapus Kos Milik Sendiri

| ID | Tujuan | Story & AC | File yang Boleh Diubah | Cara Menguji | Status |
|---|---|---|---|---|---|
| T08 | Buat `OwnerDashboardScreen` untuk menampilkan daftar kos milik pemilik yang login, state kosong, dan tombol logout. | `US04-AC1`, `US06-AC2` | `lib/repositories/kos_repository.dart`, `lib/providers/kos_provider.dart`, `lib/screens/owner_dashboard_screen.dart`, `lib/screens/owner_auth_screen.dart`, `lib/screens/kos_list_screen.dart`, `lib/main.dart`, `test/owner_dashboard_test.dart` | `flutter analyze && flutter test test/owner_dashboard_test.dart` serta uji login masuk dashboard, daftar kosong, dan logout di Android. | TODO |
| T09 | Buat `KosFormScreen` serta aksi tambah & ubah kos (kolom wajib, harga `> 0`, kamar `>= 0` dengan status **Penuh** saat `0`, kontak `08`/`+62`, 4 fasilitas opsional). | `US05` (`US05-AC1`, `US05-AC2`), `US06` (`US06-AC1`, `US06-AC3`) | `lib/repositories/kos_repository.dart`, `lib/providers/kos_provider.dart`, `lib/screens/kos_form_screen.dart`, `lib/screens/owner_dashboard_screen.dart`, `test/kos_form_test.dart` | `flutter analyze && flutter test test/kos_form_test.dart` serta uji tambah (tanpa & dengan fasilitas) dan edit kos (termasuk kamar `0`) di Android/Supabase. | TODO |
| T10 | Implementasi hapus permanen kos milik sendiri dengan dialog konfirmasi dan verifikasi penolakan akses lintas pemilik oleh RLS backend. | `US06` (`US06-AC1`, `US06-AC3`) | `lib/repositories/kos_repository.dart`, `lib/providers/kos_provider.dart`, `lib/screens/owner_dashboard_screen.dart`, `test/kos_crud_rls_test.dart` | `flutter analyze && flutter test test/kos_crud_rls_test.dart` serta uji integrasi langsung ke Supabase memakai **dua akun berbeda (Pemilik A dan Pemilik B)**—bukan hanya mock—untuk membuktikan `UPDATE`/`DELETE` lintas pemilik ditolak RLS. | TODO |

## Slice 5 (Bonus): Ketersediaan Kamar

| ID | Tujuan | Story & AC | File yang Boleh Diubah | Cara Menguji | Status |
|---|---|---|---|---|---|
| T11 | Tambah aksi cepat pembaruan jumlah kamar di `OwnerDashboardScreen` serta uji end-to-end sinkronisasi status `Tersedia`/badge **Penuh** (`0`) ke daftar & detail publik dalam `≤ 3 detik`. | `US01-AC1`, `US03-AC1`, `US06-AC1` | `lib/repositories/kos_repository.dart`, `lib/providers/kos_provider.dart`, `lib/screens/owner_dashboard_screen.dart`, `lib/screens/kos_list_screen.dart`, `lib/screens/kos_detail_screen.dart`, `test/room_availability_test.dart` | `flutter analyze && flutter test test/room_availability_test.dart` serta uji ubah kamar ke `0` dan kembali `> 0` dari dashboard hingga tampil di daftar & detail Android dalam `≤ 3 detik`. | TODO |
