import 'package:flutter_test/flutter_test.dart';

import 'package:lirih/core/utils/pitch_math.dart';

void main() {
  group('pitchRatioForFrequency', () {
    test('440 Hz menghasilkan rasio 1.0 (referensi)', () {
      expect(pitchRatioForFrequency(440), 1.0);
    });

    test('432 Hz menghasilkan rasio ~0.9818', () {
      expect(pitchRatioForFrequency(432), closeTo(0.981818, 1e-5));
    });

    test('528 Hz dihitung dari 440, bukan konstanta hardcode', () {
      // 528 / 440 = 1.2 — keharusan ini berlaku untuk base lain juga.
      expect(pitchRatioForFrequency(528), 1.2);
      expect(pitchRatioForFrequency(880), 2.0);
    });

    test('frekuensi di luar slider tetap di-clamp ke rentang aman', () {
      expect(pitchRatioForFrequency(100), kMinPitchRatio);
      expect(pitchRatioForFrequency(1000), kMaxPitchRatio);
    });
  });

  group('centsOffsetForFrequency', () {
    test('440 Hz = 0 cents', () {
      expect(centsOffsetForFrequency(440), closeTo(0.0, 1e-9));
    });

    test('432 Hz ≈ −31.77 cents sesuai spec', () {
      expect(centsOffsetForFrequency(432), closeTo(-31.77, 0.01));
    });

    test('528 Hz ≈ +315.64 cents (rasio 1.2×)', () {
      expect(centsOffsetForFrequency(528), closeTo(315.64, 0.01));
    });

    test('naik 1 oktaf (880 Hz) = +1200 cents', () {
      expect(centsOffsetForFrequency(880), closeTo(1200.0, 1e-6));
    });
  });
}
