import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ps_institute/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const PSInstituteApp());

    // Check if any widget from the app loads
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
