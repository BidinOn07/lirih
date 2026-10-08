import 'package:freezed_annotation/freezed_annotation.dart';

part 'frequency_preset.freezed.dart';

/// Preset frekuensi penalaan (TDD §3.3) — inti fitur pembeda Lirih.
///
/// Frekuensi selalu dihitung relatif terhadap A4 = 440 Hz melalui
/// `pitchRatioForFrequency` (lihat `lib/core/utils/pitch_math.dart`).
/// Pengguna juga dapat memilih frekuensi bebas via slider kontinu.
@freezed
abstract class FrequencyPreset with _$FrequencyPreset {
  /// Membuat preset dengan [name] dan [frequencyHz].
  const factory FrequencyPreset({
    /// Nama preset yang ditampilkan di UI.
    required String name,

    /// Frekuensi target dalam Hz (mis. 440, 432, 528).
    required double frequencyHz,
  }) = _FrequencyPreset;

  const FrequencyPreset._();

  /// Preset bawaan — Standar (A4 internasional).
  static const standard = FrequencyPreset(name: 'Standar', frequencyHz: 440);

  /// 432 Hz — preset alternatif.
  static const verdi = FrequencyPreset(name: '432 Hz', frequencyHz: 432);

  /// 528 Hz — preset alternatif.
  static const solfeggio = FrequencyPreset(name: '528 Hz', frequencyHz: 528);

  /// Ketiga preset bawaan, terurut naik.
  static const builtins = <FrequencyPreset>[standard, verdi, solfeggio];
}
