import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lirih/core/errors/failures.dart';
import 'package:lirih/core/extensions/either_x.dart';

void main() {
  group('EitherX.getOrThrow', () {
    test('mengembalikan nilai kanan pada Right', () {
      const either = Right<Failure, int>(42);

      expect(either.getOrThrow(), 42);
    });

    test('melempar nilai kiri pada Left', () {
      const failure = ScanFailure('boom');
      const either = Left<ScanFailure, int>(failure);

      expect(() => either.getOrThrow(), throwsA(failure));
    });
  });
}
