import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_voice_recorder/main.dart';
import 'package:ai_voice_recorder/core/providers/app_providers.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          telemetryStreamProvider.overrideWith((ref, id) => const Stream.empty()),
          meetingsListProvider.overrideWith((ref) async => []),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MyApp), findsOneWidget);
  });
}
