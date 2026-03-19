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
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: _GlowCircle(
              size: 300,
              color: AppColors.violet.withValues(alpha: 0.14),
            ),
          ),
          Positioned(
            bottom: -110,
            right: -70,
            child: _GlowCircle(
              size: 260,
              color: AppColors.stableGreen.withValues(alpha: 0.12),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cards,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          'Prototype interactif',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.violet,
                              ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'MindZen',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 56,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w400,
                          height: 0.95,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Plateforme de bien-etre en entreprise',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppColors.cards,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.border),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.06),
                              blurRadius: 18,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selectionnez votre role',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Choisissez votre espace pour continuer.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 18),
                            _RoleButton(
                              title: 'Employe',
                              description:
                                  'Accedez a votre bien-etre personnel',
                              icon: Icons.person,
                              accent: AppColors.violet,
                              onPressed: () async {
                                ref.read(currentRoleProvider.notifier).state =
                                    UserRole.employe;
                                if (context.mounted) context.go('/home');
                              },
                            ),
                            const SizedBox(height: 12),
                            _RoleButton(
                              title: 'Medecin',
                              description:
                                  'Suivez les signaux collectifs equipes',
                              icon: Icons.local_hospital,
                              accent: AppColors.stableGreen,
                              onPressed: () async {
                                ref.read(currentRoleProvider.notifier).state =
                                    UserRole.medecin;
                                if (context.mounted) context.go('/doctor');
                              },
                            ),
                            const SizedBox(height: 12),
                            _RoleButton(
                              title: 'Responsable RH',
                              description:
                                  'Pilotez les indicateurs organisation',
                              icon: Icons.badge,
                              accent: AppColors.riskOrange,
                              onPressed: () async {
                                ref.read(currentRoleProvider.notifier).state =
                                    UserRole.drh;
                                if (context.mounted) context.go('/hr');
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        '2026 MindZen · Prototype confidentiel',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    required this.onPressed,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: accent.withValues(alpha: 0.24),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Row(
            children: [
              // Role icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: accent),
              ),
              const SizedBox(width: 14),
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
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_forward, size: 18, color: accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
