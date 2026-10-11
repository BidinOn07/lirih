import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lirih/app.dart';
import 'package:lirih/features/home/home_screen.dart';

void main() {
  group('LirihApp', () {
    testWidgets('me-render MaterialApp', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: LirihApp()));

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('navigasi bawah 3 tab & tab Beranda aktif (task 2.4)', (
      tester,
    ) async {
      // NavigationBar butuh ukuran layar konkret agar label ter-render.
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const ProviderScope(child: LirihApp()));

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(3));
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Pemutar'), findsNothing);
      // Tab pertama (Beranda) adalah layar awal.
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
