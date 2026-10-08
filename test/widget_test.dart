import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lirih/app.dart';
import 'package:lirih/features/library/library_screen.dart';

void main() {
  group('LirihApp', () {
    testWidgets('me-render MaterialApp', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: LirihApp()));

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('navigasi bawah 3 tab & tab Pustaka aktif (task 2.4)', (
      tester,
    ) async {
      await tester.pumpWidget(const ProviderScope(child: LirihApp()));

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(3));
      expect(find.text('PoC'), findsOneWidget);
      // Tab pertama (Pustaka) adalah layar awal.
      expect(find.byType(LibraryScreen), findsOneWidget);
    });
  });
}
