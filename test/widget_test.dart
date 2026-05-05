
import 'package:flutter_test/flutter_test.dart';

import 'package:kascahh/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KasCahhApp());

    // Verify that the splash screen loads with the text "KasCahh"
    expect(find.text('KasCahh'), findsWidgets);
  });
}
