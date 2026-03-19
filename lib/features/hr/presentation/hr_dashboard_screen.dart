import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';

class HrDashboardScreen extends StatelessWidget {
  const HrDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scoreGlobal = mockEntreprise['score_global'] as int;
    final burnoutsEvites = mockEntreprise['burnouts_evites'] as int;
    final roiEuros = mockEntreprise['roi_euros'] as int;
    final recommandations = (mockEntreprise['recommandations'] as List<dynamic>)
        .cast<String>();
    final equipes = (mockMedecin['equipes'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1060),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HrCard(
                child: Text(
                  'Tableau de bord bien-être — Corsica Tech',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ).animate().fadeIn().slideY(begin: 0.07, end: 0),
              const SizedBox(height: 16),
              _HrCard(
                child: Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _GlobalScoreCircle(score: scoreGlobal),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.riskOrangeLight,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.riskOrange),
                      ),
                      child: Text(
                        'Zone à surveiller',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF633806),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 120.ms).fadeIn().slideY(begin: 0.07, end: 0),
              const SizedBox(height: 16),
              _HrCard(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.stableGreenLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.stableGreen),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💰 $burnoutsEvites burn-outs potentiels évités',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: const Color(0xFF085041),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Économie estimée : ${_formatEuros(roiEuros)} €',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF085041),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: 220.ms).fadeIn().slideY(begin: 0.07, end: 0),
              const SizedBox(height: 16),
              const _HrCard(
                child: _HrBarSection(),
              ).animate(delay: 320.ms).fadeIn().slideY(begin: 0.07, end: 0),
              const SizedBox(height: 16),
              _HrCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tableau équipes',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    _HrTeamsTable(equipes: equipes),
                  ],
                ),
              ).animate(delay: 420.ms).fadeIn().slideY(begin: 0.07, end: 0),
              const SizedBox(height: 16),
              _HrCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 Recommandations IA',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    ...recommandations.map(
                      (reco) => Padding(
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
                            reco,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 520.ms).fadeIn().slideY(begin: 0.07, end: 0),
              const SizedBox(height: 16),
              _HrCard(
                child: Text(
                  'MindZen ne peut jamais être utilisé comme base de décision RH individuelle.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ).animate(delay: 620.ms).fadeIn().slideY(begin: 0.07, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _HrCard extends StatelessWidget {
  const _HrCard({required this.child});

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

class _GlobalScoreCircle extends StatelessWidget {
  const _GlobalScoreCircle({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: score.toDouble()),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.easeOut,
        builder: (context, animatedScore, _) {
          final progress = (animatedScore / 100).clamp(0.0, 1.0);
          return Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 210,
                height: 210,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 14,
                  backgroundColor: AppColors.background,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.riskOrange,
                  ),
                ),
              ),
              Text(
                '${animatedScore.round()}/100',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HrBarSection extends StatelessWidget {
  const _HrBarSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bar Chart 3 derniers mois par équipe',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Moyenne globale : Nov (72) · Déc (70) · Jan (68)',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 320,
          child: BarChart(
            BarChartData(
              minY: 40,
              maxY: 90,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) =>
                    const FlLine(color: AppColors.border, strokeWidth: 1),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: AppColors.border),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (value, _) => Text(
                      value.toInt().toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final i = value.toInt();
                      if (i < 0 || i >= _teamTrendData.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _teamTrendData[i].short,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: List.generate(_teamTrendData.length, (index) {
                final item = _teamTrendData[index];
                return BarChartGroupData(
                  x: index,
                  barsSpace: 3,
                  barRods: [
                    BarChartRodData(
                      toY: item.nov.toDouble(),
                      width: 8,
                      color: AppColors.stableGreen,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    BarChartRodData(
                      toY: item.dec.toDouble(),
                      width: 8,
                      color: AppColors.riskOrange,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    BarChartRodData(
                      toY: item.jan.toDouble(),
                      width: 8,
                      color: AppColors.violet,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                );
              }),
            ),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOut,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          children: const [
            _LegendDot(color: AppColors.stableGreen, label: 'Nov'),
            _LegendDot(color: AppColors.riskOrange, label: 'Déc'),
            _LegendDot(color: AppColors.violet, label: 'Jan'),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _HrTeamsTable extends StatelessWidget {
  const _HrTeamsTable({required this.equipes});

  final List<Map<String, dynamic>> equipes;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.resolveWith(
          (states) => AppColors.background,
        ),
        columnSpacing: 24,
        columns: const [
          DataColumn(label: Text('Équipe')),
          DataColumn(label: Text('Score')),
          DataColumn(label: Text('Zone')),
          DataColumn(label: Text('Tendance')),
        ],
        rows: equipes.map((equipe) {
          final zone = equipe['zone'] as String;
          final style = _zoneStyle(zone);

          return DataRow(
            cells: [
              DataCell(Text(equipe['nom'] as String)),
              DataCell(Text('${equipe['score']}')),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: style.background,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: style.border),
                  ),
                  child: Text(
                    '${style.icon}${style.label}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: style.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              DataCell(Text(equipe['tendance'] as String)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _TeamTrend {
  const _TeamTrend({
    required this.short,
    required this.nov,
    required this.dec,
    required this.jan,
  });

  final String short;
  final int nov;
  final int dec;
  final int jan;
}

const _teamTrendData = [
  _TeamTrend(short: 'Mkg', nov: 66, dec: 61, jan: 58),
  _TeamTrend(short: 'IT', nov: 70, dec: 67, jan: 64),
  _TeamTrend(short: 'RH', nov: 80, dec: 79, jan: 79),
  _TeamTrend(short: 'Fin', nov: 84, dec: 83, jan: 82),
  _TeamTrend(short: 'Com', nov: 65, dec: 63, jan: 61),
];

class _ZoneStyle {
  const _ZoneStyle({
    required this.icon,
    required this.label,
    required this.background,
    required this.text,
    required this.border,
  });

  final String icon;
  final String label;
  final Color background;
  final Color text;
  final Color border;
}

_ZoneStyle _zoneStyle(String zone) {
  switch (zone) {
    case 'vert':
      return const _ZoneStyle(
        icon: '🟢',
        label: 'vert',
        background: AppColors.stableGreenLight,
        text: Color(0xFF085041),
        border: AppColors.stableGreen,
      );
    case 'rouge':
      return const _ZoneStyle(
        icon: '🔴',
        label: 'rouge',
        background: AppColors.criticalRedLight,
        text: Color(0xFF712B13),
        border: AppColors.criticalRed,
      );
    case 'orange':
    default:
      return const _ZoneStyle(
        icon: '🟡',
        label: 'orange',
        background: AppColors.riskOrangeLight,
        text: Color(0xFF633806),
        border: AppColors.riskOrange,
      );
  }
}

String _formatEuros(int value) {
  final raw = value.toString();
  if (raw.length <= 3) {
    return raw;
  }
  final head = raw.substring(0, raw.length - 3);
  final tail = raw.substring(raw.length - 3);
  return '$head $tail';
}
