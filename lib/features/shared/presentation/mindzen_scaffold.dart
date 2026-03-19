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

const doctorDestinations = [
  MindZenDestination(
    label: 'Vue medecin',
    path: '/doctor',
    icon: Icons.local_hospital_outlined,
  ),
];

const hrDestinations = [
  MindZenDestination(
    label: 'Vue DRH',
    path: '/hr',
    icon: Icons.business_center_outlined,
  ),
];

enum DashboardView { employe, medecin, drh }

String _viewLabel(DashboardView view) {
  switch (view) {
    case DashboardView.employe:
      return 'Employe';
    case DashboardView.medecin:
      return 'Medecin';
    case DashboardView.drh:
      return 'DRH';
  }
}

IconData _viewIcon(DashboardView view) {
  switch (view) {
    case DashboardView.employe:
      return Icons.person_outline;
    case DashboardView.medecin:
      return Icons.local_hospital_outlined;
    case DashboardView.drh:
      return Icons.business_center_outlined;
  }
}

List<MindZenDestination> _destinationsForView(DashboardView view) {
  switch (view) {
    case DashboardView.employe:
      return employeeDestinations;
    case DashboardView.medecin:
      return doctorDestinations;
    case DashboardView.drh:
      return hrDestinations;
  }
}

class _RoleVisual {
  const _RoleVisual({
    required this.accent,
    required this.accentLight,
    required this.bgTint,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final Color accent;
  final Color accentLight;
  final Color bgTint;
  final IconData icon;
  final String title;
  final String subtitle;
}

_RoleVisual _roleVisual(DashboardView view) {
  switch (view) {
    case DashboardView.medecin:
      return const _RoleVisual(
        accent: AppColors.stableGreen,
        accentLight: AppColors.stableGreenLight,
        bgTint: Color(0xFFEAF7F2),
        icon: Icons.local_hospital,
        title: 'Espace Medecin',
        subtitle: 'Vision clinique collective et prevention des risques.',
      );
    case DashboardView.drh:
      return const _RoleVisual(
        accent: AppColors.riskOrange,
        accentLight: AppColors.riskOrangeLight,
        bgTint: Color(0xFFFFF6E8),
        icon: Icons.business_center,
        title: 'Espace DRH',
        subtitle: 'Pilotage global, ROI social et decisions responsables.',
      );
    case DashboardView.employe:
      return const _RoleVisual(
        accent: AppColors.violet,
        accentLight: AppColors.violetLight,
        bgTint: Color(0xFFF1EEFF),
        icon: Icons.self_improvement,
        title: 'Espace Employe',
        subtitle: 'Suivi personnel du bien-etre et des habitudes de travail.',
      );
  }
}

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
    final visual = _roleVisual(_view);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;

        if (isDesktop) {
          return Scaffold(
            backgroundColor: visual.bgTint,
            body: Row(
              children: [
                _Sidebar(location: location, view: _view, visual: visual),
                Expanded(
                  child: SafeArea(
                    child: _RoleContentFrame(
                      view: _view,
                      visual: visual,
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: visual.bgTint,
          body: SafeArea(
            child: Column(
              children: [
                _MobileTopBar(location: location, view: _view, visual: visual),
                Expanded(
                  child: _RoleContentFrame(
                    view: _view,
                    visual: visual,
                    child: child,
                    compact: true,
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _isEmployeeLocation
              ? NavigationBar(
                  height: 70,
                  indicatorColor: visual.accentLight,
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

class _RoleContentFrame extends StatelessWidget {
  const _RoleContentFrame({
    required this.view,
    required this.visual,
    required this.child,
    this.compact = false,
  });

  final DashboardView view;
  final _RoleVisual visual;
  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [visual.bgTint, AppColors.background],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 12 : 18,
              compact ? 10 : 14,
              compact ? 12 : 18,
              0,
            ),
            child: _RoleBanner(view: view, visual: visual),
          ),
          const SizedBox(height: 6),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _RoleBanner extends StatelessWidget {
  const _RoleBanner({required this.view, required this.visual});

  final DashboardView view;
  final _RoleVisual visual;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cards,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: visual.accent.withValues(alpha: 0.30)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 10,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: visual.accentLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(visual.icon, size: 20, color: visual.accent),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visual.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: visual.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    visual.subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: visual.accentLight,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Mode ${_viewLabel(view)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: visual.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileTopBar extends StatelessWidget {
  const _MobileTopBar({
    required this.location,
    required this.view,
    required this.visual,
  });

  final String location;
  final DashboardView view;
  final _RoleVisual visual;

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
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_viewIcon(view), size: 14, color: visual.accent),
                      const SizedBox(width: 6),
                      Text(
                        _viewLabel(view),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: visual.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
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
                  color: visual.accentLight,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout, size: 18, color: visual.accent),
                    const SizedBox(width: 6),
                    Text(
                      'Changer rôle',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: visual.accent,
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
  const _Sidebar({
    required this.location,
    required this.view,
    required this.visual,
  });

  final String location;
  final DashboardView view;
  final _RoleVisual visual;

  @override
  Widget build(BuildContext context) {
    final userName = switch (view) {
      DashboardView.employe => mockUser['name'] as String,
      DashboardView.medecin => 'Dr. Martin',
      DashboardView.drh => 'Direction RH',
    };
    final userTeam = switch (view) {
      DashboardView.employe => mockUser['team'] as String,
      DashboardView.medecin => 'Sante au travail',
      DashboardView.drh => 'Gouvernance bien-etre',
    };
    final avatar = switch (view) {
      DashboardView.employe => mockUser['avatar'] as String,
      DashboardView.medecin => 'M',
      DashboardView.drh => 'RH',
    };

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
            '- ${_viewLabel(view).toUpperCase()} -',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              letterSpacing: 1,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_viewIcon(view), size: 16, color: visual.accent),
                const SizedBox(width: 8),
                Text(
                  'Vue ${_viewLabel(view)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: visual.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ..._destinationsForView(view).map((destination) {
            final selected = location == destination.path;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _SidebarItem(
                selected: selected,
                icon: destination.icon,
                label: destination.label,
                visual: visual,
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
                          color: visual.accent,
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
                  ).textTheme.titleMedium?.copyWith(color: visual.accent),
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
    required this.visual,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final _RoleVisual visual;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? visual.accentLight : Colors.transparent,
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
                color: selected ? visual.accent : AppColors.textSecondary,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: selected ? visual.accent : AppColors.textPrimary,
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
