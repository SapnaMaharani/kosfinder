# PRD: KosFinder (Versi 1)

**Platform:** Flutter (Android) | **Backend:** Supabase (Auth & PostgreSQL + RLS)

## 1. Masalah dan Tujuan Terukur

**Masalah:** Info kos tersebar di medsos/WhatsApp/lisan; pencari sulit membandingkan harga, lokasi, dan fasilitas; pemilik kesulitan memperbarui ketersediaan kamar.

**Tujuan Terukur:**
- **T1:** 100% data kos mengikuti skema seragam (`nama kos`, `alamat lengkap`, `area`, jenis, harga bulanan, jumlah kamar, fasilitas opsional, kontak).
- **T2:** Pencari menemukan detail dan kontak pemilik dalam `≤ 3` ketukan tanpa login.
- **T3:** Pembaruan kamar (termasuk status **Penuh**) tampil ke publik dalam `≤ 3 detik` setelah disimpan.
- **T4:** 0% aksi ubah/hapus kos milik orang lain berhasil di backend (proteksi RLS 100%).

## 2. Pengguna dan Scope Versi 1

**Pengguna:**
- **Pencari Kos:** Tanpa login; akses baca (daftar, cari, filter, detail, hubungi pemilik).
- **Pemilik Kos:** Daftar & login email + password via Supabase Auth (pakai konfirmasi email jika aktif di proyek); kelola kos sendiri. Tanpa peran admin.

**Masuk Scope:**
- Daftar kos publik (teks, ikon fasilitas, badge **Tersedia** / **Penuh** saat kamar `0`, placeholder bawaan bila perlu).
- Pencarian teks (`nama kos`, `alamat lengkap`, `area`) dan filter harga bulanan (min–maks), jenis (`putra`/`putri`/`campur`), serta fasilitas baku (`AC`, `WiFi`, `kamar mandi dalam`, `parkir`) dengan logika **AND**.
- Detail kos + tombol buka WhatsApp langsung (`08` dinormalisasi ke `62`), serta alternatif salin nomor atau panggilan telepon jika WhatsApp tidak tersedia.
- Tambah, ubah, dan hapus permanen kos milik sendiri (tanpa batas jumlah kos; langsung tayang; kolom wajib diisi kecuali fasilitas yang opsional; harga `> 0`, kamar `>= 0`, kontak `08`/`+62`).
- Penanganan gagal koneksi tanpa crash.

**Tidak Masuk Scope:** Login pencari, bookmark/favorit, admin/verifikasi identitas/moderasi, pemesanan atau pembayaran online (termasuk kos penuh), chat dalam aplikasi, ulasan/rating, AI, upload/URL foto, peta/GPS, mode offline/cache.

## 3. Non-Functional Requirements (NFR)

1. **Keamanan:** RLS `auth.uid() = owner_id` (`INSERT`/`UPDATE`/`DELETE`) dan constraint DB (`NOT NULL` kolom wajib, fasilitas opsional, `harga > 0`, `kamar >= 0`, kontak `08`/`+62`). *Uji:* Request API `UPDATE`/`DELETE` lintas pemilik ditolak (0 baris terdampak); `harga <= 0` ditolak DB.
2. **Keandalan:** Tidak crash saat internet mati, data kosong, atau WhatsApp tidak tersedia. *Uji:* Uji seluruh layar dalam mode airplane dan perangkat tanpa WhatsApp.
3. **Kemudahan Pakai:** Filter langsung tanpa login, badge **Penuh** jelas saat kamar `0`, opsi kontak langsung, pesan error spesifik per kolom. *Uji:* Pengguna baru mencapai opsi kontak dalam `≤ 3` ketukan.
4. **Performa:** Muat daftar dan filter (100 data uji) `≤ 3 detik` di jaringan 4G. *Uji:* Ukur waktu query hingga render di Android.
5. **Privasi:** Endpoint baca publik hanya mengirim data listing dan kontak yang dipublikasikan, tanpa email akun/token pemilik. *Uji:* Inspeksi JSON `GET` publik.

## 4. User Stories

- **US01:** Sebagai pencari kos, saya ingin melihat daftar kos dan status ketersediaannya tanpa login, agar dapat membandingkan pilihan dengan cepat.
- **US02:** Sebagai pencari kos, saya ingin mencari berdasarkan nama kos, alamat lengkap, atau area serta menyaring harga min–maks, jenis, dan fasilitas (logika AND), agar menemukan kos yang sesuai.
- **US03:** Sebagai pencari kos, saya ingin melihat detail kos dan menghubungi pemilik lewat WhatsApp atau alternatif salin/telepon, agar dapat berkomunikasi langsung.
- **US04:** Sebagai pemilik kos, saya ingin mendaftar dan login dengan email dan password, agar dapat mengelola kos saya.
- **US05:** Sebagai pemilik kos, saya ingin menambah kos baru (dengan fasilitas opsional) yang langsung tayang, agar calon penyewa segera melihatnya.
- **US06:** Sebagai pemilik kos, saya ingin mengubah dan menghapus permanen kos milik sendiri, agar info selalu akurat.

## 5. Acceptance Criteria (AC)

**US01 – Daftar Kos**
- **US01-AC1:** *Given* data kos tersedia (termasuk kamar `0`), *When* pencari membuka daftar tanpa login, *Then* tampil nama kos, area, jenis, harga/bulan, ikon fasilitas, placeholder bawaan bila perlu, dan badge **Penuh** saat kamar `0`.
- **US01-AC2 (Data kosong):** *Given* belum ada kos, *When* daftar dibuka, *Then* tampil state kosong informatif tanpa error.
- **US01-AC3 (Koneksi gagal):** *Given* internet mati, *When* daftar dimuat, *Then* tampil pesan gagal memuat tanpa crash.

**US02 – Cari & Filter Kos**
- **US02-AC1:** *Given* data kos ada, *When* pencari mengisi kata kunci dan/atau filter harga min–maks, jenis, dan fasilitas baku, *Then* hanya tampil kos yang cocok pada `nama kos`/`alamat lengkap`/`area`, sesuai rentang harga, dan memiliki **semua** fasilitas terpilih (**AND**).
- **US02-AC2 (Data kosong):** *Given* tidak ada kos yang cocok, *When* filter dijalankan, *Then* tampil pesan tidak ada hasil.
- **US02-AC3 (Koneksi gagal):** *Given* internet mati saat mencari/memfilter, *When* permintaan dikirim, *Then* tampil pesan gagal memuat tanpa crash.

**US03 – Detail Kos & Kontak**
- **US03-AC1:** *Given* kos dipilih, *When* detail terbuka, *Then* tampil nama kos, alamat lengkap, area, jenis, harga bulanan, jumlah kamar/status ketersediaan, fasilitas (jika ada), nomor kontak, dan tombol buka WhatsApp (`08` otomatis jadi `62`), tanpa chat, foto upload/URL, atau booking online.
- **US03-AC2:** *Given* WhatsApp tidak tersedia, *When* tombol WhatsApp ditekan, *Then* tampil alternatif salin nomor atau panggilan telepon tanpa crash.
- **US03-AC3 (Koneksi gagal):** *Given* internet mati saat membuka detail, *When* kos diketuk, *Then* tampil pesan gagal memuat tanpa crash.

**US04 – Registrasi & Login Pemilik**
- **US04-AC1:** *Given* pemilik di form auth, *When* mengirim email dan password valid, *Then* jika konfirmasi email proyek aktif, pemilik diminta konfirmasi email dahulu; jika tidak aktif/sudah terkonfirmasi, sesi aktif dan masuk ke halaman kelola kos.
- **US04-AC2:** *Given* input kosong/invalid, kredensial salah, email belum terkonfirmasi, atau internet mati, *When* submit, *Then* ditolak dengan pesan error jelas tanpa crash.

**US05 – Tambah Kos**
- **US05-AC1:** *Given* pemilik login, *When* mengisi kolom wajib (`nama kos`, `alamat lengkap`, `area`, `jenis`, `harga > 0`, `kamar >= 0`, kontak `08`/`+62`) dengan 0 atau lebih fasilitas baku (opsional) lalu simpan, *Then* backend menyimpan `owner_id = auth.uid()` dan kos langsung tayang.
- **US05-AC2:** *Given* kolom wajib kosong, `harga <= 0`, `kamar < 0`, kontak bukan `08`/`+62`, atau request tanpa token valid, *When* dikirim, *Then* UI dan constraint/RLS backend menolak penyimpanan.

**US06 – Ubah & Hapus Kos Sendiri**
- **US06-AC1:** *Given* pemilik login dan memilih kos miliknya, *When* mengubah data (mis. kamar `0` atau kosongkan fasilitas) atau menghapus, *Then* data terbarui (badge **Penuh**) atau terhapus permanen dari DB.
- **US06-AC2 (Data kosong):** *Given* pemilik belum punya kos, *When* membuka daftar kosnya, *Then* tampil state kosong.
- **US06-AC3 (Akses pemilik lain):** *Given* Pemilik A mencoba mengubah/menghapus kos Pemilik B (termasuk manipulasi ID API), *When* dikirim ke Supabase, *Then* RLS backend menolak operasi sehingga data milik Pemilik B tetap utuh dan tidak berubah, serta aplikasi menampilkan pesan akses ditolak.
