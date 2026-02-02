import 'package:flutter_test/flutter_test.dart';
import 'package:roady/main.dart';

void main() {
  testWidgets('App starts and shows Roady', (WidgetTester tester) async {
    await tester.pumpWidget(const RoadyApp());
    expect(find.text('Roady', findRichText: true), findsOneWidget);
  });
}
