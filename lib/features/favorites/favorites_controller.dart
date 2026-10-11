import 'package:hive_ce/hive.dart';
import 'package:lirih/core/services/hive_service.dart';
import 'package:lirih/data/mappers/track_mapper.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorites_controller.g.dart';

/// Trek yang ditandai favorit pengguna (task 3.1) — disimpan di
/// `favoritesBox`.
///
/// Tiap trek disimpan utuh (key = [Track.id], value = map `TrackMapper`)
/// sehingga favorit tetap bisa diputar walau pemindaian MediaStore belum
/// selesai. Sama seperti controller Hive lainnya, controller ini bersifat
/// *inert* bila box belum terbuka — operasi menjadi no-op alih-alih
/// menghempaskan galat.
@riverpod
class FavoritesController extends _$FavoritesController {
  Box<dynamic>? _box;

  @override
  List<Track> build() {
    if (!Hive.isBoxOpen(HiveBoxes.favorites)) return const <Track>[];
    _box = Hive.box<dynamic>(HiveBoxes.favorites);
    return _readAll();
  }

  /// Membaca seluruh trek favorit dari box (urutan penambahan).
  List<Track> _readAll() {
    final box = _box;
    if (box == null) return const <Track>[];

    final tracks = <Track>[];
    for (final value in box.values) {
      if (value is! Map) continue;
      final track = TrackMapper.fromJson(Map<String, dynamic>.from(value));
      if (track != null) tracks.add(track);
    }
    return List<Track>.unmodifiable(tracks);
  }

  /// Apakah trek ber-ID [id] sedang ditandai favorit.
  bool isFavorite(String id) => state.any((track) => track.id == id);

  /// Menambahkan [track] ke favorit, atau menghapusnya bila sudah ada.
  Future<void> toggle(Track track) async {
    final box = _box;
    if (box == null) return;

    if (isFavorite(track.id)) {
      await box.delete(track.id);
    } else {
      await box.put(track.id, TrackMapper.toJson(track));
    }
    state = _readAll();
  }
}
