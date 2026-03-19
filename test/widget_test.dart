import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindzen/app/app.dart';

void main() {
  testWidgets('MindZen home renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MindZenApp()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Bonjour Sarah'), findsOneWidget);
    expect(find.textContaining('Mon Moment MindZen'), findsOneWidget);
  });
}
