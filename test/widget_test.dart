import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unperch/app.dart';

void main() {
  testWidgets('app renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: UnperchApp()));
    expect(find.byType(UnperchApp), findsOneWidget);
  });
}
