import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/user.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../ticket/presentation/pages/ticket_list_page.dart';
import 'role_home_page.dart';

class MainNavigationPage extends StatefulWidget {
  final User? user;

  const MainNavigationPage({super.key, this.user});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final role = widget.user?.role;

    // Navigation items based on role
    // vendor_admin: Beranda/Dashboard, Tiket Masuk, Pengaturan
    // technician: Beranda/Profil, Tugas Saya, Pengaturan
    // tenant_admin: Beranda, Tiket, Pengaturan
    final String ticketTabLabel = role == 'vendor_admin'
        ? AppStrings.incomingTickets
        : role == 'technician'
        ? AppStrings.myAssignedTickets
        : AppStrings.navTickets;

    final String ticketHeaderTitle = role == 'vendor_admin'
        ? AppStrings.incomingTickets
        : role == 'technician'
        ? AppStrings.myAssignedTickets
        : AppStrings.allTickets;

    final pages = [
      RoleHomePage(user: widget.user),
      TicketListPage(customTitle: ticketHeaderTitle, showAppBar: true),
      const SettingsPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: AppStrings.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.confirmation_number_outlined),
            selectedIcon: const Icon(Icons.confirmation_number_rounded),
            label: ticketTabLabel,
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: AppStrings.navSettings,
          ),
        ],
      ),
    );
  }
}
