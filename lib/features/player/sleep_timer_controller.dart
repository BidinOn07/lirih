import 'dart:async';

import 'package:lirih/features/player/player_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sleep_timer_controller.g.dart';

/// Pilihan durasi sleep timer yang ditawarkan UI (menit).
const List<int> kSleepTimerMinutes = <int>[5, 10, 15, 30, 45, 60];

/// Sleep timer (task 2.9) — menjeda playback otomatis setelah selang waktu.
///
/// Status berupa sisa durasi; `null` berarti timer tidak aktif. Saat habis,
/// playback dijeda lewat [PlayerController.pauseIfPlaying] (frekuensi penalaan
/// tidak direset, sehingga melanjutkan tetap pada 432/528 Hz).
@riverpod
class SleepTimerController extends _$SleepTimerController {
  Timer? _timer;

  @override
  Duration? build() {
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  /// Memulai hitungan mundur [duration]; playback dijeda saat habis.
  void start(Duration duration) {
    _timer?.cancel();
    state = duration;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state;
      if (remaining == null) {
        timer.cancel();
        return;
      }
      final next = remaining - const Duration(seconds: 1);
      if (next <= Duration.zero) {
        timer.cancel();
        state = null;
        unawaited(ref.read(playerControllerProvider.notifier).pauseIfPlaying());
        return;
      }
      state = next;
    });
  }

  /// Membatalkan timer yang sedang berjalan.
  void cancel() {
    _timer?.cancel();
    state = null;
  }
}
