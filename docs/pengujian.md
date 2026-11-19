# Pengujian Sistem Fiber Track

Dokumen ini mencatat hasil pengujian otomatis dan pengujian isolasi hak akses / multi-tenancy sesuai ketentuan `CONTEXT.md` Bagian 18.

---

## Hasil Uji Isolasi Hak Akses & Multi-Tenant (Fase 4 - Task T44)

Tanggal pengujian: 2026-11-13  
Target branch: `feature/ticket-core`  
Lingkungan pengujian: Localhost REST API (Node.js Express + MySQL)

| No | Kasus Uji | Skenario | Expected | Actual | Status |
|:---|:---|:---|:---:|:---:|:---:|
| 1 | Isolasi Tiket Lintas Tenant | Admin Tenant Beta membaca tiket milik Tenant Alpha (`/api/v1/tickets/2`) | 404 Not Found | 404 Not Found | **Lolos (PASS)** |
| 3 | Isolasi Tiket Antar Vendor | Admin Vendor 1 / Vendor 2 membaca tiket yang belum diteruskan / milik vendor lain | 404 Not Found | 404 Not Found | **Lolos (PASS)** |
| 5 | Isolasi Tiket Antar Teknisi | Teknisi membaca tiket yang bukan penugasan dirinya | 404 Not Found | 404 Not Found | **Lolos (PASS)** |
| 8 | Autentikasi Tanpa/Token Rusak | Request endpoint berautentikasi tanpa token atau menggunakan bearer token cacat | 401 Unauthorized | 401 Unauthorized | **Lolos (PASS)** |
| 9 | Pencegahan Spoofing `tenant_id` | Request POST `/tickets` menyisipkan `tenant_id: 999` di body | 201 Created (disimpan dengan `tenant_id` milik JWT yaitu 1) | 201 Created (`tenant_id: 1`) | **Lolos (PASS)** |

---

## Kesimpulan Pengujian Fase 4
1. **Multi-tenancy:** Data tiket sepenuhnya terisolasi pada level query (`WHERE t.tenant_id = ?`), sehingga pengguna tenant lain menerima respons `404` tanpa membocorkan eksistensi data.
2. **Role-based Scope:** Hak akses berjenjang (`tenant_admin` melihat seluruh tiket tenant, `vendor_admin` hanya melihat tiket yang diteruskan ke vendornya, `technician` hanya melihat tiket miliknya) terverifikasi berjalan sesuai spesifikasi.
3. **Parameter Tampering:** Input `tenant_id` pada payload request body sepenuhnya diabaikan dan backend secara konsisten mengambil identitas dari JWT yang terverifikasi.

---

## Hasil Uji Isolasi Hak Akses & Workflow Penugasan (Fase 5 - Task T57)

Tanggal pengujian: 2026-11-13  
Target branch: `feature/ticket-workflow`  
Lingkungan pengujian: Localhost REST API (Node.js Express + MySQL)

| No | Kasus Uji | Skenario | Expected | Actual | Status |
|:---|:---|:---|:---:|:---:|:---:|
| 2 | Relasi Kemitraan Tenant-Vendor | Admin tenant meneruskan tiket ke vendor tanpa relasi kemitraan aktif | 422 Unprocessable Entity | 422 Unprocessable Entity | **Lolos (PASS)** |
| 4 | Penugasan Teknisi Lintas Vendor | Admin vendor X mencoba menugaskan teknisi milik vendor Y | 422 Unprocessable Entity | 422 Unprocessable Entity | **Lolos (PASS)** |
| 6 | Otorisasi Teknisi pada Status | Teknisi mencoba mengubah status tiket yang bukan miliknya | 404 Not Found | 404 Not Found | **Lolos (PASS)** |
| 7 | Peta Transisi Status yang Valid | Teknisi mencoba melompat status langsung dari `assigned` ke `resolved` | 409 Conflict | 409 Conflict | **Lolos (PASS)** |

---

## Kesimpulan Pengujian Fase 5
1. **Validasi Kemitraan Vendor:** Tenant hanya dapat meneruskan tiket kepada vendor yang terikat aktif di tabel `tenant_vendors`.
2. **Validasi Personel Vendor:** Admin vendor hanya dapat mendelegasikan tiket kepada teknisi aktif dalam naungan perusahaannya sendiri.
3. **Integritas Alur Status:** Transisi status tiket secara ketat mengikuti alur `new -> forwarded -> assigned -> in_progress -> resolved` dengan pencatatan riwayat audit dan pemenuhan syarat catatan pada penyelesaian tiket.

---

## Hasil Uji Verifikasi Agregasi Dashboard (Fase 8 - Task T75)

Tanggal pengujian: 2026-11-18  
Target branch: `feature/dashboard`  
Lingkungan pengujian: Localhost REST API (Node.js Express + MySQL)

### 1. Pencocokan Data API vs Query SQL Manual (Tenant 1)

| Metrik Dashboard | Nilai API (`/dashboard/summary`) | Nilai SQL Manual | Status Pencocokan |
|:---|:---:|:---:|:---:|
| Total Tiket | 14 | 14 | **Sesuai (MATCH)** |
| Tiket Status: `new` | 4 | 4 | **Sesuai (MATCH)** |
| Tiket Status: `forwarded` | 2 | 2 | **Sesuai (MATCH)** |
| Tiket Status: `assigned` | 3 | 3 | **Sesuai (MATCH)** |
| Tiket Status: `in_progress` | 2 | 2 | **Sesuai (MATCH)** |
| Tiket Status: `resolved` | 3 | 3 | **Sesuai (MATCH)** |
| Tiket Overdue (Aktif & Lewat SLA) | 7 | 7 | **Sesuai (MATCH)** |
| Rata-rata Durasi Selesai (Jam) | 9.3 | 9.3 | **Sesuai (MATCH)** |
| Persentase Kepatuhan SLA (%) | 66.7% | 66.7% | **Sesuai (MATCH)** |
| Jumlah Tiket Kumulatif Per Area | 14 | 14 | **Sesuai (MATCH)** |

### 2. Pengujian Role Guard Postman

| Skenario | Role Penguji | Endpoint | Expected | Actual | Status |
|:---|:---|:---|:---:|:---:|:---:|
| Ringkasan Dashboard | `tenant_admin` | `GET /dashboard/summary` | 200 OK | 200 OK | **Lolos (PASS)** |
| Rekap Per Area | `tenant_admin` | `GET /dashboard/by-area` | 200 OK | 200 OK | **Lolos (PASS)** |
| Rekap Per Vendor | `tenant_admin` | `GET /dashboard/by-vendor` | 200 OK | 200 OK | **Lolos (PASS)** |
---

## Rekapitulasi Final Pengujian 9 Kasus Isolasi Hak Akses & Multi-Tenant (Fase 10 - Task T89)

Tanggal verifikasi final: 2026-11-19  
Lingkungan pengujian: Localhost REST API (Node.js Express + MySQL)  
Koleksi Postman: `docs/postman/`

Sesuai spesifikasi `CONTEXT.md` Bagian 18, seluruh 9 kasus pengujian isolasi hak akses, multi-tenancy, dan workflow wajib diuji dan dipastikan lolos:

| No | Kasus Uji | Skenario Pengujian | Input / Header | Expected Status | Actual Status | Hasil |
|:---:|:---|:---|:---|:---:|:---:|:---:|
| **1** | Isolasi Tiket Lintas Tenant | Admin Tenant B membaca tiket milik Tenant A | `GET /api/v1/tickets/1` (Token Tenant B) | **404 Not Found** | 404 Not Found | **Lolos (PASS)** |
| **2** | Kemitraan Tenant-Vendor | Admin Tenant meneruskan tiket ke vendor tanpa relasi kemitraan aktif | `PATCH /api/v1/tickets/2/forward` (body `vendor_id: 999`) | **422 Unprocessable** | 422 Unprocessable | **Lolos (PASS)** |
| **3** | Isolasi Tiket Antar Vendor | Admin Vendor 2 membaca tiket yang ditugaskan ke Vendor 1 | `GET /api/v1/tickets/:idV1` (Token Vendor 2) | **404 Not Found** | 404 Not Found | **Lolos (PASS)** |
| **4** | Penugasan Teknisi Lintas Vendor | Admin Vendor 1 menugaskan teknisi milik Vendor 2 | `PATCH /api/v1/tickets/2/assign` (body `technician_id: 6`) | **422 Unprocessable** | 422 Unprocessable | **Lolos (PASS)** |
| **5** | Isolasi Tiket Antar Teknisi | Teknisi membaca tiket yang bukan menjadi tugas dirinya | `GET /api/v1/tickets/:idOther` (Token Teknisi) | **404 Not Found** | 404 Not Found | **Lolos (PASS)** |
| **6** | Otorisasi Teknisi pada Status | Teknisi mencoba mengubah status tiket milik orang lain | `PATCH /api/v1/tickets/:idOther/status` | **404 Not Found** | 404 Not Found | **Lolos (PASS)** |
| **7** | Pencegahan Lompat Transisi Status | Teknisi mencoba mengubah tiket status `new`/`assigned` langsung ke `resolved` | `PATCH /api/v1/tickets/:id/status` (to: `resolved`) | **409 Conflict** | 409 Conflict | **Lolos (PASS)** |
| **8** | Autentikasi Tanpa / Token Rusak | Request endpoint terproteksi tanpa header Authorization atau token cacat | `GET /api/v1/tickets/1` (Token rusak) | **401 Unauthorized** | 401 Unauthorized | **Lolos (PASS)** |
| **9** | Pencegahan Parameter Tampering | Request pembuatan tiket menyisipkan `tenant_id: 999` palsu di body | `POST /api/v1/tickets` (body `tenant_id: 999`) | **201 Created** (`tenant_id: 1` dari JWT) | 201 Created (`tenant_id: 1`) | **Lolos (PASS)** |

### Kesimpulan Final Pengujian
Seluruh 9 kasus uji isolasi multi-tenant dan hak akses peran berhasil diverifikasi dan terbukti aman:
- Data antar-tenant tidak pernah bocor (mengembalikan 404).
- Keamanan berbasis token JWT berjalan tanpa celah spoofing parameter.
- Aturan integritas workflow operasional tiket ditaati sepenuhnya oleh backend dan mobile client.


---

## Tabel Pengujian Black Box Aplikasi Mobile (Fase 10 - Task T88)

Tanggal pengujian: 2026-11-19  
Lingkungan pengujian: Android Emulator / Pixel 6 (API 34) & Flutter Test Suite  
Metode: Black Box Testing (Equivalence Partitioning & Boundary Value Analysis)

| ID | Modul / Fitur | Skenario Pengujian | Masukan (Input) | Hasil yang Diharapkan | Hasil Pengujian | Status |
|:---|:---|:---|:---|:---|:---|:---:|
| **BB-01** | Autentikasi | Login dengan kredensial kosong | Email & Password kosong | Muncul pesan error validasi pada field formulir | Sesuai | **PASS** |
| **BB-02** | Autentikasi | Login format email salah | `admin.nusa` (tanpa domain) | Validasi menolak: "Format email tidak valid" | Sesuai | **PASS** |
| **BB-03** | Autentikasi | Login password salah | Password keliru | SnackBar error server: "Email atau password salah" | Sesuai | **PASS** |
| **BB-04** | Autentikasi | Login peran super admin | Akun `superadmin@fibertrack.id` | Ditolak oleh guard aplikasi mobile | Sesuai | **PASS** |
| **BB-05** | Autentikasi | Login sukses tenant admin | `admin.nusa@fibertrack.id` | Masuk ke Beranda Admin Tenant, token JWT tersimpan aman | Sesuai | **PASS** |
| **BB-06** | Pengaturan | Ganti tema aplikasi | Pilih Mode Terang / Gelap / Sistem | Tema aplikasi berubah seketika, tersimpan di SharedPreferences | Sesuai | **PASS** |
| **BB-07** | Pengaturan | Konfirmasi keluar (Logout) | Klik Logout -> Konfirmasi Batal / Ya | Sesi JWT dihapus, router mengarahkan ke halaman login | Sesuai | **PASS** |
| **BB-08** | Tiket Gangguan | Buat tiket deskripsi < 10 karakter | Deskripsi 5 karakter | Validasi formulir menolak: "Deskripsi minimal 10 karakter" | Sesuai | **PASS** |
| **BB-09** | Tiket Gangguan | Buat tiket sukses | Pelanggan, Area, ODP, Jenis, Prioritas valid | Tiket baru terbuat, nomor TKT terbit, SLA dihitung otomatis | Sesuai | **PASS** |
| **BB-10** | Tiket Gangguan | Cari tiket dan filter status | Query nama / nomor & filter `in_progress` | Daftar menampilkan tiket yang sesuai secara instan | Sesuai | **PASS** |
| **BB-11** | Tiket Gangguan | Tampilan SLA Badge | Tiket overdue / on track | Badge menampilkan warna, teks status, dan countdown waktu | Sesuai | **PASS** |
| **BB-12** | Alur Kerja | Teruskan tiket ke vendor | Pilih Mitra Vendor aktif | Status tiket berubah jadi `forwarded`, notifikasi terkirim | Sesuai | **PASS** |
| **BB-13** | Alur Kerja | Tugaskan teknisi lapangan | Pilih Teknisi vendor | Status tiket berubah jadi `assigned`, notifikasi terkirim | Sesuai | **PASS** |
| **BB-14** | Alur Kerja | Mulai pengerjaan tiket | Klik Mulai Pengerjaan | Status tiket menjadi `in_progress`, tombol unggah foto aktif | Sesuai | **PASS** |
| **BB-15** | Alur Kerja | Selesaikan tiket tanpa catatan | Klik Selesaikan tanpa catatan | Validasi menolak: "Catatan wajib diisi minimal 5 karakter" | Sesuai | **PASS** |
| **BB-16** | Bukti Foto | Unggah foto bukti gangguan | Pilih gambar dari galeri / kamera | Foto terunggah, muncul di galeri detail tiket | Sesuai | **PASS** |
| **BB-17** | Notifikasi | Polling & tandai telah dibaca | Buka halaman notifikasi -> klik item | Badge unread di NavigationBar berkurang, status terbaca | Sesuai | **PASS** |
| **BB-18** | Dashboard | Muat ringkasan & grafik area | Buka menu Dashboard | Kartu metrik, bar chart per area, performa vendor tampil akurat | Sesuai | **PASS** |
| **BB-19** | Master Area | Tambah & hapus area | Buat area baru -> Hapus area | Area berhasil dibuat dan terhapus saat tidak ada keterikatan data | Sesuai | **PASS** |
| **BB-20** | Master Area | Hapus area yang sedang digunakan | Hapus area dengan relasi tiket/ODP | Muncul pesan error proteksi konflik data (409) | Sesuai | **PASS** |
| **BB-21** | Master Pelanggan | Tambah pelanggan & validasi ODP | Pilih area dan ODP yang sesuai | Pelanggan tersimpan dengan pemetaan area & ODP yang valid | Sesuai | **PASS** |

