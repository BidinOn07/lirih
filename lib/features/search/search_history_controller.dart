import 'package:hive_ce/hive.dart';
import 'package:lirih/core/services/hive_service.dart';
import 'package:lirih/data/mappers/track_mapper.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_history_controller.g.dart';

/// Jumlah maksimal entri riwayat pencarian yang disimpan.
const int kMaxSearchHistory = 10;

/// Jumlah maksimal trek hasil pencarian terakhir yang disimpan.
const int kMaxLastSearchResults = 20;

/// Hasil pencarian terakhir — kueri dan trek yang cocok (task 3.5).
///
/// Dipakai layar Pencarian untuk menampilkan kembali lagu yang terakhir
/// dicari (dan dapat diputar) saat kolom pencarian kosong.
class LastSearch {
  /// Membuat catatan hasil pencarian [query].
  const LastSearch({required this.query, required this.tracks});

  /// Teks kueri yang menghasilkan [tracks].
  final String query;

  /// Trek yang cocok dengan [query], terurut seperti hasil aslinya.
  final List<Track> tracks;
}

/// Riwayat pencarian pengguna (task 3.5) — disimpan di `searchHistoryBox`.
///
/// Entri terbaru ada di depan, unik, dibatasi [kMaxSearchHistory] entri.
/// Karena hanya menyimpan String, tidak butuh adapter Hive kustom. Hasil
/// pencarian terakhir disimpan terpisah di key [lastResultsKey] (sebagai
/// map `{'query': String, 'tracks': List<Map>}`).
///
/// Bila box belum terbuka (mis. inisialisasi Hive gagal atau lingkungan
/// test), controller bersifat *inert*: riwayat tetap tampil kosong tanpa
/// menghempaskan galat ke UI — fitur ini bersifat pelengkap, bukan inti.
@riverpod
class SearchHistoryController extends _$SearchHistoryController {
  /// Key khusus (non-String) di box untuk hasil terakhir.
  static const String lastResultsKey = '__last_search__';

  Box<dynamic>? _box;

  @override
  List<String> build() {
    if (!Hive.isBoxOpen(HiveBoxes.searchHistory)) return const <String>[];
    _box = Hive.box<dynamic>(HiveBoxes.searchHistory);
    return _values;
  }

  List<String> get _values =>
      _box?.values.whereType<String>().toList(growable: false) ??
      const <String>[];

  /// Menambahkan [query] ke puncak riwayat (mengabaikan string kosong).
  ///
  /// Hanya entri String yang dihapus — key [lastResultsKey] (map) harus
  /// tetap ada agar hasil pencarian terakhir tidak hilang.
  Future<void> add(String query) async {
    final trimmed = query.trim();
    final box = _box;
    if (trimmed.isEmpty || box == null) return;

    for (final key in box.keys.toList()) {
      if (box.get(key) is String) await box.delete(key);
    }
    await box.addAll(
      <String>[
        trimmed,
        ..._values.where((e) => e != trimmed),
      ].take(kMaxSearchHistory),
    );
    state = _values;
  }

  /// Menghapus seluruh riwayat pencarian (termasuk hasil terakhir).
  Future<void> clear() async {
    await _box?.clear();
    state = _values;
  }

  /// Menyimpan [tracks] sebagai hasil pencarian terakhir untuk [query]
  /// (dibatasi [kMaxLastSearchResults] trek pertama).
  Future<void> saveResults(String query, List<Track> tracks) async {
    final box = _box;
    if (box == null) return;
    await box.put(lastResultsKey, <String, dynamic>{
      'query': query,
      'tracks': tracks
          .take(kMaxLastSearchResults)
          .map(TrackMapper.toJson)
          .toList(),
    });
  }

  /// Hasil pencarian terakhir; `null` bila belum ada/box tertutup/rusak.
  LastSearch? get lastSearch {
    final box = _box;
    if (box == null) return null;
    final json = box.get(lastResultsKey);
    if (json is! Map) return null;
    final query = json['query'];
    if (query is! String) return null;
    final rawTracks = json['tracks'];
    if (rawTracks is! List) return null;
    final tracks = <Track>[];
    for (final entry in rawTracks) {
      if (entry is Map) {
        final track = TrackMapper.fromJson(Map<String, dynamic>.from(entry));
        if (track != null) tracks.add(track);
      }
    }
    if (tracks.isEmpty) return null;
    return LastSearch(query: query, tracks: tracks);
  }
}
