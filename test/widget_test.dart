import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindzen/app/app.dart';

void main() {
  testWidgets('MindZen home renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MindZenApp()));
    await tester.pumpAndSettle();

    // Login page should be shown first
    expect(find.textContaining('Selectionnez votre role'), findsOneWidget);

    // Tap on Employé button
    await tester.tap(find.textContaining('Employe'));
    await tester.pumpAndSettle();

    // Home page should now be visible
    expect(find.textContaining('Bonjour Sarah'), findsOneWidget);
    expect(find.textContaining('Mon Moment MindZen'), findsOneWidget);
  });
}
