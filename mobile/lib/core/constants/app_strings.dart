class AppStrings {
  // App General
  static const String appName = 'Fiber Track';
  static const String appTagline = 'Pemantauan Gangguan Jaringan Fiber Optic';

  // Auth
  static const String login = 'Masuk';
  static const String loginTitle = 'Selamat Datang';
  static const String loginSubtitle = 'Silakan masuk dengan akun Anda';
  static const String email = 'Email';
  static const String emailHint = 'nama@perusahaan.com';
  static const String password = 'Password';
  static const String passwordHint = 'Masukkan password';
  static const String logout = 'Keluar';
  static const String logoutConfirmationTitle = 'Konfirmasi Keluar';
  static const String logoutConfirmationMessage =
      'Apakah Anda yakin ingin keluar dari aplikasi?';
  static const String superAdminBlockedMessage =
      'Akun Super Admin tidak dapat digunakan di aplikasi mobile. Silakan gunakan dashboard web.';

  // Buttons & Actions
  static const String retry = 'Coba Lagi';
  static const String cancel = 'Batal';
  static const String save = 'Simpan';
  static const String send = 'Kirim';
  static const String ok = 'OK';

  // Common States
  static const String loading = 'Memuat data...';
  static const String emptyData = 'Tidak ada data';
  static const String unexpectedError = 'Terjadi kesalahan sistem';
  static const String networkError =
      'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
  static const String sessionExpired =
      'Sesi Anda telah berakhir. Silakan masuk kembali.';
  static const String validationErrorTitle = 'Periksa Kembali Input';

  // Roles
  static const String roleTenantAdmin = 'Admin Tenant';
  static const String roleVendorAdmin = 'Admin Vendor';
  static const String roleTechnician = 'Teknisi';
  static const String roleSuperAdmin = 'Super Admin';

  // Settings
  static const String settings = 'Pengaturan';
  static const String theme = 'Tema Aplikasi';
  static const String themeSystem = 'Ikuti Sistem';
  static const String themeLight = 'Mode Terang';
  static const String themeDark = 'Mode Gelap';

  // Navigation & Role Screens
  static const String navHome = 'Beranda';
  static const String navTickets = 'Tiket';
  static const String navSettings = 'Pengaturan';
  static const String incomingTickets = 'Tiket Masuk';
  static const String myAssignedTickets = 'Tugas Saya';
  static const String allTickets = 'Daftar Tiket';
  static const String tenantHomeTitle = 'Beranda Admin Tenant';
  static const String vendorHomeTitle = 'Beranda Admin Vendor';
  static const String technicianHomeTitle = 'Beranda Teknisi';

  // Dashboard
  static const String dashboard = 'Dashboard';
  static const String dashboardTitle = 'Dashboard Pemantauan';
  static const String totalTickets = 'Total Tiket';
  static const String activeTickets = 'Tiket Aktif';
  static const String overdueTickets = 'Tiket Overdue';
  static const String slaCompliance = 'Kepatuhan SLA';
  static const String avgResolutionTime = 'Rata-rata Selesai';
  static const String ticketDistributionByArea = 'Distribusi Tiket per Area';
  static const String vendorPerformance = 'Performa Mitra Vendor';
  static const String statusBreakdown = 'Rincian Status Tiket';
  static const String resolvedTickets = 'Tiket Selesai';
}
