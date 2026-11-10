import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campusfix/core/routes/app_router.dart';
import 'package:campusfix/core/theme/app_colors.dart';
import 'package:campusfix/providers/session_provider.dart';
import 'package:campusfix/screens/incidents/my_reports_screen.dart';
import 'package:campusfix/screens/incidents/reports_screen.dart';
import 'package:campusfix/screens/profile/profile_screen.dart';
import 'package:campusfix/screens/staff/staff_dashboard_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final isStaff = context.select<SessionProvider, bool>((s) => s.isStaff);

    final pages = isStaff
        ? [
            StaffDashboardScreen(onViewAll: () => _select(1)),
            const ReportsScreen(title: 'All Reports'),
            const ProfileScreen(),
          ]
        : const [
            ReportsScreen(title: 'Campus Reports'),
            MyReportsScreen(),
            ProfileScreen(),
          ];

    final destinations = isStaff
        ? const [
            NavigationDestination(
              icon: Icon(Icons.space_dashboard_outlined),
              selectedIcon: Icon(Icons.space_dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: 'Reports',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ]
        : const [
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Campus',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment),
              label: 'My Reports',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ];

    final index = _index.clamp(0, pages.length - 1);
    final showFab = !isStaff && index < 2;

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      floatingActionButton: showFab
          ? FloatingActionButton.extended(
              heroTag: 'report-fab',
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.createIncident),
              icon: const Icon(Icons.add),
              label: const Text(
                'Report issue',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          : null,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: _select,
          destinations: destinations,
        ),
      ),
    );
  }
}
