import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/main.dart';

void main() {
  testWidgets('renders the home hub and toggles theme and language', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Financial Platform'), findsAtLeastNWidgets(1));
    expect(find.text('Dark mode'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('theme-mode-toggle')));
    await tester.pumpAndSettle();

    expect(find.text('Light mode'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('language-toggle')));
    await tester.pumpAndSettle();

    expect(find.text('금융 플랫폼'), findsAtLeastNWidgets(1));
  });
}
