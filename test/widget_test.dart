import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_engine/main.dart';

void main() {
  testWidgets('App loads splash test', (WidgetTester tester) async {
    await tester.pumpWidget(const NexusEngineApp());
    expect(find.text('O NEXUS'), findsWidgets);
  });
}
