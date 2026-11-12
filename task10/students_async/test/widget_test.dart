import 'package:flutter_test/flutter_test.dart';
import 'package:students_async/main.dart';

void main() {
  testWidgets('home screen shows three ways in', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('By hand'), findsOneWidget);
    expect(find.text('FutureBuilder'), findsOneWidget);
    expect(find.text('Countdown'), findsOneWidget);
  });
}
