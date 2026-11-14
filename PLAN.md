# PLAN.md - Rencana pengerjaan Fiber Track

Acuan teknis ada di `CONTEXT.md`; aturan kerja AI ada di `AGENTS.md`. Centang task saat selesai (di commit yang sama dengan task itu, tanpa commit terpisah).

## Ringkasan cara kerja (baca ini dulu)
1. **Anda menjalankan AI per FASE** (satu prompt untuk satu fase, lihat tabel di bawah).
2. **Di dalam fase, AI tetap bekerja per TASK:** satu task selesai, diuji, lalu di-commit sendiri oleh AI. Baru lanjut ke task berikutnya. Jadi satu fase menghasilkan banyak commit kecil yang berurutan, bukan satu commit besar.
3. **Kalau limit habis atau Anda ingin berhenti, tidak ada yang rusak.** Task yang sudah di-commit aman. Sesi berikutnya (tool yang sama atau berbeda) lanjut dari task pertama yang belum dicentang memakai prompt "Lanjut".
4. **Anda memeriksa, lalu push.** AI tidak pernah push. Anda cek `git log --oneline`, jalankan hasilnya, lalu `git push` di akhir sesi kerja.

## Aturan commit (WAJIB, berlaku untuk AI dan Anda)

| Hal | Aturan |
|---|---|
| **Siapa yang commit** | **AI**, otomatis, sesuai prompt sesi di bawah. Anda tidak perlu mengetik perintah commit. Pengecualian: T01 dan T02 Anda kerjakan sendiri (lihat catatan di tiap task) |
| **Kapan commit** | Tepat **setelah satu task selesai dan lolos uji** ("Selesai jika" terpenuhi, `flutter analyze`/pengecekan bersih). Tidak boleh ditunda sampai akhir fase |
| **Isi satu commit** | Hanya perubahan **satu task** + centang task itu di `PLAN.md` + catatan serah terima. Tidak boleh menggabungkan dua task |
| **Cara `git add`** | Per folder atau file milik task (`git add backend PLAN.md`). **Dilarang `git add .`** |
| **Pesan commit** | Persis seperti yang tertera di tiap task (format Conventional Commits). Boleh disesuaikan sedikit, tetap formatnya |
| **Tidak boleh masuk commit** | `.env`, `node_modules/`, `uploads/`, `build/`, `.dart_tool/`, keystore |
| **Task gagal / error / belum stabil** | **JANGAN commit.** AI berhenti, melaporkan masalah, dan mencatatnya di Catatan serah terima. Task tidak dicentang |
| **Push** | Dilakukan **Anda**, bukan AI: `git push` (atau `git push -u origin <branch>` untuk branch baru) di akhir sesi kerja atau akhir hari, setelah `git log --oneline` Anda periksa |
| **Dilarang** | `git push --force`, mengubah tanggal commit, squash/rebase riwayat, menggabungkan commit, `git commit --amend` pada commit yang sudah di-push |
| **Salah commit** | Jangan menulis ulang riwayat. Perbaiki dengan commit baru (`fix: ...`) |

### Branch dan merge
- Satu fase = satu (atau dua) branch `feature/...` seperti tabel di bawah. **AI membuat branch** di awal fase (`git switch -c ...`) bila belum ada.
- **AI tidak merge dan tidak push.** Merge dilakukan Anda di akhir fase lewat Pull Request di GitHub.
- Saat merge, pilih **"Create a merge commit"**. **Jangan "Squash and merge"** (itu meleburkan semua commit fase menjadi satu).
- Sebelum memulai fase berikutnya: merge dulu, lalu `git switch main` dan `git pull`.

### Cek cepat setelah AI selesai satu sesi
```powershell
git status          # harus bersih (tidak ada file tertinggal)
git log --oneline   # satu commit per task, urut sesuai nomor task
```
Kalau satu commit isinya campur beberapa task, atau ada task yang tidak ter-commit, laporkan ke AI di sesi berikutnya dan perbaiki dengan commit baru.

## Fase, rentang task, dan branch

| Fase | Task | Branch | Prasyarat sebelum menjalankan |
|---|---|---|---|
| Awal (manual) | T01-T02 | `main` | Git terpasang, repo GitHub dibuat |
| 1a | T03-T10 | `feature/backend-foundation` | Node.js 20+; **T04 ke atas:** MySQL menyala, database `fibertrack` dibuat, `backend/.env` terisi |
| 1b | T11-T14 | `feature/backend-auth` | Sama seperti 1a; merge 1a dulu |
| 2a | T15-T22 | `feature/mobile-foundation` | Flutter SDK dan emulator siap, `flutter doctor` bersih |
| 2b | T23-T27 | `feature/mobile-auth` | Backend jalan (`npm run dev`); merge 2a dulu |
| 3 | T28-T36 | `feature/master-lookup` | Backend dan database terisi seed |
| 4 | T37-T53 | `feature/ticket-core` | - |
| 5 | T54-T61 | `feature/ticket-workflow` | - |
| 6 | T62-T65 | `feature/ticket-photos` | - |
| 7 | T66-T70 | `feature/sla-notifications` | - |
| 8 | T71-T79 | `feature/dashboard` | - |
| 9 | T80-T84 | `feature/master-crud` | Opsional (potong jika waktu mepet) |
| 10 | T85-T93 | `feature/finishing` | - |

Fase besar (4 dan 8, belasan task) sebaiknya dipecah menjadi dua sesi memakai prompt "Lanjut" di bawah, dan itu tidak masalah karena commit sudah per task.

## Prompt yang dipakai

Buka **folder root** repo di tool AI, lalu salin salah satu prompt di bawah. Ganti bagian dalam `[...]`.

### Prompt A - Jalankan satu fase
```
Baca CONTEXT.md, AGENTS.md, dan PLAN.md (termasuk Catatan serah terima).

Sesi ini: kerjakan FASE [nama fase] = task [Txx] sampai [Txx] dari PLAN.md,
berurutan, satu task satu per satu.
Branch: [nama branch dari tabel]. Jika belum ada, buat dengan `git switch -c`;
jika sudah ada, pindah ke branch itu. Jangan merge dan jangan push.

Aturan per task (wajib, menggantikan larangan commit di AGENTS.md):
1. Kerjakan HANYA task yang sedang berjalan. Jangan mengerjakan task berikutnya
   sebelum task ini selesai dan ter-commit.
2. Jalankan dan uji sendiri sesuai "Selesai jika" dan pengecekan di AGENTS.md.
3. Jika lolos: centang task di PLAN.md, tambah catatan serah terima, lalu buat
   SATU commit berisi hanya perubahan task itu, dengan pesan dari PLAN.md.
   Gunakan `git add <folder/file milik task> PLAN.md`; dilarang `git add .`;
   jangan pernah meng-commit .env, node_modules, uploads, build.
4. Jika gagal atau ada error yang belum teratasi (termasuk MySQL tidak terhubung
   atau .env belum lengkap): BERHENTI, JANGAN commit, JANGAN centang, catat di
   Catatan serah terima, laporkan masalahnya. Jangan mengarang hasil uji.
5. Setelah tiap commit, tulis ringkasan 3 baris (apa yang dibuat, cara uji,
   hash commit), lalu lanjut ke task berikutnya dalam rentang.
6. Jangan push, jangan ubah tanggal commit, jangan gabungkan dua task dalam
   satu commit, jangan kerjakan task di luar rentang.
7. Jika limit hampir habis: selesaikan task yang sedang berjalan sampai stabil lalu
   commit; jika tidak sempat, JANGAN commit setengah jadi, catat kondisinya di
   Catatan serah terima, lalu berhenti.
8. Di akhir (atau saat berhenti), tampilkan `git status` dan `git log --oneline`.
```

### Prompt B - Lanjut setelah limit habis (atau sesi baru / tool lain)
```
Baca CONTEXT.md, AGENTS.md, dan PLAN.md (termasuk Catatan serah terima).

Lanjutkan pekerjaan: mulai dari task pertama yang BELUM dicentang di PLAN.md,
sampai [Txx / akhir fase ini]. Branch: [nama branch].

Langkah awal wajib:
1. Jalankan `git status` dan `git log --oneline -10`.
2. Jika ada perubahan yang belum ter-commit (sisa task yang terputus karena limit):
   baca Catatan serah terima, periksa dan selesaikan task itu, uji, lalu commit
   sebagai satu task. Jika tidak yakin file mana milik task apa, BERHENTI dan tanya.
3. Setelah itu ikuti aturan per task yang sama seperti Prompt A (satu task satu
   commit, git add per folder, tanpa push, berhenti jika gagal).
```

### Prompt C - Satu task saja
```
Baca CONTEXT.md, AGENTS.md, dan PLAN.md (termasuk Catatan serah terima).
Kerjakan hanya task [Txx]. Ikuti aturan per task yang sama seperti Prompt A
(uji, centang, catatan serah terima, satu commit dengan pesan dari PLAN.md,
git add per folder, tanpa push). Setelah itu berhenti.
```

### Perintah berhenti kapan saja
Kirim: `Selesaikan task yang sedang berjalan sampai ter-commit, lalu berhenti. Jangan mulai task berikutnya, tampilkan git log --oneline.`

## Ritme dan prioritas
- Total 93 task. Isi tanggal UAS: `____`. Hitung sisa hari, lalu target kira-kira `jumlah task / sisa hari` per hari (mis. 5 minggu ~ 35 hari ~ 3 task per hari).
- Jika waktu mepet, potong dari bawah: **Fase 9** dulu, lalu T91, lalu T79. Fase 1-8 dan 10 adalah inti yang harus selesai.
- Sisihkan 3-4 hari terakhir untuk Fase 10, jurnal, dan video.
- Jika sebuah task terasa terlalu besar, **pecah** jadi dua (tambahkan sub-nomor, mis. T41a, T41b) sebelum menjalankannya.
- Urutan fase tidak boleh dilompati, karena fase berikutnya bergantung pada yang sebelumnya.

---

## Fase 1 - Fondasi dan backend auth (branch: `feature/backend-foundation`, `feature/backend-auth`)
- [x] **T01** Inisialisasi repo: struktur folder (`backend/`, `mobile/`, `docs/`), `.gitignore`, README awal. **Dikerjakan manual oleh Anda** (bukan AI), langsung di `main`. Selesai jika struktur ada dan terlacak Git. Commit: `chore: init repository structure`
- [x] **T02** Tambahkan `CONTEXT.md`, `AGENTS.md`, `PLAN.md`, `docs/erd-fibertrack.dbml`. **Dikerjakan manual oleh Anda**, langsung di `main`. Commit: `docs: add project context, agent rules, plan and ERD`
- [x] **T03** Scaffold backend Express: `package.json`, `app.js`, `server.js`, `GET /health`, config env, `.env.example`. Selesai jika `/health` menjawab. Commit: `chore(backend): scaffold express app`
- [x] **T04** Koneksi MySQL (pool) dan cek DB di `/health`. Commit: `feat(backend): add mysql connection`
- [x] **T05** Runner migrasi (`npm run migrate`) + migrasi 001: `tenants`, `vendors`, `tenant_vendors`, `users`. Commit: `feat(db): add core tables migration`
- [x] **T06** Migrasi 002: `areas`, `odps`, `customers`, `issue_types`, `priorities`. Commit: `feat(db): add master tables migration`
- [x] **T07** Migrasi 003: `tickets`, `ticket_histories`, `ticket_photos`, `notifications` (+ indeks dan FK sesuai DBML). Commit: `feat(db): add ticket tables migration`
- [x] **T08** Seed 1: tenant, vendor, relasi, pengguna semua peran (password di-hash). `npm run seed`. Commit: `feat(db): seed tenants, vendors and users`
- [x] **T09** Seed 2: master per tenant (area, ODP, jenis gangguan, prioritas+SLA, pelanggan). Commit: `feat(db): seed master data`
- [x] **T10** Middleware dasar: helper response, `AppError`, `errorHandler`, `validate` (zod). Selesai jika error mengikuti format `CONTEXT.md` bagian 14. Commit: `feat(backend): add error handling and validation middleware`
- [x] **T11** `POST /auth/login` (schema, repository, service, controller, route; bcrypt + JWT berisi userId/role/tenantId/vendorId). Selesai jika login sukses dan gagal teruji di Postman. Commit: `feat(auth): add login endpoint`
- [x] **T12** Middleware `auth` (verifikasi JWT -> `req.auth`), `requireRole`, dan `GET /auth/me`. Commit: `feat(auth): add jwt middleware, role guard and me endpoint`
- [x] **T13** `helmet`, `cors`, dan rate limit di `/auth/login`. Commit: `feat(backend): add security middleware`
- [x] **T14** Koleksi Postman awal + environment (login semua peran, token tersimpan). Commit: `docs: add postman collection for auth`

## Fase 2 - Fondasi Flutter dan auth mobile (branch: `feature/mobile-foundation`, `feature/mobile-auth`)
- [x] **T15** Proyek Flutter sudah dibuat manual di `mobile/` (`flutter create . --project-name fibertrack --org com.fibertrack --platforms=android`); jangan dibuat ulang. Tugas: pastikan nama paket `fibertrack`, tambah paket yang disetujui di `pubspec.yaml`, buat struktur folder `core/` dan `features/` (beri file `.gitkeep` pada folder kosong), rapikan `mobile/README.md`, jalankan `flutter pub get` dan `flutter analyze`. Commit: `chore(mobile): scaffold flutter project`
- [x] **T16** Core dasar: `app_config.dart` (dart-define), `app_strings.dart`, `app_sizes.dart`, `exceptions.dart`, `failures.dart`. Commit: `feat(mobile): add core config, constants and error types`
- [x] **T17** Manajemen aset: folder `assets/`, deklarasi di `pubspec.yaml` (images, icons, fonts), `app_assets.dart`, logo placeholder. Commit: `feat(mobile): add asset management setup`
- [x] **T18** Tema: `app_theme.dart` (terang/gelap), `app_colors.dart`, `StatusColors` (ThemeExtension), `ThemeCubit` + `shared_preferences`. Commit: `feat(mobile): add theme system with dark mode`
- [x] **T19** Network: `DioClient`, `AuthInterceptor` (Bearer + tangani 401), `error_mapper`, penyimpanan token di `flutter_secure_storage`. Commit: `feat(mobile): add network layer and token storage`
- [x] **T20** DI `get_it`, `app.dart`, `main.dart` (MaterialApp.router sementara dengan halaman kosong). Commit: `feat(mobile): add dependency injection and app bootstrap`
- [x] **T21** `validators.dart` (required, email, minLength, maxLength, range) + unit test. Commit: `feat(mobile): add form validators with tests`
- [x] **T22** Widget umum: `AppButton`, `AppTextField`, `LoadingView`, `ErrorView`, `EmptyView`. Commit: `feat(mobile): add common widgets`
- [x] **T23** Auth domain: entity `User`, repository abstrak, use case `Login`, `GetCurrentUser`, `Logout`. Commit: `feat(auth): add auth domain layer`
- [x] **T24** Auth data: model, remote datasource, local datasource (token), repository impl. Commit: `feat(auth): add auth data layer`
- [x] **T25** Auth presentation: `AuthBloc` + `LoginPage` (form validasi, loading, pesan error). Commit: `feat(auth): add login page and bloc`
- [x] **T26** Router + guard berdasarkan status login dan peran; beranda placeholder per peran; tolak `super_admin`. Commit: `feat(auth): add router guard and role-based home`
- [x] **T27** Halaman pengaturan: ganti tema (terang/gelap/sistem) dan logout. Commit: `feat(settings): add theme toggle and logout`

## Fase 3 - Data master baca-saja dan lookup (branch: `feature/master-lookup`)
- [x] **T28** Backend `GET /areas` dan `GET /odps` (filter `area_id`), dicakup `tenantId`. Commit: `feat(master): add areas and odps list endpoints`
- [x] **T29** Backend `GET /issue-types` dan `GET /priorities`. Commit: `feat(master): add issue types and priorities list endpoints`
- [x] **T30** Backend `GET /customers` (cari, paginasi, dicakup tenant). Commit: `feat(master): add customers list endpoint`
- [x] **T31** Backend `GET /vendors` (hanya relasi aktif ke tenant) dan `GET /users?role=technician` (untuk vendor_admin). Commit: `feat(master): add vendors and technicians list endpoints`
- [x] **T32** Postman: skenario lookup + uji lintas tenant (tenant A tidak melihat data tenant B). Commit: `docs: add postman cases for master lookups`
- [x] **T33** Flutter lookup: domain + data untuk area dan ODP. Commit: `feat(master): add area and odp lookup layers`
- [x] **T34** Flutter lookup: domain + data untuk jenis gangguan dan prioritas. Commit: `feat(master): add issue type and priority lookup layers`
- [x] **T35** Flutter lookup: domain + data untuk pelanggan (cari + paginasi). Commit: `feat(master): add customer lookup layers`
- [x] **T36** Komponen dropdown/pemilih yang bisa dipakai ulang (loading, error, kosong, validator). Commit: `feat(mobile): add reusable lookup picker widgets`

## Fase 4 - Tiket: buat, daftar, detail (branch: `feature/ticket-core`)
- [x] **T37** Backend `utils/sla.js` (hitung `sla_due_at`, status `on_track/at_risk/overdue/met/breached`) + unit test. Commit: `feat(sla): add sla utility with tests`
- [x] **T38** Backend: generator nomor tiket + fungsi repository insert tiket dan riwayat awal (transaksi). Commit: `feat(ticket): add ticket number generator and insert repository`
- [x] **T39** Backend `POST /tickets` (validasi `zod`, cek semua ID milik tenant, ODP satu area, `sla_due_at`, status `new`). Commit: `feat(ticket): add create ticket endpoint`
- [x] **T40** Backend `GET /tickets` untuk `tenant_admin` (paginasi). Commit: `feat(ticket): add ticket list for tenant admin`
- [x] **T41** Backend `GET /tickets`: tambah cakupan `vendor_admin` dan `technician` + filter `status`, `area_id`, `vendor_id`, `sla`, `q`. Commit: `feat(ticket): add role scoping and filters to ticket list`
- [x] **T42** Backend `GET /tickets/:id` dan `GET /tickets/:id/histories` (dicakup per peran, 404 jika bukan miliknya). Commit: `feat(ticket): add ticket detail and history endpoints`
- [x] **T43** Backend `PUT /tickets/:id` (hanya status `new`). Commit: `feat(ticket): add update ticket endpoint`
- [x] **T44** Postman: skenario tiket + tes isolasi nomor 1, 3, 5, 8, 9 (`CONTEXT.md` bagian 18), catat hasil di `docs/pengujian.md`. Commit: `docs: add postman cases and isolation test results for tickets`
- [x] **T45** Flutter tiket domain: entity, repository abstrak, use case buat/daftar/detail. Commit: `feat(ticket): add ticket domain layer`
- [x] **T46** Flutter tiket data: model, remote datasource, repository impl. Commit: `feat(ticket): add ticket data layer`
- [x] **T47** Widget `StatusChip` dan `SlaBadge` memakai `StatusColors` (terang/gelap). Commit: `feat(ticket): add status chip and sla badge widgets`
- [x] **T48** `TicketListBloc` + `TicketListPage` (loading, error, kosong, paginasi). Commit: `feat(ticket): add ticket list page`
- [x] **T49** Filter status/SLA dan pencarian di daftar tiket. Commit: `feat(ticket): add ticket list filters and search`
- [x] **T50** `TicketDetailBloc` + `TicketDetailPage` (info + linimasa riwayat). Commit: `feat(ticket): add ticket detail page`
- [x] **T51** Form buat tiket (UI + validasi sesuai `CONTEXT.md` bagian 7, dropdown area -> ODP). Commit: `feat(ticket): add create ticket form ui and validation`
- [x] **T52** Hubungkan form ke bloc dan use case, tangani error server per field, navigasi sukses. Commit: `feat(ticket): connect create ticket form to api`
- [x] **T53** Edit tiket (pakai ulang form, hanya status `new`). Commit: `feat(ticket): add edit ticket`

## Fase 5 - Penugasan dan status (branch: `feature/ticket-workflow`)
- [x] **T54** Backend `PATCH /tickets/:id/forward` (vendor harus relasi aktif; status -> `forwarded`; riwayat; transaksi). Commit: `feat(ticket): add forward to vendor endpoint`
- [x] **T55** Backend `PATCH /tickets/:id/assign` (teknisi aktif, vendor sama; status -> `assigned`). Commit: `feat(ticket): add assign technician endpoint`
- [x] **T56** Backend `PATCH /tickets/:id/status` (peta transisi, hanya teknisi pemilik, catatan wajib saat `resolved`, set `resolved_at`). Commit: `feat(ticket): add status update endpoint`
- [x] **T57** Postman + tes isolasi nomor 2, 4, 6, 7; catat hasil. Commit: `docs: add workflow cases and isolation test results`
- [x] **T58** Flutter: use case + data + UI teruskan ke vendor (bottom sheet pemilih vendor). Commit: `feat(ticket): add forward to vendor flow`
- [x] **T59** Flutter: use case + data + UI tugaskan teknisi. Commit: `feat(ticket): add assign technician flow`
- [x] **T60** Flutter: form ubah status dengan validasi catatan. Commit: `feat(ticket): add status update flow`
- [x] **T61** Beranda per peran: `vendor_admin` (tiket masuk), `technician` (tugas saya) dengan navigasi bawah per peran. Commit: `feat(ticket): add role-based home screens`

## Fase 6 - Foto bukti (branch: `feature/ticket-photos`)
- [ ] **T62** Backend middleware upload (`multer`: tipe, ukuran, nama acak) dan `POST /tickets/:id/photos` (maks 10 foto). Commit: `feat(ticket): add photo upload endpoint`
- [ ] **T63** Backend: sajikan foto lewat endpoint berhak akses dan sertakan daftar foto di detail tiket. Commit: `feat(ticket): serve ticket photos with access control`
- [ ] **T64** Flutter: pilih foto (`image_picker`), validasi tipe/ukuran, unggah dari detail/form status. Commit: `feat(ticket): add photo picker and upload`
- [ ] **T65** Flutter: galeri foto di detail (`CachedNetworkImage` dengan header token, placeholder, errorWidget). Commit: `feat(ticket): add photo gallery in detail`

## Fase 7 - SLA dan notifikasi (branch: `feature/sla-notifications`)
- [ ] **T66** Backend: sertakan `sla_status` dan sisa waktu di respons daftar dan detail tiket. Commit: `feat(sla): include sla status in ticket responses`
- [ ] **T67** Backend: tulis notifikasi di dalam transaksi forward, assign, dan `resolved`. Commit: `feat(notification): create notifications on workflow events`
- [ ] **T68** Backend `GET /notifications` dan `PATCH /notifications/:id/read`. Commit: `feat(notification): add notification endpoints`
- [ ] **T69** Flutter notifikasi: domain + data + bloc + halaman + badge di navigasi, polling 30-60 detik dan saat aplikasi dibuka kembali. Commit: `feat(notification): add notification feature with polling`
- [ ] **T70** Flutter: tampilkan `sla_status` dan sisa waktu di daftar dan detail tiket. Commit: `feat(sla): show sla status in ticket screens`

## Fase 8 - Dashboard (branch: `feature/dashboard`)
- [ ] **T71** Seed 3: tiket contoh di berbagai status dan SLA (termasuk `at_risk`, `overdue`, `breached`). Commit: `feat(db): seed sample tickets`
- [ ] **T72** Backend `GET /dashboard/summary` (jumlah per status, overdue, rata-rata durasi, persentase SLA terpenuhi). Commit: `feat(dashboard): add summary endpoint`
- [ ] **T73** Backend `GET /dashboard/by-area`. Commit: `feat(dashboard): add by-area endpoint`
- [ ] **T74** Backend `GET /dashboard/by-vendor`. Commit: `feat(dashboard): add by-vendor endpoint`
- [ ] **T75** Postman dashboard + cocokkan angka dengan query SQL manual; catat hasil. Commit: `docs: add dashboard cases and manual verification`
- [ ] **T76** Flutter dashboard: domain + data. Commit: `feat(dashboard): add dashboard domain and data layers`
- [ ] **T77** Flutter dashboard: halaman dan kartu ringkasan. Commit: `feat(dashboard): add summary cards`
- [ ] **T78** Flutter dashboard: grafik batang gangguan per area (`fl_chart`). Commit: `feat(dashboard): add area chart`
- [ ] **T79** Flutter dashboard: kinerja per vendor (daftar atau grafik). Commit: `feat(dashboard): add vendor performance section`

## Fase 9 - CRUD data master di aplikasi (prioritas rendah; potong dulu jika waktu mepet) (branch: `feature/master-crud`)
- [ ] **T80** Backend area: `POST`, `PUT`, `DELETE` (hapus ditolak 409 jika dipakai). Commit: `feat(master): add area write endpoints`
- [ ] **T81** Backend pelanggan: `POST`, `PUT`, `DELETE`. Commit: `feat(master): add customer write endpoints`
- [ ] **T82** Backend ODP, jenis gangguan, prioritas: `POST`, `PUT`, `DELETE`. Commit: `feat(master): add odp, issue type and priority write endpoints`
- [ ] **T83** Flutter: kelola area (daftar + form + hapus). Commit: `feat(master): add area management screens`
- [ ] **T84** Flutter: kelola pelanggan (daftar + form + hapus). Commit: `feat(master): add customer management screens`

## Fase 10 - Penyelesaian (branch: `feature/finishing`)
- [ ] **T85** Periksa semua layar di mode gelap; cari dan perbaiki warna hard-coded. Commit: `fix(ui): fix dark mode and remove hard-coded colors`
- [ ] **T86** Periksa state loading, error, kosong di semua layar. Commit: `fix(ui): complete loading, error and empty states`
- [ ] **T87** Unit test tambahan: validators, SLA, use case utama. Commit: `test: add unit tests for validators, sla and use cases`
- [ ] **T88** Tabel pengujian black box di `docs/pengujian.md` + tangkapan layar di `docs/screenshots/`. Commit: `docs: add black box test results and screenshots`
- [ ] **T89** Postman final: jalankan 9 tes isolasi, simpan hasil, ekspor koleksi. Commit: `docs: finalize postman collection and isolation results`
- [ ] **T90** README final: deskripsi, arsitektur, cara menjalankan backend dan mobile, akun demo, daftar endpoint. Commit: `docs: finalize readme`
- [ ] **T91** (opsional) Ikon aplikasi dan splash screen. Commit: `feat(mobile): add app icon and splash screen`
- [ ] **T92** Build APK release dan uji di perangkat nyata. Commit: `chore(mobile): prepare release build`
- [ ] **T93** Tag rilis `v1.0.0`. Commit/tag: `chore: release v1.0.0`

---

## Jalur paralel (bukan commit kode): jurnal dan video
Kerjakan sedikit-sedikit di sela fase, dan simpan draf di `docs/` bila ingin ikut terlacak.
- Saat Fase 1-2: rumusan masalah, tujuan, batasan masalah, dan tinjauan pustaka (kumpulkan 5-10 referensi).
- Saat Fase 3-5: Bab Metode (Waterfall, ERD, arsitektur berlapis, diagram Clean Architecture, alur data).
- Saat Fase 6-8: Bab Hasil dan Pembahasan (tangkapan layar tiap fitur, hasil uji isolasi, tabel black box).
- Saat Fase 10: abstrak (ID dan EN), kesimpulan, daftar pustaka, rapikan format jurnal SI.
- Video: tulis skrip setelah Fase 8; rekam setelah T92; unggah ke YouTube; tempel tautan di README.

## Catatan serah terima
(Diisi AI setelah setiap task. Entri terbaru di atas. Format: `Tanggal - Txx - apa yang selesai - keputusan/kendala - task berikutnya`.)

- 2026-11-15 - T61 - Beranda per peran (MainNavigationPage dengan NavigationBar dinamis sesuai peran, custom header 'Tiket Masuk'/'Tugas Saya'/'Daftar Tiket', profil peran dinamis) selesai - flutter analyze (0 issue) dan flutter test lolos - Task berikutnya: T62 (Fase 6: Foto bukti).

- 2026-11-15 - T60 - Flutter flow ubah status pengerjaan tiket (use case UpdateTicketStatus, UpdateStatusBottomSheet dengan validasi catatan min 5 karakter saat resolved, aksi Mulai Pengerjaan & Selesaikan Tiket di TicketDetailPage) selesai - flutter analyze (0 issue) dan flutter test lolos - Task berikutnya: T61.

- 2026-11-15 - T59 - Flutter flow tugaskan teknisi (GetTechnicians, AssignTicket, TechnicianPickerBottomSheet, integrasi tombol di TicketDetailPage & TicketDetailBloc) selesai - flutter analyze (0 issue) dan flutter test lolos - Task berikutnya: T60.
- 2026-11-13 - T58 - Flutter flow teruskan tiket ke vendor (Vendor entity, VendorModel, GetVendors, ForwardTicket, VendorPickerBottomSheet, integrasi tombol di TicketDetailPage & TicketDetailBloc) selesai - flutter analyze (0 issue) dan flutter test lolos - Task berikutnya: T59.
- 2026-11-13 - T57 - Postman koleksi workflow & tes isolasi (2, 4, 6, 7) selesai & tercatat di docs/pengujian.md - Seluruh 4 tes isolasi lolos (PASS) - Task berikutnya: T58.
- 2026-11-13 - T56 - Backend PATCH /tickets/:id/status (peta transisi assigned->in_progress->resolved, teknisi pemilik, validasi catatan >= 5 karakter saat resolved, set resolved_at=NOW(), riwayat status dalam transaksi) selesai - Teruji 200 OK, 404 teknisi lain, 409 lompat status, 422 catatan pendek - Task berikutnya: T57.
- 2026-11-13 - T55 - Backend PATCH /tickets/:id/assign (validasi teknisi aktif dari vendor yang sama, update status 'assigned', tulis riwayat 'Tiket ditugaskan ke <Teknisi>', transaksi DB) selesai - Teruji 200 OK, 422 teknisi vendor lain, 404 akses tiket vendor lain - Task berikutnya: T56.
- 2026-11-13 - T54 - Backend PATCH /tickets/:id/forward (cek relasi aktif tenant_vendors, update status 'forwarded', tulis riwayat 'Tiket diteruskan ke <Vendor>', transaksi DB) selesai - Teruji 200 OK, 422 vendor non-relasi, 403 guard bukan tenant_admin, 409 tiket bukan status 'new' - Task berikutnya: T55.
- 2026-11-13 - T53 - Edit tiket (reusable TicketFormPage dengan pre-filled data, navigasi dari detail page hanya saat status 'new', updateTicket via TicketFormBloc & TicketRepository) selesai - flutter analyze (0 issue) dan flutter test lolos - Task berikutnya: T54 (Fase 5: Penugasan dan status).
- 2026-11-13 - T52 - Hubungkan TicketFormPage ke TicketFormBloc & CreateTicket use case, mapping error per-field server dari ValidationFailure, routing go_router /tickets, /tickets/create, /tickets/:id, /tickets/:id/edit, dan tombol navigasi sukses selesai - flutter analyze (0 issue) dan flutter test lolos - Task berikutnya: T53.
- 2026-11-13 - T51 - Form buat tiket TicketFormPage (CustomerPickerBottomSheet, dropdown dinamis Area -> ODP, issue_types, priorities, validasi deskripsi 10-1000 dan koordinat berpasangan) selesai - flutter analyze (0 issue) dan flutter test lolos - Task berikutnya: T52.
- 2026-11-13 - T50 - TicketDetailBloc & TicketDetailPage (informasi pelanggan, lokasi ODP, detail gangguan, penugasan vendor/teknisi, SLA badge, dan linimasa riwayat status) selesai - flutter analyze (0 issue) dan flutter test lolos - Task berikutnya: T51.
- 2026-11-13 - T49 - Filter status (semua / popup status), filter SLA (semua / popup SLA), pencarian q (nomor tiket/nama pelanggan), dan tombol reset pada TicketListPage selesai - flutter analyze (0 issue) dan flutter test lolos - Task berikutnya: T50.
- 2026-11-13 - T48 - TicketListBloc & TicketListPage (state loading, error dengan retry, empty view, infinite scroll pagination, TicketCard) selesai - dart format, flutter analyze (0 issue), dan flutter test lolos - Task berikutnya: T49.
- 2026-11-13 - T47 - Widget StatusChip dan SlaBadge dengan integrasi StatusColors ThemeExtension (support tema terang dan gelap) selesai - dart format, flutter analyze (0 issue), dan flutter test lolos - Task berikutnya: T48.
- 2026-11-13 - T46 - Flutter data layer tiket (TicketModel, TicketHistoryModel, TicketPhotoModel, TicketRemoteDataSource, TicketRepositoryImpl, registrasi DI di injection.dart) selesai - flutter analyze (0 issue) dan flutter test lolos - Task berikutnya: T47.
- 2026-11-13 - T45 - Flutter domain tiket (Ticket, TicketHistory, TicketPhoto, TicketStatus, SlaStatus, TicketRepository, CreateTicket, GetTickets, GetTicketDetail, GetTicketHistories) selesai - dart format, flutter analyze (0 issue), dan flutter test lolos - Task berikutnya: T46.
- 2026-11-13 - T44 - Postman koleksi tickets + tes isolasi multi-tenant/peran (1, 3, 5, 8, 9) selesai & tercatat di docs/pengujian.md - Seluruh 5 tes isolasi lolos (PASS) - Task berikutnya: T45.
- 2026-11-13 - T43 - Backend PUT /tickets/:id hanya saat status new oleh tenant_admin (validasi FK, sla_due_at tetap) selesai - Teruji 200 OK & 403 guard untuk role non-tenant_admin - Task berikutnya: T44.
- 2026-11-13 - T42 - Backend GET /tickets/:id & GET /tickets/:id/histories dicakup per peran selesai - Teruji 200 OK untuk tenant pemilik, 404 jika diakses tenant lain atau vendor yang belum ditugaskan - Task berikutnya: T43.
- 2026-11-13 - T41 - Backend GET /tickets cakupan vendor_admin & technician + filter status, area_id, vendor_id, sla, q selesai - Teruji 200 OK untuk tenant_admin, vendor_admin, technician & filter berjalan - Task berikutnya: T42.
- 2026-11-13 - T40 - Backend GET /tickets untuk tenant_admin dengan paginasi, joins customer/area/odp/priority/vendor/technician selesai - Teruji 200 OK & 403 guard untuk role non-tenant_admin - Task berikutnya: T41.
- 2026-11-12 - T39 - POST /tickets (validasi Zod, isolasi tenant semua FK, cek ODP-area, hitung sla_due_at, status new) selesai - Teruji 201 sukses, 422 ODP mismatch, 422 tenant mismatch - Task berikutnya: T40.
- 2026-11-12 - T38 - generateTicketNo (format TKT-YYYYMMDD-XXXX, FOR UPDATE lock) + createTicketWithInitialHistory (transaksi) selesai - Teruji insert + history lolos - Task berikutnya: T39.
- 2026-11-12 - T37 - sla.js (calculateSlaDueAt, getSlaStatus: on_track/at_risk/overdue/met/breached) + 6/6 unit test lolos - Task berikutnya: T38.
- 2026-11-12 - T36 - Reusable UI widgets AppDropdownField<T>, CustomerPickerBottomSheet<T>, dan registrasi DI master lookup di injection.dart selesai - flutter analyze & flutter test lolos - Task berikutnya: T37 (Fase 4: Tiket core).
- 2026-11-12 - T35 - Flutter lookup pelanggan (Customer entity & model, PaginatedResult<T>, MasterLookupRepository & GetCustomers) selesai - flutter analyze & flutter test lolos - Task berikutnya: T36.
- 2026-11-12 - T34 - Flutter lookup jenis gangguan & prioritas (entities, models, GetIssueTypes, GetPriorities, MasterLookupRepository) selesai - flutter analyze & flutter test lolos - Task berikutnya: T35.
- 2026-11-12 - T33 - Flutter lookup area & ODP (Area, Odp entities & models, MasterRemoteDataSource, MasterLookupRepositoryImpl, GetAreas, GetOdps) selesai - flutter analyze & flutter test lolos - Task berikutnya: T34.

- 2026-11-12 - T32 - Koleksi Postman docs/postman/FiberTrack_Master.postman_collection.json dibuat; seluruh pengujian isolasi lintas tenant dan role guard sukses - Task berikutnya: T33 (Fase 3b: Flutter Lookup).
- 2026-11-12 - T31 - Backend GET /vendors (hanya relasi aktif tenant) dan GET /users?role=technician (hanya vendor_admin) selesai - Guard requireRole terpasang, uji isolasi teknisi antar vendor lolos - Task berikutnya: T32.
- 2026-11-12 - T30 - Backend GET /customers (pencarian berparameter, paginasi page & limit, total count, join area & odp, dicakup tenantId) selesai - Uji query dan paginasi lolos - Task berikutnya: T31.
- 2026-11-12 - T29 - Backend GET /issue-types dan GET /priorities dicakup tenantId selesai - Uji endpoint dengan akun demo lolos - Task berikutnya: T30.
- 2026-11-12 - T28 - Backend GET /areas dan GET /odps (filter query area_id, dicakup tenantId dari JWT) selesai - Uji isolasi data tenant lolos - Task berikutnya: T29.

- 2026-11-09 - T27 - Halaman pengaturan (ganti tema terang/gelap/sistem dengan RadioGroup & ThemeCubit) dan tombol logout konfirmasi dialog selesai - Teruji flutter analyze bersih & flutter test lolos - Task berikutnya: T28 (Fase 3: Data master baca-saja).
- 2026-11-09 - T26 - Router guard berbasis login/peran GoRouter, startup token auto-check, tolak super_admin, RoleHomePage per peran selesai - Teruji flutter analyze bersih & flutter test lolos - Task berikutnya: T27.
- 2026-11-09 - T25 - AuthBloc, AuthState, AuthEvent, dan LoginPage (validasi email/password, server error mapping, loading states) selesai - Teruji flutter analyze bersih & flutter test lolos - Task berikutnya: T26.
- 2026-11-09 - T24 - Auth data layer (UserModel, remote & local datasource, AuthRepositoryImpl, android:usesCleartextTraffic di debug AndroidManifest.xml) selesai - Teruji flutter analyze bersih & flutter test lolos - Task berikutnya: T25.
- 2026-11-09 - T23 - Auth domain layer (User entity, AuthRepository, use cases Login, GetCurrentUser, Logout) selesai - Teruji flutter analyze bersih & flutter test lolos - Task berikutnya: T24.

- 2026-11-08 - T22 - Widget umum AppButton, AppTextField, LoadingView, ErrorView, EmptyView selesai - dart format, flutter analyze (0 issue), flutter test lolos - Task berikutnya: T23 (Fase 2b).
- 2026-11-08 - T21 - FormValidators (required, email, minLength, maxLength, range) & unit test selesai - 6/6 test lolos - Task berikutnya: T22.
- 2026-11-08 - T20 - DI get_it, app.dart, dan main.dart bootstrap selesai - MaterialApp.router dengan ThemeCubit terhubung - Task berikutnya: T21.
- 2026-11-08 - T19 - Network layer: DioClient, AuthInterceptor (401 handler), error_mapper, TokenStorage selesai - flutter analyze bersih - Task berikutnya: T20.
- 2026-11-08 - T18 - Sistem tema Material 3 (app_colors, app_theme, StatusColors extension) dan ThemeCubit selesai - Dukungan light/dark mode - Task berikutnya: T19.
- 2026-11-08 - T17 - Setup manajemen aset (assets/images, icons, fonts), pubspec.yaml asset paths, app_assets.dart - Teruji flutter analyze bersih - Task berikutnya: T18.
- 2026-11-08 - T16 - Core config (app_config), app_strings, app_sizes, exceptions & failures selesai - Teruji flutter analyze bersih - Task berikutnya: T17.
- 2026-11-08 - T15 - Scaffold flutter mobile, dependencies pubspec.yaml, folder structure core/ dan features/ dengan .gitkeep selesai - flutter analyze bersih - Task berikutnya: T16.

- 2026-11-08 - T14 - Koleksi Postman dan environment auth (`docs/postman/`) dibuat dan diuji untuk 4 peran; token JWT otomatis tersimpan - Semua pengujian login dan me sukses - Task berikutnya: T15 (Fase 2: Scaffold Flutter).
- 2026-11-08 - T13 - Middleware keamanan HTTP (helmet, cors, loginRateLimiter) selesai dan terpasang di app dan route auth - Header keamanan dan rate limit terverifikasi - Task berikutnya: T14.
- 2026-11-08 - T12 - Middleware auth (JWT -> req.auth), requireRole guard, dan endpoint GET /api/v1/auth/me selesai - Pengujian token valid, tanpa token (401), dan role guard (200 vs 403) lolos - Task berikutnya: T13.
- 2026-11-08 - T11 - Endpoint POST /api/v1/auth/login selesai sesuai arsitektur berlapis (routes -> controller -> service -> repository) - Pesan gagal seragam, token JWT memuat identitas multi-tenant/vendor - Task berikutnya: T12.
- 2026-11-08 - T10 - Middleware AppError, error response standard, errorHandler, dan validasi Zod selesai - Format respons error sesuai CONTEXT.md bagian 14 teruji - Task berikutnya: T11.
- 2026-11-08 - T09 - Seed master per tenant (area, ODP, issue_types, priorities+SLA, customers) selesai - Idempotent ON DUPLICATE KEY UPDATE - Task berikutnya: T10.
- 2026-11-08 - T08 - Seed core (tenants, vendors, tenant_vendors, users semua peran) selesai - Password demo 'Password123!' di-hash bcrypt, idempotent - Task berikutnya: T09.
- 2026-11-08 - T07 - Migrasi 003 tabel tiket (tickets, ticket_histories, ticket_photos, notifications) dengan indeks dan FK selesai - Teruji dieksekusi via runner migrasi - Task berikutnya: T08.
- 2026-11-08 - T06 - Migrasi 002 tabel master (areas, odps, customers, issue_types, priorities) selesai - Teruji dieksekusi via runner migrasi - Task berikutnya: T07.
- 2026-11-08 - T05 - Runner migrasi idempotent dengan pelacakan schema_migrations + migrasi 001 tabel core selesai - Teruji dieksekusi via npm run migrate - Task berikutnya: T06.
- 2026-11-08 - T04 - Koneksi MySQL pool mysql2/promise dibuat di src/config/db.js dan terintegrasi di GET /health - Status DB connected teruji - Task berikutnya: T05.
- 2026-11-08 - T03 - Scaffold backend Express (package.json ES module, config/env.js, app.js, server.js, .env.example) selesai - Endpoint GET /health teruji - Task berikutnya: T04.
