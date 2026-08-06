import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/main.dart';

void main() {
  testWidgets('EHealthCardApp displays the dashboard and emergency access', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EHealthCardApp());

    expect(find.text('Carnet santé'), findsOneWidget);
    expect(find.text('Fiche d’urgence'), findsOneWidget);
  });
}
