import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../notification/presentation/bloc/notification_bloc.dart';
import '../../../notification/presentation/bloc/notification_event.dart';
import '../../../notification/presentation/bloc/notification_state.dart';
import '../../../notification/presentation/pages/notification_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../ticket/presentation/pages/ticket_list_page.dart';
import '../../domain/entities/user.dart';
import 'role_home_page.dart';

class MainNavigationPage extends StatefulWidget {
  final User? user;

  const MainNavigationPage({super.key, this.user});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  Timer? _pollingTimer;
  late final NotificationBloc _notificationBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notificationBloc = getIt<NotificationBloc>();
    _notificationBloc.add(const LoadNotificationsEvent());

    // Polling setiap 30 detik sesuai CONTEXT.md & PLAN.md
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _notificationBloc.add(const LoadNotificationsEvent(isSilent: true));
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Saat aplikasi dibuka kembali dari background, polling notifikasi terbaru
    if (state == AppLifecycleState.resumed) {
      _notificationBloc.add(const LoadNotificationsEvent(isSilent: true));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollingTimer?.cancel();
    _notificationBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.user?.role;

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
      const NotificationPage(),
      const SettingsPage(),
    ];

    return BlocProvider.value(
      value: _notificationBloc,
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: pages),
        bottomNavigationBar: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            final unreadCount = state is NotificationLoaded
                ? state.unreadCount
                : 0;

            return NavigationBar(
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
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: unreadCount > 0,
                    label: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                    ),
                    child: const Icon(Icons.notifications_outlined),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: unreadCount > 0,
                    label: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                    ),
                    child: const Icon(Icons.notifications_rounded),
                  ),
                  label: 'Notifikasi',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings_rounded),
                  label: AppStrings.navSettings,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
