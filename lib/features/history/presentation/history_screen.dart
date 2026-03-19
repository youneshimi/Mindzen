import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1060),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mon historique',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 14),
                    const SizedBox(height: 320, child: _HistoryLineChart()),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.07, end: 0),
              const SizedBox(height: 16),
              const _Card(
                child: _HistoryRadarSection(),
              ).animate(delay: 120.ms).fadeIn().slideY(begin: 0.07, end: 0),
              const SizedBox(height: 16),
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Liste des check-ins',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    ..._historyListItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _HistoryListTile(item: item),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 240.ms).fadeIn().slideY(begin: 0.07, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

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

class _HistoryLineChart extends StatelessWidget {
  const _HistoryLineChart();

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (var i = 0; i < mockHistory.length; i++) {
      spots.add(
        FlSpot(i.toDouble(), (mockHistory[i]['score'] as int).toDouble()),
      );
    }

    return LineChart(
      LineChartData(
        minY: 40,
        maxY: 90,
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.textPrimary,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                final month = _monthLongLabel(index);
                final score = spot.y.round();
                return LineTooltipItem(
                  '$month : $score/100',
                  Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList();
            },
          ),
        ),
        rangeAnnotations: RangeAnnotations(
          horizontalRangeAnnotations: [
            HorizontalRangeAnnotation(
              y1: 70,
              y2: 90,
              color: AppColors.stableGreenLight.withValues(alpha: 0.45),
            ),
            HorizontalRangeAnnotation(
              y1: 50,
              y2: 70,
              color: AppColors.riskOrangeLight.withValues(alpha: 0.45),
            ),
            HorizontalRangeAnnotation(
              y1: 40,
              y2: 50,
              color: AppColors.criticalRedLight.withValues(alpha: 0.45),
            ),
          ],
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.border, strokeWidth: 1),
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
              reservedSize: 38,
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
                final index = value.toInt();
                if (index < 0 || index >= mockHistory.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    mockHistory[index]['month'] as String,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppColors.border),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.28,
            barWidth: 4,
            color: AppColors.violet,
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final color = _scoreColor(spot.y.toInt());
                return FlDotCirclePainter(
                  radius: 4,
                  color: color,
                  strokeColor: Colors.white,
                  strokeWidth: 2,
                );
              },
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOut,
    );
  }
}

class _HistoryRadarSection extends StatelessWidget {
  const _HistoryRadarSection();

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
                  fillColor: AppColors.riskOrange.withValues(alpha: 0.23),
                  borderColor: AppColors.riskOrange,
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
                    return const RadarChartTitle(text: 'Vocal');
                  case 1:
                    return const RadarChartTitle(text: 'Facial');
                  case 2:
                    return const RadarChartTitle(text: 'Calendrier');
                  case 3:
                    return const RadarChartTitle(text: 'Tendance');
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

class _HistoryListTile extends StatelessWidget {
  const _HistoryListTile({required this.item});

  final _HistoryItem item;

  @override
  Widget build(BuildContext context) {
    final zoneStyle = _zoneStyle(item.zone);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cards,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.label,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Text('${item.score}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: zoneStyle.background,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: zoneStyle.border),
            ),
            child: Text(
              zoneStyle.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: zoneStyle.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem {
  const _HistoryItem({
    required this.label,
    required this.score,
    required this.zone,
  });

  final String label;
  final int score;
  final String zone;
}

const _historyListItems = [
  _HistoryItem(label: 'Janvier 2026', score: 62, zone: 'orange'),
  _HistoryItem(label: 'Décembre 2025', score: 71, zone: 'orange'),
  _HistoryItem(label: 'Novembre 2025', score: 68, zone: 'orange'),
  _HistoryItem(label: 'Octobre 2025', score: 74, zone: 'vert'),
  _HistoryItem(label: 'Septembre 2025', score: 76, zone: 'vert'),
  _HistoryItem(label: 'Août 2025', score: 81, zone: 'vert'),
];

String _monthLongLabel(int index) {
  switch (index) {
    case 0:
      return 'Août 2025';
    case 1:
      return 'Septembre 2025';
    case 2:
      return 'Octobre 2025';
    case 3:
      return 'Novembre 2025';
    case 4:
      return 'Décembre 2025';
    case 5:
      return 'Janvier 2026';
    default:
      return '';
  }
}

Color _scoreColor(int score) {
  if (score > 70) {
    return AppColors.stableGreen;
  }
  if (score >= 50) {
    return AppColors.riskOrange;
  }
  return AppColors.criticalRed;
}

class _ZoneStyle {
  const _ZoneStyle({
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

_ZoneStyle _zoneStyle(String zone) {
  switch (zone) {
    case 'vert':
      return const _ZoneStyle(
        label: 'vert',
        background: AppColors.stableGreenLight,
        text: Color(0xFF085041),
        border: AppColors.stableGreen,
      );
    case 'rouge':
      return const _ZoneStyle(
        label: 'rouge',
        background: AppColors.criticalRedLight,
        text: Color(0xFF712B13),
        border: AppColors.criticalRed,
      );
    case 'orange':
    default:
      return const _ZoneStyle(
        label: 'orange',
        background: AppColors.riskOrangeLight,
        text: Color(0xFF633806),
        border: AppColors.riskOrange,
      );
  }
}
