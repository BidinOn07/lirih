import 'dart:async';
import 'dart:io';

import 'package:lirih/core/audio/dsp_channel.dart';
import 'package:lirih/core/utils/pitch_math.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/features/player/player_state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_controller.g.dart';

/// Kendali pemutar Lirih (task 2.7) — jembatan antara antrean trek dan
/// mesin DSP native.
///
/// Memegang [PlayerState] sebagai sumber kebenaran tunggal: antrean, trek
/// aktif, status pemutaran, posisi, dan **frekuensi penalaan**. Posisi
/// dijaga tetap mutakhir dengan *polling* periodik (mesin native tidak
/// memancarkan posisi — hanya `completed`/`error`).
///
/// Sementara memakai [DspChannel] (PoC); akan digantikan oleh plugin
/// `lirih_audio` (task 1.x) tanpa mengubah UI.
@riverpod
class PlayerController extends _$PlayerController {
  final DspChannel _dsp = const DspChannel();

  Timer? _positionTimer;

  StreamSubscription<DspEventPayload>? _eventSub;

  /// Apakah izin notifikasi sudah pernah diminta (hindari nag).
  bool _notificationAsked = false;

  @override
  PlayerState build() {
    _eventSub = _dsp.events.listen(_onNativeEvent);
    ref.onDispose(() {
      unawaited(_eventSub?.cancel());
      _positionTimer?.cancel();
      unawaited(_dsp.stop());
    });
    return const PlayerState(queue: <Track>[]);
  }

  /// Menangani event dari mesin native.
  void _onNativeEvent(DspEventPayload payload) {
    switch (payload.event) {
      case DspEvent.completed:
        unawaited(skipNext());
      case DspEvent.error:
        state = state.copyWith(isPlaying: false);
        _stopPositionTimer();
    }
  }

  /// Memutar [track] dalam konteks [queue] (default: trek tunggal).
  Future<void> playTrack(Track track, {List<Track>? queue}) async {
    await _ensureNotificationPermission();

    final effectiveQueue = queue ?? <Track>[track];
    var index = effectiveQueue.indexOf(track);
    if (index < 0) index = 0;

    state = state.copyWith(
      queue: effectiveQueue,
      currentIndex: index,
      isPlaying: true,
      positionMs: 0,
      durationMs: 0,
    );

    await _dsp.play(track.sourcePath);
    await _dsp.setPitch(pitchRatioForFrequency(state.frequencyHz));
    _startPositionTimer();
  }

  /// Menjeda atau melanjutkan playback.
  Future<void> togglePlay() async {
    if (state.currentTrack == null) return;
    if (state.isPlaying) {
      await _dsp.pause();
      _stopPositionTimer();
      state = state.copyWith(isPlaying: false);
    } else {
      await _dsp.resume();
      _startPositionTimer();
      state = state.copyWith(isPlaying: true);
    }
  }

  /// Trek berikutnya (membungkus ke awal bila di akhir antrean).
  Future<void> skipNext() => _skipBy(1);

  /// Trek sebelumnya (membungkus ke akhir bila di awal antrean).
  Future<void> skipPrevious() => _skipBy(-1);

  Future<void> _skipBy(int delta) async {
    final queue = state.queue;
    if (queue.isEmpty) return;
    final next = (state.currentIndex + delta) % queue.length;
    await playTrack(queue[next], queue: queue);
  }

  /// Melompat ke [position].
  Future<void> seekTo(Duration position) async {
    await _dsp.seek(position);
    state = state.copyWith(positionMs: position.inMilliseconds);
  }

  /// Mengatur frekuensi penalaan (diterapkan real-time ke mesin native).
  Future<void> setFrequency(double hz) async {
    state = state.copyWith(frequencyHz: hz);
    await _dsp.setPitch(pitchRatioForFrequency(hz));
  }

  /// Menghentikan playback sepenuhnya.
  Future<void> stop() async {
    await _dsp.stop();
    _stopPositionTimer();
    state = state.copyWith(isPlaying: false, positionMs: 0);
  }

  // ── Polling posisi ────────────────────────────────────────────────

  /// Minta izin notifikasi sekali (Android 13+) agar kontrol media tampil.
  /// Best-effort: playback tetap jalan bila ditolak.
  Future<void> _ensureNotificationPermission() async {
    if (_notificationAsked) return;
    _notificationAsked = true;
    if (!Platform.isAndroid) return;
    final status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 500), (
      _,
    ) async {
      if (!state.isPlaying) return;
      final position = await _dsp.getPosition();
      final duration = await _dsp.getDuration();
      state = state.copyWith(
        positionMs: position.inMilliseconds,
        durationMs: duration.inMilliseconds,
      );
    });
  }

  void _stopPositionTimer() => _positionTimer?.cancel();
}
