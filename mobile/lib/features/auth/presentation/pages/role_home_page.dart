import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/user.dart';

class RoleHomePage extends StatelessWidget {
  final User? user;

  const RoleHomePage({super.key, this.user});

  String _getRoleTitle(String? role) {
    switch (role) {
      case 'tenant_admin':
        return AppStrings.roleTenantAdmin;
      case 'vendor_admin':
        return AppStrings.roleVendorAdmin;
      case 'technician':
        return AppStrings.roleTechnician;
      default:
        return 'Pengguna';
    }
  }

  String _getHomeCardTitle(String? role) {
    switch (role) {
      case 'tenant_admin':
        return 'Manajemen & Pemantauan Gangguan';
      case 'vendor_admin':
        return 'Pusat Penugasan & Tiket Masuk';
      case 'technician':
        return 'Pusat Tugas & Pengerjaan Lapangan';
      default:
        return 'Beranda Aplikasi';
    }
  }

  String _getHomeCardDescription(String? role) {
    switch (role) {
      case 'tenant_admin':
        return 'Kelola tiket gangguan pelanggan, teruskan ke mitra vendor, dan pantau SLA penyelesaian jaringan.';
      case 'vendor_admin':
        return 'Terima tiket dari tenant dan tugaskan langsung ke teknisi yang bertugas di lapangan.';
      case 'technician':
        return 'Lihat daftar tugas gangguan Anda, perbarui status pengerjaan, dan laporkan bukti penyelesaian.';
      default:
        return 'Selamat datang di sistem Fiber Track.';
    }
  }

  String _getPrimaryActionLabel(String? role) {
    switch (role) {
      case 'vendor_admin':
        return 'Buka Tiket Masuk';
      case 'technician':
        return 'Buka Tugas Saya';
      default:
        return 'Buka Daftar Tiket';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final role = user?.role;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getRoleTitle(role)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: AppStrings.settings,
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Profil / Identitas
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.r16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        role == 'technician'
                            ? Icons.build_rounded
                            : role == 'vendor_admin'
                            ? Icons.business_center_rounded
                            : Icons.admin_panel_settings_rounded,
                        size: 32,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: AppSizes.p16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Pengguna',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSizes.p4),
                          Text(
                            user?.email ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSizes.p8),
                          Chip(
                            visualDensity: VisualDensity.compact,
                            label: Text(
                              _getRoleTitle(role),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: theme.colorScheme.primaryContainer,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p20),

            // Card Ringkasan / Petunjuk Peran
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.r16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: AppSizes.p8),
                        Expanded(
                          child: Text(
                            _getHomeCardTitle(role),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.p12),
                    Text(
                      _getHomeCardDescription(role),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          context.push('/tickets');
                        },
                        icon: const Icon(Icons.confirmation_number_outlined),
                        label: Text(_getPrimaryActionLabel(role)),
                      ),
                    ),
                    if (role == 'tenant_admin') ...[
                      const SizedBox(height: AppSizes.p12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.push('/tickets/create');
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Buat Tiket Baru'),
                        ),
                      ),
                      const SizedBox(height: AppSizes.p12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonalIcon(
                          onPressed: () {
                            context.push('/dashboard');
                          },
                          icon: const Icon(Icons.dashboard_outlined),
                          label: const Text('Buka Dashboard Rekap'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
