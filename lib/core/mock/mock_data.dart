const mockUser = {
  'name': 'Sarah Dupont',
  'team': 'Équipe Marketing',
  'company': 'Corsica Tech',
  'avatar': 'SD',
  'score_ce_mois': 62,
  'zone': 'orange',
  'score_mois_precedent': 74,
  'tendance': -12,
};

const mockHistory = [
  {'month': 'Août', 'score': 81},
  {'month': 'Sep', 'score': 76},
  {'month': 'Oct', 'score': 74},
  {'month': 'Nov', 'score': 68},
  {'month': 'Déc', 'score': 71},
  {'month': 'Jan', 'score': 62},
];

const mockDimensions = {
  'vocal': 58,
  'facial': 65,
  'calendrier': 55,
  'tendance': 70,
};

const mockAIResponse =
    'Ta voix montre des signes de fatigue ce mois-ci — '
    'ton débit est 18% plus lent que ta moyenne habituelle. '
    'Rien d\'alarmant, mais ce serait une bonne semaine '
    'pour t\'accorder du temps sans réunions. '
    'Tu mérites une vraie pause.';

const mockRecommandations = [
  '🗓️ Évite les réunions consécutives le jeudi',
  '🥗 Prends une pause déjeuner sans écran cette semaine',
  '😴 Ton score vocal montre de la fatigue — dors 30 min de plus',
];

const mockCalendar = {
  'reunions_semaine': 14,
  'consecutives_max': 4,
  'reunions_tardives': 3,
  'taches_en_retard': 6,
  'score_surcharge': 78,
};

const mockMedecin = {
  'total_employes': 48,
  'zone_vert': 28,
  'zone_orange': 14,
  'zone_rouge': 6,
  'equipes': [
    {'nom': 'Équipe Marketing', 'score': 58, 'zone': 'rouge', 'tendance': '↓'},
    {'nom': 'Équipe IT', 'score': 64, 'zone': 'orange', 'tendance': '↓'},
    {'nom': 'Équipe RH', 'score': 79, 'zone': 'vert', 'tendance': '→'},
    {'nom': 'Équipe Finance', 'score': 82, 'zone': 'vert', 'tendance': '↑'},
    {
      'nom': 'Équipe Commercial',
      'score': 61,
      'zone': 'orange',
      'tendance': '↓',
    },
  ],
  'alertes': [
    '⚠️ Équipe Marketing — 3 membres en zone rouge ce mois',
    '📈 Équipe IT — hausse de risque depuis 2 mois consécutifs',
  ],
};

const mockEntreprise = {
  'score_global': 68,
  'burnouts_evites': 4,
  'roi_euros': 14000,
  'recommandations': [
    'L\'équipe Marketing montre une surcharge récurrente le jeudi — limitez les réunions ce jour-là.',
    '3 équipes ont un taux de réunions supérieur à 80% — un bloc focus hebdomadaire est recommandé.',
  ],
};
