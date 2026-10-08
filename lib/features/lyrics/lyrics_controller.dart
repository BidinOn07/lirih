import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lirih/core/audio/dsp_channel.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/features/player/player_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lyrics_controller.g.dart';

/// Lirik trek yang sedang aktif (task 3.2) — diambil dari frame lirik
/// tertanam (`USLT` di tag ID3v2) lewat parser native (best effort:
/// `null` bila tak ada).
///
/// Status berupa [AsyncValue] `String?`: `loading` saat mengambil,
/// `data(null)` bila trek tak punya lirik. Hasil di-<b>cache</b> per id
/// trek dalam memori. Provider hanya dibangun ulang saat trek aktif
/// berubah (bukan tiap pembaruan posisi).
@riverpod
class LyricsController extends _$LyricsController {
  final DspChannel _dsp = const DspChannel();

  /// Cache per id trek agar lirik tak diambil ulang saat kembali ke lagu.
  final Map<String, String?> _cache = <String, String?>{};

  @override
  FutureOr<String?> build() {
    // Hanya react saat trek aktif berganti, bukan saat posisi berubah.
    final track = ref.watch(
      playerControllerProvider.select((state) => state.currentTrack),
    );
    if (track == null) return null;
    return _load(track);
  }

  Future<String?> _load(Track track) async {
    if (_cache.containsKey(track.id)) return _cache[track.id];
    final lyrics = await _dsp.lyricsFor(track.sourcePath);
    _cache[track.id] = lyrics;
    return lyrics;
  }

  /// Menghapus seluruh cache lirik (mis. setelah mengubah tag).
  void clearCache() => _cache.clear();
}
