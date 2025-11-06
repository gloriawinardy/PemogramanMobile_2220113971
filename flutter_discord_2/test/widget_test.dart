
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_discord_2/main.dart';

void main() {
  testWidgets('Discord login UI loads correctly', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const DiscordLoginApp());

    // Verify that the title text exists
    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });
}
