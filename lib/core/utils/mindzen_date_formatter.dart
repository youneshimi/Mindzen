String formatCurrentDate() {
  final now = DateTime.now();
  const weekdays = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];
  const months = [
    'Janvier',
    'Février',
    'Mars',
    'Avril',
    'Mai',
    'Juin',
    'Juillet',
    'Août',
    'Septembre',
    'Octobre',
    'Novembre',
    'Décembre',
  ];

  final weekday = weekdays[now.weekday - 1];
  final month = months[now.month - 1];
  return '$weekday ${now.day} $month ${now.year}';
}
