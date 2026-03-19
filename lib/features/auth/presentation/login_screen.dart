import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/providers/role_provider.dart';
import '../../../core/theme/app_colors.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 40.0,
                ),
                child: Column(
                  children: [
                    // Logo / Title
                    Text(
                      'MindZen',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 48,
                        fontStyle: FontStyle.italic,
                        color: AppColors.violet,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Plateforme de bien-être en entreprise',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Instructions
                    Text(
                      'Sélectionnez votre rôle',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 32,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Employee Button
                    _RoleButton(
                      title: 'Employé',
                      description: 'Accédez à votre bien-être',
                      icon: Icons.person,
                      onPressed: () async {
                        ref.read(currentRoleProvider.notifier).state =
                            UserRole.employe;
                        if (context.mounted) context.go('/home');
                      },
                    ),
                    const SizedBox(height: 16),

                    // Doctor Button
                    _RoleButton(
                      title: 'Médecin',
                      description: 'Suivez vos équipes',
                      icon: Icons.local_hospital,
                      onPressed: () async {
                        ref.read(currentRoleProvider.notifier).state =
                            UserRole.medecin;
                        if (context.mounted) context.go('/doctor');
                      },
                    ),
                    const SizedBox(height: 16),

                    // HR Button
                    _RoleButton(
                      title: 'Responsable RH',
                      description: 'Pilotez le bien-être global',
                      icon: Icons.badge,
                      onPressed: () async {
                        ref.read(currentRoleProvider.notifier).state =
                            UserRole.drh;
                        if (context.mounted) context.go('/hr');
                      },
                    ),
                    const SizedBox(height: 60),

                    // Footer
                    Text(
                      '© 2026 MindZen — Prototype Confidential',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.title,
    required this.description,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.violet.withValues(alpha: 0.3),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
            color: AppColors.violetLight.withValues(alpha: 0.5),
          ),
          child: Row(
            children: [
              // Role icon
              Icon(icon, size: 34, color: AppColors.violet),
              const SizedBox(width: 20),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow
              Icon(Icons.arrow_forward_ios, size: 20, color: AppColors.violet),
            ],
          ),
        ),
      ),
    );
  }
}
