import 'package:hive_ce/hive.dart';
import 'package:lirih/core/services/hive_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_history_controller.g.dart';

/// Jumlah maksimal entri riwayat pencarian yang disimpan.
const int kMaxSearchHistory = 10;

/// Riwayat pencarian pengguna (task 3.5) — disimpan di `searchHistoryBox`.
///
/// Entri terbaru ada di depan, unik, dibatasi [kMaxSearchHistory] entri.
/// Karena hanya menyimpan String, tidak butuh adapter Hive kustom.
///
/// Bila box belum terbuka (mis. inisialisasi Hive gagal atau lingkungan
/// test), controller bersifat *inert*: riwayat tetap tampil kosong tanpa
/// menghempaskan galat ke UI — fitur ini bersifat pelengkap, bukan inti.
@riverpod
class SearchHistoryController extends _$SearchHistoryController {
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
  Future<void> add(String query) async {
    final trimmed = query.trim();
    final box = _box;
    if (trimmed.isEmpty || box == null) return;

    final updated = <String>[
      trimmed,
      ..._values.where((e) => e != trimmed),
    ].take(kMaxSearchHistory);

    await box.clear();
    await box.addAll(updated);
    state = _values;
  }

  /// Menghapus seluruh riwayat pencarian.
  Future<void> clear() async {
    await _box?.clear();
    state = _values;
  }
}
