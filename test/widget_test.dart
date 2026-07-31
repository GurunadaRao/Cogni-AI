import 'package:flutter_test/flutter_test.dart';
import 'package:ai_voice_recorder/main.dart';

void main() {
  testWidgets('App loads splash screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CogniMeetApp());
    expect(find.text('CogniMeetAI'), findsOneWidget);
  });
}
