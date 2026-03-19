import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/dynamic_analysis_service.dart';

/// État de l'analyse générée
class GeneratedAnalysisState {
  const GeneratedAnalysisState({
    required this.score,
    required this.previousScore,
    required this.zone,
    required this.tendance,
    required this.dimensions,
    required this.aiResponse,
    required this.recommendations,
  });

  final int score;
  final int previousScore;
  final String zone;
  final int tendance;
  final Map<String, int> dimensions; // {vocal, facial, calendrier}
  final String aiResponse;
  final List<String> recommendations;

  factory GeneratedAnalysisState.fromDynamic(Map<String, dynamic> data) {
    return GeneratedAnalysisState(
      score: data['score_ce_mois'] as int? ?? 62,
      previousScore: data['score_mois_precedent'] as int? ?? 74,
      zone: data['zone'] as String? ?? 'orange',
      tendance: data['tendance'] as int? ?? -12,
      dimensions: {
        'vocal': data['vocal'] as int? ?? 58,
        'facial': data['facial'] as int? ?? 65,
        'calendrier': data['calendrier'] as int? ?? 55,
        'tendance': data['tendance'] as int? ?? 70,
      },
      aiResponse:
          data['ai_response'] as String? ??
          'Ta session d\'analyse a été complétée avec succès.',
      recommendations: List<String>.from(
        data['recommendations'] as List<dynamic>? ?? [],
      ),
    );
  }
}

/// Provider pour stocker l'analyse générée
final generatedAnalysisProvider =
    StateNotifierProvider<GeneratedAnalysisNotifier, GeneratedAnalysisState?>(
      (ref) => GeneratedAnalysisNotifier(),
    );

class GeneratedAnalysisNotifier extends StateNotifier<GeneratedAnalysisState?> {
  GeneratedAnalysisNotifier() : super(null);

  /// Génère une nouvelle analyse et met à jour l'état
  void generateNewAnalysis({int? facialScore}) {
    final analysisData = DynamicAnalysisService.generateAnalysis(
      facialScore: facialScore,
    );
    state = GeneratedAnalysisState.fromDynamic(analysisData);
  }

  /// Réinitialise l'analyse
  void reset() {
    state = null;
  }
}
