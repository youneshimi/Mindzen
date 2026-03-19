import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final totalEmployes = mockMedecin['total_employes'] as int;
    final zoneVert = mockMedecin['zone_vert'] as int;
    final zoneOrange = mockMedecin['zone_orange'] as int;
    final zoneRouge = mockMedecin['zone_rouge'] as int;
    final alertes = (mockMedecin['alertes'] as List<dynamic>).cast<String>();
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
              _DoctorCard(
                child: Text(
                  'Dr. Martin — Corsica Tech ($totalEmployes employés)',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ).animate().fadeIn().slideY(begin: 0.07, end: 0),
              const SizedBox(height: 16),
              _DoctorCard(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _StatPill(
                      icon: '✅',
                      label: '$zoneVert stables',
                      background: AppColors.stableGreenLight,
                      textColor: const Color(0xFF085041),
                      borderColor: AppColors.stableGreen,
                    ),
                    _StatPill(
                      icon: '⚠️',
                      label: '$zoneOrange à risque',
                      background: AppColors.riskOrangeLight,
                      textColor: const Color(0xFF633806),
                      borderColor: AppColors.riskOrange,
                    ),
                    _StatPill(
                      icon: '🔴',
                      label: '$zoneRouge critiques',
                      background: AppColors.criticalRedLight,
                      textColor: const Color(0xFF712B13),
                      borderColor: AppColors.criticalRed,
                    ),
                  ],
                ),
              ).animate(delay: 120.ms).fadeIn().slideY(begin: 0.07, end: 0),
              const SizedBox(height: 16),
              _DoctorCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Répartition des zones',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    const SizedBox(height: 280, child: _DoctorDonutChart()),
                  ],
                ),
              ).animate(delay: 220.ms).fadeIn().slideY(begin: 0.07, end: 0),
              const SizedBox(height: 16),
              _DoctorCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ Alertes ce mois',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    _AlertCard(
                      text: alertes[0],
                      background: AppColors.criticalRedLight,
                      border: AppColors.criticalRed,
                      textColor: const Color(0xFF712B13),
                    ),
                    const SizedBox(height: 10),
                    _AlertCard(
                      text: alertes[1],
                      background: AppColors.riskOrangeLight,
                      border: AppColors.riskOrange,
                      textColor: const Color(0xFF633806),
                    ),
                  ],
                ),
              ).animate(delay: 320.ms).fadeIn().slideY(begin: 0.07, end: 0),
              const SizedBox(height: 16),
              _DoctorCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tableau équipes',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    _TeamsTable(equipes: equipes),
                    const SizedBox(height: 12),
                    Text(
                      '⚠️ JAMAIS de noms individuels',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '⚠️ Uniquement par équipe',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 420.ms).fadeIn().slideY(begin: 0.07, end: 0),
              const SizedBox(height: 16),
              _DoctorCard(
                child: Text(
                  'Conformité RGPD — Aucune donnée individuelle identifiable n\'est transmise.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ).animate(delay: 520.ms).fadeIn().slideY(begin: 0.07, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.child});

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

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.background,
    required this.textColor,
    required this.borderColor,
  });

  final String icon;
  final String label;
  final Color background;
  final Color textColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorDonutChart extends StatelessWidget {
  const _DoctorDonutChart();

  @override
  Widget build(BuildContext context) {
    final zoneVert = mockMedecin['zone_vert'] as int;
    final zoneOrange = mockMedecin['zone_orange'] as int;
    final zoneRouge = mockMedecin['zone_rouge'] as int;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final chart = SizedBox(
          width: 220,
          height: 220,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 58,
              sectionsSpace: 2,
              sections: [
                PieChartSectionData(
                  value: zoneVert.toDouble(),
                  color: AppColors.stableGreen,
                  radius: 46,
                  title: '',
                ),
                PieChartSectionData(
                  value: zoneOrange.toDouble(),
                  color: AppColors.riskOrange,
                  radius: 46,
                  title: '',
                ),
                PieChartSectionData(
                  value: zoneRouge.toDouble(),
                  color: AppColors.criticalRed,
                  radius: 46,
                  title: '',
                ),
              ],
            ),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOut,
          ),
        );

        final legend = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LegendItem(
              color: AppColors.stableGreen,
              label: 'Vert',
              value: zoneVert,
            ),
            const SizedBox(height: 8),
            _LegendItem(
              color: AppColors.riskOrange,
              label: 'Orange',
              value: zoneOrange,
            ),
            const SizedBox(height: 8),
            _LegendItem(
              color: AppColors.criticalRed,
              label: 'Rouge',
              value: zoneRouge,
            ),
          ],
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: chart),
              const SizedBox(height: 16),
              legend,
            ],
          );
        }

        return Row(children: [chart, const SizedBox(width: 24), legend]);
      },
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text('$label : $value', style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.text,
    required this.background,
    required this.border,
    required this.textColor,
  });

  final String text;
  final Color background;
  final Color border;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 10,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton.tonal(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.cards,
              foregroundColor: AppColors.textPrimary,
            ),
            child: const Text('Planifier atelier'),
          ),
        ],
      ),
    );
  }
}

class _TeamsTable extends StatelessWidget {
  const _TeamsTable({required this.equipes});

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
          DataColumn(label: Text('Action')),
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
              DataCell(
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    foregroundColor: AppColors.textPrimary,
                  ),
                  child: const Text('Contacter'),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

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
