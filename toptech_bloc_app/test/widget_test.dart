import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toptech_bloc_app/core/services/storage_service.dart';
import 'package:toptech_bloc_app/main.dart';

void main() {
  testWidgets('App loads splash screen smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = await StorageService.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(TopTechApp(storageService: storageService));

    // Verify that TOPTECH text is present on the splash screen.
    expect(find.text('TOPTECH'), findsOneWidget);

    // Advance timer past splash duration to complete splash bloc timer cleanly
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
