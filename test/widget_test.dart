import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lirih/app.dart';

void main() {
  group('LirihApp', () {
    testWidgets('me-render MaterialApp dan judul aplikasi', (tester) async {
      await tester.pumpWidget(const LirihApp());

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text(LirihApp.title), findsOneWidget);
    });
  });
}
