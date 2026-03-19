import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _shareWithDoctor = false;

  @override
  Widget build(BuildContext context) {
    final score = mockUser['score_ce_mois'] as int;
    final zone = mockUser['zone'] as String;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1060),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MainCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vos résultats de janvier',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 24,
                      runSpacing: 16,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _AnimatedScore(score: score, zone: zone),
                        _ZoneBadge(zone: zone),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.08, end: 0),
              const SizedBox(height: 16),
              const _MainCard(
                child: _RadarSection(),
              ).animate(delay: 120.ms).fadeIn().slideY(begin: 0.08, end: 0),
              const SizedBox(height: 16),
              _MainCard(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.violetLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🧠 '),
                      Expanded(
                        child: Text(
                          mockAIResponse,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: 220.ms).fadeIn().slideY(begin: 0.08, end: 0),
              const SizedBox(height: 16),
              _MainCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '3 recommandations pour ce mois',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 14),
                    ...mockRecommandations.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.cards,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            item,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 320.ms).fadeIn().slideY(begin: 0.08, end: 0),
              const SizedBox(height: 16),
              _MainCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile.adaptive(
                      value: _shareWithDoctor,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Partager avec le médecin'),
                      activeTrackColor: AppColors.stableGreenLight,
                      activeThumbColor: AppColors.stableGreen,
                      onChanged: (value) {
                        setState(() {
                          _shareWithDoctor = value;
                        });
                      },
                    ),
                    if (_shareWithDoctor)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.stableGreenLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.stableGreen),
                        ),
                        child: Text(
                          'Le médecin verra uniquement le score de votre équipe. Jamais votre nom.',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: const Color(0xFF085041)),
                        ),
                      ),
                  ],
                ),
              ).animate(delay: 420.ms).fadeIn().slideY(begin: 0.08, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _MainCard extends StatelessWidget {
  const _MainCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cards,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AnimatedScore extends StatelessWidget {
  const _AnimatedScore({required this.score, required this.zone});

  final int score;
  final String zone;

  @override
  Widget build(BuildContext context) {
    final color = _zoneColor(zone);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: score.toDouble()),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.easeOut,
        builder: (context, value, _) {
          return Text.rich(
            TextSpan(
              text: '${value.round()}',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 72,
                fontStyle: FontStyle.italic,
                color: color,
                height: 0.95,
              ),
              children: [
                TextSpan(
                  text: '/100',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RadarSection extends StatelessWidget {
  const _RadarSection();

  @override
  Widget build(BuildContext context) {
    final entries = [
      RadarEntry(value: (mockDimensions['vocal'] as int).toDouble()),
      RadarEntry(value: (mockDimensions['facial'] as int).toDouble()),
      RadarEntry(value: (mockDimensions['calendrier'] as int).toDouble()),
      RadarEntry(value: (mockDimensions['tendance'] as int).toDouble()),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Radar des dimensions',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 290,
          child: RadarChart(
            RadarChartData(
              dataSets: [
                RadarDataSet(
                  fillColor: AppColors.violet.withValues(alpha: 0.24),
                  borderColor: AppColors.violet,
                  entryRadius: 3,
                  borderWidth: 2,
                  dataEntries: entries,
                ),
              ],
              radarBackgroundColor: Colors.transparent,
              radarBorderData: const BorderSide(color: AppColors.border),
              tickCount: 5,
              ticksTextStyle: Theme.of(context).textTheme.bodySmall!,
              tickBorderData: const BorderSide(color: AppColors.border),
              gridBorderData: const BorderSide(color: AppColors.border),
              titleTextStyle: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
              titlePositionPercentageOffset: 0.18,
              getTitle: (index, angle) {
                switch (index) {
                  case 0:
                    return const RadarChartTitle(text: 'Vocal (58)');
                  case 1:
                    return const RadarChartTitle(text: 'Facial (65)');
                  case 2:
                    return const RadarChartTitle(text: 'Calen (55)');
                  case 3:
                    return const RadarChartTitle(text: 'Tend (70)');
                  default:
                    return const RadarChartTitle(text: '');
                }
              },
            ),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOut,
          ),
        ),
      ],
    );
  }
}

class _ZoneBadge extends StatelessWidget {
  const _ZoneBadge({required this.zone});

  final String zone;

  @override
  Widget build(BuildContext context) {
    final style = _zoneBadgeStyle(zone);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: style.border),
      ),
      child: Text(
        style.label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: style.text,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ZoneBadgeStyle {
  const _ZoneBadgeStyle({
    required this.label,
    required this.background,
    required this.text,
    required this.border,
  });

  final String label;
  final Color background;
  final Color text;
  final Color border;
}

_ZoneBadgeStyle _zoneBadgeStyle(String zone) {
  switch (zone) {
    case 'vert':
      return const _ZoneBadgeStyle(
        label: 'Zone stable',
        background: AppColors.stableGreenLight,
        text: Color(0xFF085041),
        border: AppColors.stableGreen,
      );
    case 'rouge':
      return const _ZoneBadgeStyle(
        label: 'Zone critique',
        background: AppColors.criticalRedLight,
        text: Color(0xFF712B13),
        border: AppColors.criticalRed,
      );
    case 'orange':
    default:
      return const _ZoneBadgeStyle(
        label: 'Zone à risque',
        background: AppColors.riskOrangeLight,
        text: Color(0xFF633806),
        border: AppColors.riskOrange,
      );
  }
}

Color _zoneColor(String zone) {
  switch (zone) {
    case 'vert':
      return AppColors.stableGreen;
    case 'rouge':
      return AppColors.criticalRed;
    case 'orange':
    default:
      return AppColors.riskOrange;
  }
}
