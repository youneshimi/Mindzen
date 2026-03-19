import 'dart:math' as math;

/// Service qui génère des scores d'analyse dynamiques et réalistes
class DynamicAnalysisService {
  static final _random = math.Random();

  /// Génère une analyse complète avec résultats aléatoires mais cohérents
  static Map<String, dynamic> generateAnalysis({
    /// Score facial détecté (0-100, optionnel pour variation)
    int? facialScore,
  }) {
    // Base des scores avec variation naturelle
    final generatedFacial = facialScore ?? (_random.nextInt(25) + 55); // 55-80
    final vocal = (_random.nextInt(25) + 50).clamp(45, 85); // 50-75
    final calendrier = (_random.nextInt(30) + 45).clamp(40, 80); // 45-75
    final tendance = (_random.nextInt(40) - 15).clamp(-25, 25); // -15 à +15

    // Score global = moyenne pondérée
    final globalScore =
        ((generatedFacial * 0.35 + // Facial le plus important
                vocal * 0.30 +
                calendrier * 0.35))
            .round()
            .clamp(45, 95);

    // Zone basée sur le score
    final zone = _getZoneFromScore(globalScore);

    // Tendance (changement depuis le mois dernier)
    final previousScore = (globalScore - tendance).clamp(45, 95);

    // Recommandations aléatoires mais sensées
    final recommendations = _generateRecommendations(
      facialScore: generatedFacial,
      vocalScore: vocal,
      calendrierScore: calendrier,
    );

    // Réponse IA personnalisée
    final aiResponse = _generateAIResponse(
      facialScore: generatedFacial,
      vocalScore: vocal,
      calendrierScore: calendrier,
      zone: zone,
    );

    return {
      'score_ce_mois': globalScore,
      'score_mois_precedent': previousScore,
      'zone': zone,
      'tendance': tendance,
      'vocal': vocal,
      'facial': generatedFacial,
      'calendrier': calendrier,
      'ai_response': aiResponse,
      'recommendations': recommendations,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Détermine la zone basée sur le score
  static String _getZoneFromScore(int score) {
    if (score >= 75) return 'vert';
    if (score >= 60) return 'orange';
    return 'rouge';
  }

  /// Génère des recommandations personnalisées basées sur les scores
  static List<String> _generateRecommendations({
    required int facialScore,
    required int vocalScore,
    required int calendrierScore,
  }) {
    final recommendations = <String>[];

    // Recommandations basées sur les éléments faibles
    if (vocalScore < 60) {
      recommendations.add(
        '🎙️ Ton score vocal est faible — prends des pauses vocales régulières',
      );
    } else if (vocalScore > 75) {
      recommendations.add(
        '✨ Excellent engagement vocal — les réunions te dynamisent!',
      );
    } else {
      recommendations.add(
        '🗣️ Communique un peu plus pour améliorer ton impact',
      );
    }

    if (facialScore < 60) {
      recommendations.add(
        '😟 L\'expression faciale montre de la tension — respire et détends-toi',
      );
    } else if (facialScore > 75) {
      recommendations.add(
        '😊 Ta sérénité faciale inspire confiance — continue ainsi!',
      );
    } else {
      recommendations.add(
        '🧘 Quelques exercices de détente pourraient te faire du bien',
      );
    }

    if (calendrierScore < 60) {
      recommendations.add(
        '📅 Ton calendrier est surchargé — bloque des créneaux de repos',
      );
    } else if (calendrierScore > 75) {
      recommendations.add(
        '⏰ Parfait équilibre horaire — tu as une excellente gestion du tempo!',
      );
    } else {
      recommendations.add(
        '📊 Optimise tes timeslots — regroupe les réunions similaires',
      );
    }

    return recommendations.take(3).toList();
  }

  /// Génère une réponse IA personnalisée
  static String _generateAIResponse({
    required int facialScore,
    required int vocalScore,
    required int calendrierScore,
    required String zone,
  }) {
    final templates = {
      'fatigue': [
        'Ton visage montre des signes de fatigue cette semaine — '
            'c\'est le moment de réduire les réunions consecutive. '
            'Accorde-toi une vraie pause dès demain.',
        'L\'analyse détecte une tension légère au niveau des yeux — '
            'ton écran de travail te fatigue. '
            'Prends 15 min toutes les 2h sans regarder l\'écran.',
      ],
      'serenity': [
        'Tu es étonnamment serein ce mois-ci! '
            'Ton expression suggère un équilibre de bien-être. '
            'Continue à maintenir ce rythme.',
        'Ton visage respire la sérénité et la concentration. '
            'C\'est le signe d\'une bonne gestion du stress. Bravo!',
      ],
      'charge': [
        'Ton calendrier révèle 14+ réunions cette semaine. '
            'C\'est beaucoup — protège au moins 2 créneaux focus.',
        'Tu as ${_random.nextInt(8) + 12} réunions cette semaine. '
            'C\'est au-dessus de la moyenne — priorise les essentielles.',
      ],
    };

    final key = facialScore < 60
        ? 'fatigue'
        : facialScore > 75
        ? 'serenity'
        : 'charge';

    final responses = templates[key] ?? templates['fatigue']!;
    return responses[_random.nextInt(responses.length)];
  }
}
