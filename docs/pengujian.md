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
