import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/checkin/presentation/checkin_screen.dart';
import '../features/doctor/presentation/doctor_dashboard_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/hr/presentation/hr_dashboard_screen.dart';
import '../features/results/presentation/results_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/shared/presentation/mindzen_scaffold.dart';

final appRouterProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => MindZenScaffold(
          location: state.uri.path,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: '/checkin',
        builder: (context, state) => MindZenScaffold(
          location: state.uri.path,
          child: const CheckinScreen(),
        ),
      ),
      GoRoute(
        path: '/results',
        builder: (context, state) => MindZenScaffold(
          location: state.uri.path,
          child: const ResultsScreen(),
        ),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => MindZenScaffold(
          location: state.uri.path,
          child: const HistoryScreen(),
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => MindZenScaffold(
          location: state.uri.path,
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/doctor',
        builder: (context, state) => MindZenScaffold(
          location: state.uri.path,
          child: const DoctorDashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/hr',
        builder: (context, state) => MindZenScaffold(
          location: state.uri.path,
          child: const HrDashboardScreen(),
        ),
      ),
    ],
  ),
);
