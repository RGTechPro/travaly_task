// Basic Flutter widget test for MyTravaly app

import 'package:flutter_test/flutter_test.dart';

import 'package:travaly_task/main.dart';

void main() {
  testWidgets('MyTravaly app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyTravalyApp());

    // Verify that splash screen shows up
    expect(find.text('MyTravaly'), findsOneWidget);
    expect(find.text('Find your perfect stay'), findsOneWidget);
  });
}
