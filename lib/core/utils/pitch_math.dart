/// Matematika penyetelan nada (pitch) — landasan fitur frekuensi Lirih.
///
/// Semua preset dihitung relatif terhadap **A4 = 440 Hz** (referensi
/// internasional). Rumus ini sengaja dipisah dari mesin native agar mudah
/// diuji unit tanpa perangkat — lihat `test/core/utils/pitch_math_test.dart`.
///
/// Lihat `MelodicDSP-Technical-Design-Doc.md` §4.1.
library;

import 'dart:math' as math;

/// Frekuensi referensi A4. Semua rasio pitch dihitung relatif ke nilai ini.
const double kReferenceFrequencyHz = 440;

/// Frekuensi minimum slider kontinu (Hz).
const double kMinFrequencyHz = 400;

/// Frekuensi maksimum slider kontinu (Hz).
const double kMaxFrequencyHz = 600;

/// Batas bawah rasio pitch mesin native.
const double kMinPitchRatio = 0.5;

/// Batas atas rasio pitch mesin native.
const double kMaxPitchRatio = 2;

/// Mengubah frekuensi target menjadi rasio pitch untuk mesin native.
///
/// `pitchRatioForFrequency(440) == 1.0`; `pitchRatioForFrequency(432)`
/// ≈ 0.9818; `pitchRatioForFrequency(528) == 1.2`. Nilai dijaga tetap dalam
/// rentang aman [kMinPitchRatio, kMaxPitchRatio].
double pitchRatioForFrequency(double frequencyHz) {
  final ratio = frequencyHz / kReferenceFrequencyHz;
  if (ratio < kMinPitchRatio) return kMinPitchRatio;
  if (ratio > kMaxPitchRatio) return kMaxPitchRatio;
  return ratio;
}

/// Offset frekuensi terhadap referensi dalam satuan **cents**
/// (100 cents = 1 semitone) untuk ditampilkan di UI tuner.
///
/// Contoh: 432 Hz ≈ −31.77 cents; 528 Hz ≈ +315.64 cents (rasio 1.2×).
double centsOffsetForFrequency(double frequencyHz) {
  // 1200 · log2(f / 440); dart:math tidak punya log2 → dibagi dengan ln 2.
  return 1200 * math.log(frequencyHz / kReferenceFrequencyHz) / math.log(2);
}
