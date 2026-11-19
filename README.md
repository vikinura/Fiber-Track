# Fiber Track

> **Platform Mobile Pelaporan dan Pemantauan Gangguan Jaringan Fiber Optic Berbasis Multi-Tenant dan Multi-Vendor**

Fiber Track adalah aplikasi mobile yang dirancang untuk penyelenggara jaringan fiber optik (*tenant*) dan mitra perbaikan teknis (*vendor*) guna mempercepat alur penanganan tiket insiden gangguan jaringan, memonitor kepatuhan SLA (*Service Level Agreement*), mengelola bukti perbaikan berbasis foto, dan menganalisis performa operasional lapangan melalui dashboard analitik interaktif.

Dibangun dengan arsitektur **Clean Architecture (Flutter)** di sisi mobile dan **Layered Architecture (Node.js Express + MySQL)** di sisi backend REST API.

---

## 1. Fitur Utama

- **Multi-Tenancy & Multi-Vendor Terisolasi:** Pemisahan ketat data tiket, pelanggan, dan area antar-tenant. Kemitraan vendor fleksibel (satu vendor dapat melayani multi-tenant).
- **Manajemen Siklus Hidup Tiket:** Alur status standar industri: `new` $\to$ `forwarded` $\to$ `assigned` $\to$ `in_progress` $\to$ `resolved`.
- **Perhitungan SLA Otomatis & Visual:** Batas waktu resolusi otomatis berdasarkan prioritas (`Kritis`, `Tinggi`, `Sedang`, `Rendah`), dilengkapi indikator `SlaBadge` (`on_track`, `at_risk`, `overdue`, `met`, `breached`) beserta hitung mundur waktu sisa.
- **Bukti Foto Lapangan:** Unggah foto bukti sebelum/sesudah perbaikan (maksimal 10 foto per tiket) dengan kompresi, verifikasi hak akses, dan galeri interaktif.
- **Pemberitahuan Dalam Aplikasi:** Polling otomatis 30 detik untuk notifikasi alur kerja (penugasan tiket, delegasi teknisi, tiket diselesaikan) dengan badge jumlah pesan belum dibaca.
- **Dashboard Analitik Eksekutif:** Visualisasi metrik total tiket, tiket aktif, overdue, persentase kepatuhan SLA, rata-rata jam penyelesaian, grafik batang per area jaringan (`fl_chart`), dan kartu performa kinerja mitra vendor.
- **Kelola Data Master (CRUD):** Manajemen data area jaringan, pelanggan, ODP, jenis gangguan, dan prioritas dengan proteksi integritas data relasional (409 Conflict).
- **Tema Fleksibel (Material 3):** Dukungan penuh Tema Terang (*Light Mode*), Tema Gelap (*Dark Mode*), dan Mengikuti Sistem.

---

## 2. Arsitektur Sistem

### A. Mobile (Flutter Clean Architecture)
Mengikuti prinsip pemisahan lapisan independen:
- **Presentation Layer:** Halaman (Pages/Views), Widget, dan State Management berbasis **BLoC/Cubit** (`flutter_bloc`).
- **Domain Layer:** Pure Dart tanpa dependensi framework UI atau HTTP. Berisi Entities, Use Cases, dan Repository Interfaces dengan error handling fungsional **fpdart** (`Either<Failure, T>`).
- **Data Layer:** Models (konversi JSON), Data Sources (`DioClient` dengan interceptor autentikasi dan auto-logout 401), dan Repository Implementations.
- **Dependency Injection:** Dikelola menggunakan Service Locator `get_it`.

### B. Backend (Layered Architecture)
Pemisahan satu arah: **Routes $\to$ Controller $\to$ Service $\to$ Repository $\to$ Database (MySQL)**.
- **Otorisasi Multi-Tenant:** Identitas `tenant_id`, `vendor_id`, dan `role` **hanya** diambil dari token JWT yang terverifikasi secara kriptografis (mencegah parameter spoofing).
- **Integritas Transaksi:** Operasi multi-tabel (update status tiket + riwayat audit + pembuatan notifikasi) dibungkus transaksi database ACID.
- **Keamanan:** Dilengkapi `helmet`, CORS terkonfigurasi, rate limiter untuk proteksi brute force login, dan validasi skema runtime `zod`.

---

## 3. Akun Pengguna Demo

Semua akun demo di bawah ini menggunakan kata sandi bawaan: **`Password123!`**

| Peran (*Role*) | Email Demo | Lingkup Akses / Entitas |
|:---|:---|:---|
| **Super Admin** | `superadmin@fibertrack.id` | Manajemen platform backend |
| **Tenant Admin Alpha** | `admin.nusa@fibertrack.id` | Penyelenggara Jaringan (Tenant Alpha) |
| **Tenant Admin Beta** | `admin.telco@fibertrack.id` | Penyelenggara Jaringan (Tenant Beta) |
| **Vendor Admin 1** | `admin@mitraoptik.com` | Mitra Kontraktor (Vendor Satu) |
| **Vendor Admin 2** | `admin@solusifiber.com` | Mitra Kontraktor (Vendor Dua) |
| **Teknisi 1 (Vendor 1)** | `budi@mitraoptik.com` | Personel Lapangan (Vendor Satu) |
| **Teknisi 2 (Vendor 1)** | `iwan@mitraoptik.com` | Personel Lapangan (Vendor Satu) |
| **Teknisi 3 (Vendor 2)** | `eko@solusifiber.com` | Personel Lapangan (Vendor Dua) |

---

## 4. Panduan Menjalankan Sistem

### Prasyarat:
- Node.js versi 20+ dan npm
- MySQL Server (versi 8.0+)
- Flutter SDK (versi stable 3.13+) dan Android Studio / Emulator

---

### Langkah A: Menjalankan Backend API

1. Masuk ke folder backend dan pasang dependensi:
   ```bash
   cd backend
   npm install
   ```

2. Konfigurasi file environment `.env`:
   Salin `.env.example` menjadi `.env` dan sesuaikan kredensial MySQL:
   ```env
   PORT=3000
   DB_HOST=localhost
   DB_PORT=3306
   DB_USER=root
   DB_PASSWORD=
   DB_NAME=fibertrack
   JWT_SECRET=super-secret-jwt-key-fibertrack-2026
   JWT_EXPIRES_IN=1d
   UPLOAD_DIR=uploads
   MAX_UPLOAD_MB=5
   ```

3. Jalankan migrasi tabel dan data awal (seeding):
   ```bash
   npm run migrate
   npm run seed
   ```

4. Jalankan server backend (mode pengembangan):
   ```bash
   npm run dev
   ```
   *Server akan berjalan di `http://localhost:3000` (atau `http://10.0.2.2:3000` untuk emulator Android).*

---

### Langkah B: Menjalankan Aplikasi Mobile Flutter

1. Masuk ke folder mobile dan unduh paket Flutter:
   ```bash
   cd mobile
   flutter pub get
   ```

2. Jalankan pemeriksaan kode:
   ```bash
   dart format .
   flutter analyze
   flutter test
   ```

3. Jalankan aplikasi pada emulator atau perangkat Android:
   ```bash
   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
   ```
   *(Untuk pengujian di perangkat fisik asli melalui Wi-Fi, ganti `10.0.2.2` dengan IP lokal laptop Anda, misal: `http://192.168.1.100:3000/api/v1`).*

---

## 5. Ringkasan Endpoint REST API

| Modul | Method | Endpoint | Peran Akses | Deskripsi |
|:---|:---:|:---|:---|:---|
| **Auth** | `POST` | `/api/v1/auth/login` | Publik | Masuk akun dan menerima token JWT |
| | `GET` | `/api/v1/auth/me` | Autentikasi | Mendapatkan profil akun saat ini |
| **Tiket** | `GET` | `/api/v1/tickets` | Semua peran | Daftar tiket (difilter per peran & paginasi) |
| | `POST` | `/api/v1/tickets` | `tenant_admin` | Membuat tiket gangguan baru |
| | `GET` | `/api/v1/tickets/:id` | Hak pemilik | Detail tiket & riwayat |
| | `PATCH` | `/api/v1/tickets/:id/forward` | `tenant_admin` | Meneruskan tiket ke mitra vendor |
| | `PATCH` | `/api/v1/tickets/:id/assign` | `vendor_admin` | Menugaskan teknisi pelaksana |
| | `PATCH` | `/api/v1/tickets/:id/status` | `technician` | Memperbarui status (`in_progress`, `resolved`) |
| **Foto** | `POST` | `/api/v1/tickets/:id/photos` | `technician`/`vendor_admin` | Unggah foto bukti (maks 5MB, format JPG/PNG) |
| | `GET` | `/api/v1/tickets/photos/:photoId` | Hak pemilik | Mengakses file foto bukti |
| **Dashboard** | `GET` | `/api/v1/dashboard/summary` | `tenant_admin` | Ringkasan metrik total, SLA %, & rata-rata jam |
| | `GET` | `/api/v1/dashboard/by-area` | `tenant_admin` | Rekap sebaran tiket per area |
| | `GET` | `/api/v1/dashboard/by-vendor` | `tenant_admin` | Rekap kinerja performa mitra vendor |
| **Notifikasi**| `GET` | `/api/v1/notifications` | Autentikasi | Mengambil daftar notifikasi pengguna |
| | `PATCH` | `/api/v1/notifications/:id/read` | Autentikasi | Menandai notifikasi telah dibaca |
| **Master** | `GET/POST` | `/api/v1/areas` | `tenant_admin` | Kelola data area jaringan |
| | `GET/POST` | `/api/v1/customers` | `tenant_admin` | Kelola data pelanggan |
| | `GET/POST` | `/api/v1/odps` | `tenant_admin` | Kelola titik ODP |
| | `GET/POST` | `/api/v1/issue-types` | `tenant_admin` | Kelola jenis gangguan |
| | `GET/POST` | `/api/v1/priorities` | `tenant_admin` | Kelola prioritas dan durasi target SLA |

---

## 6. Dokumentasi Pengujian

Dokumentasi detail pengujian tercatat pada folder `docs/`:
- **`docs/pengujian.md`**: Rekapitulasi hasil pengujian Black Box (21 skenario), pengujian 9 kasus isolasi hak akses multi-tenant, serta verifikasi matematis angka agregasi dashboard.
- **`docs/postman/`**: Koleksi Postman lengkap beserta environment untuk pengujian otomatis API.
- **`docs/screenshots/`**: Panduan tangkapan layar fitur antarmuka mobile.
- **`docs/erd-fibertrack.dbml`**: Skema relasi database (ERD).
