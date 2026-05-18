import 'package:flutter_test/flutter_test.dart';
import 'package:siar_app/main.dart';

void main() {
  testWidgets('SIAR app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SiarApp());
    expect(find.text('Dashboard'), findsOneWidget);
  });
}