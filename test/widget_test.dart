import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lynio_flutter/main.dart';

void main() {
  testWidgets('Lynio onboarding enters Demo Mode and loads all 40 watch faces',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const LynioApp());
    await tester.pumpAndSettle();

    // Onboarding screen is shown first
    expect(find.text('Connect your Smart Watch'), findsOneWidget);

    // Advance to watch picker and select Apple Watch Ultra 2
    await tester.ensureVisible(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('Apple Watch Ultra 2'), findsOneWidget);
    await tester.tap(find.text('Apple Watch Ultra 2'));
    await tester.pumpAndSettle();

    // Enter Demo Mode
    await tester.tap(find.text('Demo Mode'));
    await tester.pumpAndSettle();

    // Home dashboard shows Apple Watch Connectivity & Demo Mode
    expect(find.text('iHealthFit'), findsOneWidget);
    expect(find.text('Apple Watch Ultra 2'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('WCSession'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('WCSession'), findsOneWidget);

    // Switch to Watch Faces tab and confirm all 40 faces loaded from JSON
    await tester.tap(find.text('Faces'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('All Faces (40)'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('All Faces (40)'), findsOneWidget);

    // Switch to Alerts & Health tabs
    await tester.tap(find.text('Alerts'));
    await tester.pumpAndSettle();
    expect(find.text('Quiet Hours'), findsOneWidget);

    await tester.tap(find.text('Health'));
    await tester.pumpAndSettle();
    expect(find.text('Daily Steps'), findsOneWidget);
  });
}
