import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shop/main.dart';
import 'package:shop/models/cart.dart';

void main() {
  testWidgets('Add puts a book in the cart and the badge shows 1', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(create: (_) => Cart(), child: const Shell()),
    );

    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.text('Add').first);
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });
}
