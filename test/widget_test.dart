import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lirih/app.dart';
import 'package:lirih/shared/widgets/lirih_logo.dart';
import 'package:lirih/shared/widgets/lirih_wordmark.dart';

void main() {
  group('LirihApp', () {
    testWidgets('me-render MaterialApp', (tester) async {
      await tester.pumpWidget(const LirihApp());

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('menampilkan logo dan wordmark Lirih (task 0N.5)', (
      tester,
    ) async {
      await tester.pumpWidget(const LirihApp());

      expect(find.byType(LirihLogo), findsOneWidget);
      expect(find.byType(LirihWordmark), findsOneWidget);
      // Wordmark memakai huruf kapital ("LIRIH"), bukan [LirihApp.title].
      expect(find.text('LIRIH'), findsOneWidget);
    });
  });
}
