import 'package:hive_ce/hive.dart';
import 'package:lirih/core/services/hive_service.dart';
import 'package:lirih/data/mappers/track_mapper.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recent_plays_controller.g.dart';

/// Jumlah maksimal trek pada daftar "Putar terakhir".
const int kMaxRecentPlays = 20;

/// Riwayat trek yang pernah diputar (task 2.6) — disimpan di `recentsBox`.
///
/// Trek terbaru ada di depan, unik per id trek, dibatasi
/// [kMaxRecentPlays] entri. Dipakai tab Home ("Putar terakhir") dan
/// quick-access. Sama seperti SearchHistoryController, controller ini
/// bersifat *inert* bila box belum terbuka (tidak menghemparkan galat).
@riverpod
class RecentPlaysController extends _$RecentPlaysController {
  static const String _storageKey = 'recentTracks';

  Box<dynamic>? _box;

  @override
  List<Track> build() {
    if (!Hive.isBoxOpen(HiveBoxes.recents)) return const <Track>[];
    _box = Hive.box<dynamic>(HiveBoxes.recents);
    return _read();
  }

  List<Track> _read() {
    final box = _box;
    if (box == null) return const <Track>[];

    final raw = box.get(_storageKey);
    if (raw is! List) return const <Track>[];

    final tracks = <Track>[];
    for (final entry in raw) {
      if (entry is! Map) continue;
      final track = TrackMapper.fromJson(Map<String, dynamic>.from(entry));
      if (track != null) tracks.add(track);
    }
    return List<Track>.unmodifiable(tracks);
  }

  /// Mencatat bahwa [track] baru saja diputar.
  Future<void> recordPlay(Track track) async {
    final box = _box;
    if (box == null) return;

    final updated = <Track>[
      track,
      ..._read().where((t) => t.id != track.id),
    ].take(kMaxRecentPlays);

    await box.put(
      _storageKey,
      updated.map(TrackMapper.toJson).toList(growable: false),
    );
    state = _read();
  }

  /// Menghapus seluruh riwayat putar.
  Future<void> clear() async {
    await _box?.delete(_storageKey);
    state = _read();
  }
}
