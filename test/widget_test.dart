// This is a basic Flutter widget test.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tastesmoke_flutter/main.dart';

void main() {
  testWidgets('TasteSmoke app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: TasteSmokeApp()));

    // Wait for initial loading
    await tester.pump();
    
    // The app should start without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
  
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Simple test to ensure app widget can be created
    const app = ProviderScope(child: TasteSmokeApp());
    
    await tester.pumpWidget(app);
    await tester.pump();
    
    // App should be created without throwing errors
    expect(app, isNotNull);
  });
}
