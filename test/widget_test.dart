import 'package:flutter_test/flutter_test.dart';
import 'package:roady/auth/auth_state.dart';
import 'package:roady/main.dart';

void main() {
  testWidgets('App starts and shows Roady', (WidgetTester tester) async {
    await tester.pumpWidget(RoadyApp(authState: AuthState()));
    expect(find.text('Roady', findRichText: true), findsOneWidget);
  });
}
