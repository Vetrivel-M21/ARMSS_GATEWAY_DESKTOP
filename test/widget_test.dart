import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mis_desktop/app/app.dart';

void main() {
  testWidgets('shows the login screen when logged out', (WidgetTester tester) async {
    // The portal session check reads SharedPreferences on startup — without
    // mock initial values its platform channel never responds in a test.
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: MisApp()));
    // Logged-out now also waits on the portal session's async check (a
    // persisted-token lookup) before showing the login screen.
    await tester.pumpAndSettle();

    expect(find.image(const AssetImage('assets/images/login_logo.png')), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Username or Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
  });
}
