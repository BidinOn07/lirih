import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:lirih/core/utils/pitch_math.dart';
import 'package:lirih/domain/entities/track.dart';

part 'player_state.freezed.dart';

/// Status pemutar Lirih — sumber kebenaran tunggal untuk UI player (task 2.7).
///
/// Antrean (`queue`) berisi daftar trek yang sedang dapat diputar; indeks
/// `currentIndex` menandai trek aktif. Frekuensi penalaan [frequencyHz]
/// diterapkan ke seluruh playback (fitur pembeda Lirih).
@freezed
abstract class PlayerState with _$PlayerState {
  /// Membuat status pemutar dengan [queue] dan nilai default lainnya.
  const factory PlayerState({
    /// Antrean trek yang sedang dimainkan.
    required List<Track> queue,

    /// Indeks trek aktif; `-1` bila belum ada trek.
    @Default(-1) int currentIndex,

    /// Sedang memutar?
    @Default(false) bool isPlaying,

    /// Posisi playback (milidetik).
    @Default(0) int positionMs,

    /// Durasi trek aktif (milidetik).
    @Default(0) int durationMs,

    /// Frekuensi penalaan aktif (default A4 internasional).
    @Default(kReferenceFrequencyHz) double frequencyHz,
  }) = _PlayerState;
  const PlayerState._();

  /// Trek yang sedang aktif, `null` bila belum ada.
  Track? get currentTrack => (currentIndex >= 0 && currentIndex < queue.length)
      ? queue[currentIndex]
      : null;

  /// Rasio pitch yang sedang diterapkan ke mesin native.
  double get pitchRatio => pitchRatioForFrequency(frequencyHz);

  /// Offset nada saat ini dalam cents (untuk tampilan tuner).
  double get centsOffset => centsOffsetForFrequency(frequencyHz);
}
