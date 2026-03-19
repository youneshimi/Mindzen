import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';

class MindZenDestination {
  const MindZenDestination({
    required this.label,
    required this.path,
    required this.icon,
  });

  final String label;
  final String path;
  final IconData icon;
}

const employeeDestinations = [
  MindZenDestination(
    label: 'Accueil',
    path: '/home',
    icon: Icons.home_outlined,
  ),
  MindZenDestination(
    label: 'Mon check-in',
    path: '/checkin',
    icon: Icons.verified_user_outlined,
  ),
  MindZenDestination(
    label: 'Mes résultats',
    path: '/results',
    icon: Icons.pie_chart_outline,
  ),
  MindZenDestination(
    label: 'Mon historique',
    path: '/history',
    icon: Icons.show_chart,
  ),
  MindZenDestination(
    label: 'Paramètres',
    path: '/settings',
    icon: Icons.settings_outlined,
  ),
];

enum DashboardView { employe, medecin, drh }

class MindZenScaffold extends StatelessWidget {
  const MindZenScaffold({
    required this.location,
    required this.child,
    super.key,
  });

  final String location;
  final Widget child;

  bool get _isEmployeeLocation {
    return employeeDestinations.any(
      (destination) => destination.path == location,
    );
  }

  DashboardView get _view {
    if (location == '/doctor') {
      return DashboardView.medecin;
    }
    if (location == '/hr') {
      return DashboardView.drh;
    }
    return DashboardView.employe;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;

        if (isDesktop) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Row(
              children: [
                _Sidebar(location: location, view: _view),
                Expanded(child: SafeArea(child: child)),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _MobileTopBar(location: location, view: _view),
                Expanded(child: child),
              ],
            ),
          ),
          bottomNavigationBar: _isEmployeeLocation
              ? NavigationBar(
                  selectedIndex: employeeDestinations.indexWhere(
                    (item) => item.path == location,
                  ),
                  destinations: employeeDestinations
                      .map(
                        (item) => NavigationDestination(
                          icon: Icon(item.icon),
                          label: item.label,
                        ),
                      )
                      .toList(),
                  onDestinationSelected: (index) {
                    context.go(employeeDestinations[index].path);
                  },
                )
              : null,
        );
      },
    );
  }
}

class _MobileTopBar extends StatelessWidget {
  const _MobileTopBar({required this.location, required this.view});

  final String location;
  final DashboardView view;

  String get _sectionLabel {
    switch (location) {
      case '/checkin':
        return 'Check-in';
      case '/results':
        return 'Résultats';
      case '/history':
        return 'Historique';
      case '/settings':
        return 'Paramètres';
      case '/doctor':
        return 'Vue Médecin';
      case '/hr':
        return 'Vue DRH';
      case '/home':
      default:
        return 'Accueil';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: const BoxDecoration(
        color: AppColors.cards,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MindZen',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 26,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _sectionLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.go('/login'),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.violetLight,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout, size: 18, color: AppColors.violet),
                    const SizedBox(width: 6),
                    Text(
                      'Changer rôle',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.violet,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.location, required this.view});

  final String location;
  final DashboardView view;

  @override
  Widget build(BuildContext context) {
    final userName = mockUser['name'] as String;
    final userTeam = mockUser['team'] as String;
    final avatar = mockUser['avatar'] as String;

    return Container(
      width: 240,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.cards,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MindZen',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 34,
              height: 1,
              fontStyle: FontStyle.italic,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            '- EMPLOYÉ -',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              letterSpacing: 1,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          ...employeeDestinations.map((destination) {
            final selected = location == destination.path;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _SidebarItem(
                selected: selected,
                icon: destination.icon,
                label: destination.label,
                onTap: () => context.go(destination.path),
              ),
            );
          }),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.go('/login'),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.logout, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Changer rôle',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.violet,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          const Divider(),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.violetLight,
                child: Text(
                  avatar,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: AppColors.violet),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      userTeam,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.violetLight : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? AppColors.violet : AppColors.textSecondary,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: selected ? AppColors.violet : AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
