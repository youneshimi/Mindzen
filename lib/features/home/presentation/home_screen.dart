import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/mindzen_date_formatter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final score = mockUser['score_ce_mois'] as int;
    final previousScore = mockUser['score_mois_precedent'] as int;
    final trend = mockUser['tendance'] as int;
    final surchargeScore = mockCalendar['score_surcharge'] as int;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1060),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(dateText: formatCurrentDate()).animate().fadeIn(),
              const SizedBox(height: 16),
              _ScoreCard(
                    score: score,
                    previousScore: previousScore,
                    trend: trend,
                    zone: mockUser['zone'] as String,
                  )
                  .animate()
                  .fadeIn(delay: 120.ms, duration: 400.ms)
                  .slideY(begin: 0.18, end: 0),
              const SizedBox(height: 16),
              _MetricsRow(trend: trend)
                  .animate()
                  .fadeIn(delay: 220.ms, duration: 400.ms)
                  .slideY(begin: 0.18, end: 0),
              const SizedBox(height: 16),
              const _HistoryCard()
                  .animate()
                  .fadeIn(delay: 320.ms, duration: 400.ms)
                  .slideY(begin: 0.18, end: 0),
              const SizedBox(height: 16),
              if (surchargeScore > 75)
                const _SurchargeBanner()
                    .animate()
                    .fadeIn(delay: 420.ms, duration: 400.ms)
                    .slideY(begin: 0.18, end: 0),
              if (surchargeScore > 75) const SizedBox(height: 16),
              ElevatedButton.icon(
                    onPressed: () => context.go('/checkin'),
                    icon: const Icon(Icons.self_improvement),
                    label: const Text('Mon Moment MindZen 🧘'),
                  )
                  .animate()
                  .fadeIn(delay: 520.ms, duration: 400.ms)
                  .slideY(begin: 0.18, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.dateText});

  final String dateText;

  @override
  Widget build(BuildContext context) {
    final fullName = mockUser['name'] as String;
    final firstName = fullName.split(' ').first;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cards,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Bonjour $firstName 👋',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          const SizedBox(width: 12),
          Text(dateText, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.score,
    required this.previousScore,
    required this.trend,
    required this.zone,
  });

  final int score;
  final int previousScore;
  final int trend;
  final String zone;

  @override
  Widget build(BuildContext context) {
    final color = _zoneColor(zone);
    final trendLabel = trend > 0 ? '+$trend' : '$trend';

    return Container(
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
      child: Wrap(
        spacing: 24,
        runSpacing: 20,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 280,
            height: 280,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: score.toDouble()),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOut,
              builder: (context, animatedScore, child) {
                final progress = (animatedScore / 100).clamp(0.0, 1.0);

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 14,
                        backgroundColor: AppColors.background,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          animatedScore.round().toString(),
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 72,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textPrimary,
                            height: 0.95,
                          ),
                        ),
                        Text(
                          '/100',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zone à risque ce mois',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                _ZoneBadge(zone: zone),
                const SizedBox(height: 16),
                Text(
                  '↓ $trendLabel pts vs mois dernier',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: color),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mois précédent: $previousScore/100',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({required this.trend});

  final int trend;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;
        final cardWidth = isCompact
            ? constraints.maxWidth
            : (constraints.maxWidth - 32) / 3;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _MiniMetricCard(
              width: cardWidth,
              icon: Icons.mic_none,
              title: 'Vocal',
              value: '${mockDimensions['vocal']}/100',
              color: AppColors.riskOrange,
            ),
            _MiniMetricCard(
              width: cardWidth,
              icon: Icons.calendar_today_outlined,
              title: 'Calendrier',
              value: 'Surcharge',
              color: AppColors.riskOrange,
            ),
            _MiniMetricCard(
              width: cardWidth,
              icon: Icons.trending_down,
              title: 'Tendance',
              value: '↓ $trend pts',
              color: AppColors.riskOrange,
            ),
          ],
        );
      },
    );
  }
}

class _MiniMetricCard extends StatelessWidget {
  const _MiniMetricCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final double width;
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard();

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (var i = 0; i < mockHistory.length; i++) {
      spots.add(
        FlSpot(i.toDouble(), (mockHistory[i]['score'] as int).toDouble()),
      );
    }

    return Container(
      height: 330,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Évolution sur 6 mois',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 40,
                maxY: 90,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.textPrimary,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        final month = mockHistory[index]['month'] as String;
                        final score = spot.y.round();
                        return LineTooltipItem(
                          '$month: $score',
                          GoogleFonts.dmSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return const FlLine(
                      color: AppColors.border,
                      strokeWidth: 1,
                    );
                  },
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
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
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
                    color: AppColors.riskOrange,
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
            ),
          ),
        ],
      ),
    );
  }
}

class _SurchargeBanner extends StatelessWidget {
  const _SurchargeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.riskOrangeLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.riskOrange),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt, color: AppColors.riskOrange),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚡ Ta semaine s\'annonce chargée',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF633806),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Check-in rapide disponible →',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF633806),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

Color _scoreColor(int score) {
  if (score > 70) {
    return AppColors.stableGreen;
  }
  if (score >= 50) {
    return AppColors.riskOrange;
  }
  return AppColors.criticalRed;
}
