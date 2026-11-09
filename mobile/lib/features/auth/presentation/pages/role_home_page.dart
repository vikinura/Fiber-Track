import 'package:flutter/material.dart';

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
            onPressed: () {
              Navigator.of(context).pushNamed('/settings');
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.person_rounded,
                  size: 40,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: AppSizes.p16),
              Text(
                user?.name ?? 'Nama Pengguna',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.p4),
              Text(
                user?.email ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSizes.p8),
              Chip(
                label: Text(
                  _getRoleTitle(role),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: theme.colorScheme.primaryContainer,
              ),
              const SizedBox(height: AppSizes.p32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  child: Text(
                    role == 'tenant_admin'
                        ? 'Beranda Tiket & Dashboard Tenant'
                        : role == 'vendor_admin'
                        ? 'Beranda Tiket Masuk Vendor'
                        : 'Beranda Tugas Saya (Teknisi)',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
