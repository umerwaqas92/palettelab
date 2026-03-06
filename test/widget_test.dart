import 'package:flutter_test/flutter_test.dart';
import 'package:palettelab/main.dart';

void main() {
  testWidgets('Litur app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const LiturApp());
    expect(find.text('Colors'), findsOneWidget);
  });
}
