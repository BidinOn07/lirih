import 'package:hive_ce/hive.dart';
import 'package:lirih/core/services/hive_service.dart';
import 'package:lirih/core/utils/pitch_math.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_controller.g.dart';

/// Kunci Hive untuk frekuensi default.
const String kDefaultFrequencyKey = 'defaultFrequencyHz';

/// Pengaturan aplikasi yang disimpan permanen (task 5.x).
///
/// Saat ini hanya menyimpan **frekuensi default** — frekuensi penalaan
/// terakhir yang dipakai pemutar, dipulihkan saat aplikasi dibuka kembali.
/// Sama seperti controller Hive lainnya, bersifat *inert* (mengembalikan
/// nilai bawaan [kReferenceFrequencyHz]) bila box belum terbuka.
@riverpod
class SettingsController extends _$SettingsController {
  Box<dynamic>? _box;

  @override
  double build() {
    if (!Hive.isBoxOpen(HiveBoxes.settings)) return kReferenceFrequencyHz;
    _box = Hive.box<dynamic>(HiveBoxes.settings);
    return _readFrequency();
  }

  double _readFrequency() {
    final stored = _box?.get(kDefaultFrequencyKey);
    if (stored is num) return stored.toDouble();
    return kReferenceFrequencyHz;
  }

  /// Menyimpan [hz] sebagai frekuensi default pemutar.
  Future<void> setDefaultFrequency(double hz) async {
    state = hz;
    await _box?.put(kDefaultFrequencyKey, hz);
  }
}
