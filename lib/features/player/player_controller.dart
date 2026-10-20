import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:hive_ce/hive.dart';
import 'package:lirih/core/audio/dsp_channel.dart';
import 'package:lirih/core/services/hive_service.dart';
import 'package:lirih/core/utils/pitch_math.dart';
import 'package:lirih/data/mappers/track_mapper.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/features/favorites/favorites_controller.dart';
import 'package:lirih/features/home/recent_plays_controller.dart';
import 'package:lirih/features/player/player_state.dart';
import 'package:lirih/features/player/repeat_mode.dart';
import 'package:lirih/features/settings/settings_controller.dart';
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

  /// Key antrean di `queueBox` (task 1.10).
  static const String _queueKey = 'queue';

  /// Key indeks trek aktif di `queueBox`.
  static const String _indexKey = 'queueIndex';

  /// Key mode pengulangan di `queueBox`.
  static const String _repeatKey = 'repeatMode';

  /// Key mode acak di `queueBox`.
  static const String _shuffleKey = 'isShuffling';

  Timer? _positionTimer;

  /// Generator angka acak untuk mode shuffle.
  final Random _random = Random();

  StreamSubscription<DspEventPayload>? _eventSub;

  /// Langganan aksi tombol kustom notifikasi media (task 3.5).
  StreamSubscription<NotificationAction>? _notificationActionSub;

  /// Box Hive untuk persistensi antrean; `null` bila belum terbuka (inert).
  Box<dynamic>? _box;

  /// Apakah izin notifikasi sudah pernah diminta (hindari nag).
  bool _notificationAsked = false;

  @override
  PlayerState build() {
    // Frekuensi default dipulihkan dari pengaturan (task 5.x).
    final defaultHz = ref.read(settingsControllerProvider);
    // Antrean, trek aktif, dan mode pengulangan dipulihkan dari Hive
    // (task 1.10). Playback TIDAK dilanjutkan otomatis — pengguna menekan
    // Play sendiri setelah aplikasi dibuka kembali.
    final restored = _restoreQueue(defaultHz);
    _eventSub = _dsp.events.listen(_onNativeEvent);
    _notificationActionSub = _dsp.notificationActions.listen(
      _onNotificationAction,
    );
    ref.onDispose(() {
      unawaited(_eventSub?.cancel());
      unawaited(_notificationActionSub?.cancel());
      _positionTimer?.cancel();
      unawaited(_dsp.stop());
    });
    return restored;
  }

  /// Mengirim state pemutar ke native agar ikon tombol kustom di notifikasi
  /// media selalu sinkron (task 3.5).
  ///
  /// Membaca status favorit trek aktif dari [FavoritesController] lalu
  /// memanggil [DspChannel.setNotificationState]. *Best effort* — galat
  /// diabaikan agar tidak mengganggu playback.
  void _pushNotificationState() {
    final track = state.currentTrack;
    final isFavorite =
        track != null &&
        ref.read(favoritesControllerProvider).any((t) => t.id == track.id);
    unawaited(
      _dsp.setNotificationState(
        isPlaying: state.isPlaying,
        isShuffling: state.isShuffling,
        repeatMode: kLoopCycle.indexOf(state.repeatMode),
        isFavorite: isFavorite,
      ),
    );
  }

  /// Menangani event dari mesin native.
  void _onNativeEvent(DspEventPayload payload) {
    switch (payload.event) {
      case DspEvent.completed:
        unawaited(_skipBy(1, auto: true));
      case DspEvent.error:
        state = state.copyWith(isPlaying: false);
        _stopPositionTimer();
      case DspEvent.playingStateChanged:
        // Jeda/lanjut dari **kontrol media standar** notifikasi (slot tengah
        // Android 13+) atau audio focus tidak melalui Dart — ikuti state
        // native agar ikon mini player & polling posisi tetap sinkron.
        final isPlaying = payload.data == 'true';
        if (isPlaying) {
          _startPositionTimer();
        } else {
          _stopPositionTimer();
        }
        state = state.copyWith(isPlaying: isPlaying);
    }
  }

  /// Menangani aksi tombol kustom dari notifikasi media (task 3.5).
  ///
  /// Aksi diteruskan dari `LirihPlaybackService` via `NotificationActions`.
  /// Setiap aksi memperbarui state, dan perubahan tersebut otomatis
  /// didorong kembali ke notifikasi lewat [_pushNotificationState] yang
  /// dipantau oleh efek samping (lihat [build]).
  Future<void> _onNotificationAction(NotificationAction action) async {
    switch (action) {
      case NotificationAction.togglePlay:
        await togglePlay();
      case NotificationAction.next:
        await skipNext();
      case NotificationAction.previous:
        await skipPrevious();
      case NotificationAction.mode:
        await cyclePlayMode();
      case NotificationAction.favorite:
        await _toggleCurrentFavorite();
    }
  }

  /// Menandai/menghapus trek aktif sebagai favorit (dipicu tombol
  /// notifikasi — task 3.5).
  Future<void> _toggleCurrentFavorite() async {
    final track = state.currentTrack;
    if (track == null) return;
    await ref.read(favoritesControllerProvider.notifier).toggle(track);
    _pushNotificationState();
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
    unawaited(_persist(state));

    await _dsp.play(
      track.sourcePath,
      title: track.title,
      artist: track.artist,
      artUri: track.artUri,
    );
    await _dsp.setPitch(pitchRatioForFrequency(state.frequencyHz));
    _pushNotificationState();
    unawaited(
      ref.read(recentPlaysControllerProvider.notifier).recordPlay(track),
    );
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
    _pushNotificationState();
  }

  /// Trek berikutnya (skip eksplisit selalu membungkus ke awal).
  Future<void> skipNext() => _skipBy(1, auto: false);

  /// Trek sebelumnya (skip eksplisit selalu membungkus ke akhir).
  Future<void> skipPrevious() => _skipBy(-1, auto: false);

  /// Memajukan antrean sesuai [delta]; [auto] `true` saat dipicu trek
  /// selesai (bukan tombol skip) — mematuhi mode `LoopMode`.
  Future<void> _skipBy(int delta, {required bool auto}) async {
    final queue = state.queue;
    if (queue.isEmpty) return;

    final lastIndex = queue.length - 1;
    final current = state.currentIndex;

    // Repeat one: trek yang sama diputar ulang saat selesai otomatis.
    if (auto && state.repeatMode == LoopMode.one && current >= 0) {
      await playTrack(queue[current], queue: queue);
      return;
    }

    // Acak: pilih trek sembarang yang berbeda dari trek aktif.
    if (state.isShuffling && queue.length > 1) {
      var random = current;
      while (random == current) {
        random = _random.nextInt(queue.length);
      }
      await playTrack(queue[random], queue: queue);
      return;
    }

    var next = current + delta;
    if (auto && next > lastIndex) {
      // Akhir antrean tercapai otomatis: berhenti bila repeat off.
      if (state.repeatMode != LoopMode.all) {
        await stop();
        return;
      }
      next = 0;
    }
    next %= queue.length; // membungkus kedua arah (Dart: % Euclidean)

    await playTrack(queue[next], queue: queue);
  }

  /// Menyalakan/mematikan mode acak (task 2.7).
  ///
  /// Saat aktif, trek berikutnya (baik skip eksplisit maupun setelah trek
  /// selesai) dipilih **sembarang**, berbeda dari trek yang sedang diputar.
  /// Tidak mengubah antrean asli — urutan di sheet antrean tetap, hanya
  /// urutan pemutaran yang diacak.
  void toggleShuffle() {
    state = state.copyWith(isShuffling: !state.isShuffling);
    unawaited(_persist(state));
    _pushNotificationState();
  }

  /// Melompat ke [position].
  Future<void> seekTo(Duration position) async {
    await _dsp.seek(position);
    state = state.copyWith(positionMs: position.inMilliseconds);
  }

  /// Mengganti mode pengulangan: off → all → one → off (task 1.11).
  Future<void> toggleRepeat() async {
    final current = kLoopCycle.indexOf(state.repeatMode);
    final next = kLoopCycle[(current + 1) % kLoopCycle.length];
    state = state.copyWith(repeatMode: next);
    unawaited(_persist(state));
    _pushNotificationState();
  }

  /// Memutar **mode pemutaran gabungan** di notifikasi (task 3.5):
  /// mati → ulang semua → ulang satu → acak → mati.
  ///
  /// Ulang & acak digabung dalam satu tombol "mode" agar semua fungsi muat
  /// di batas 5 slot notifikasi Android 13+ (mini player tetap mengekspos
  /// keduanya sebagai tombol terpisah). State tak-canonical — mis. ulang &
  /// acak aktif bersamaan dari mini player — dinormalisasi oleh
  /// [_playModeIndex] ke mode terdekat dalam siklus.
  Future<void> cyclePlayMode() async {
    final next = (_playModeIndex() + 1) % 4;
    state = state.copyWith(
      repeatMode: switch (next) {
        1 => LoopMode.all,
        2 => LoopMode.one,
        _ => LoopMode.off,
      },
      isShuffling: next == 3,
    );
    unawaited(_persist(state));
    _pushNotificationState();
  }

  /// Indeks mode gabungan: 0 = mati, 1 = ulang semua, 2 = ulang satu,
  /// 3 = acak. Acak diutamakan saat kedua mode aktif bersamaan.
  int _playModeIndex() {
    if (state.isShuffling) return 3;
    return switch (state.repeatMode) {
      LoopMode.all => 1,
      LoopMode.one => 2,
      LoopMode.off => 0,
    };
  }

  /// Mengatur frekuensi penalaan (diterapkan real-time ke mesin native).
  Future<void> setFrequency(double hz) async {
    state = state.copyWith(frequencyHz: hz);
    await _dsp.setPitch(pitchRatioForFrequency(hz));
    unawaited(
      ref.read(settingsControllerProvider.notifier).setDefaultFrequency(hz),
    );
  }

  /// Menghentikan playback sepenuhnya.
  Future<void> stop() async {
    await _dsp.stop();
    _stopPositionTimer();
    state = state.copyWith(isPlaying: false, positionMs: 0);
    _pushNotificationState();
  }

  /// Menjeda playback bila sedang memutar (mis. sleep timer selesai).
  Future<void> pauseIfPlaying() async {
    if (state.isPlaying) await togglePlay();
  }

  /// Memutar trek pada [index] di antrean saat ini (task 2.9).
  Future<void> jumpTo(int index) async {
    final queue = state.queue;
    if (index < 0 || index >= queue.length) return;
    await playTrack(queue[index], queue: queue);
  }

  /// Memutar [track] selanjutnya — menyisipkannya tepat setelah trek
  /// aktif pada antrean saat ini (task 3.5). Bila tidak ada trek aktif,
  /// trek langsung diputar.
  Future<void> playNext(Track track) async {
    final queue = List<Track>.of(state.queue);
    if (queue.isEmpty || state.currentIndex < 0) {
      await playTrack(track);
      return;
    }

    // Lewati bila trek sudah tepat setelah trek aktif.
    final insertAt = state.currentIndex + 1;
    if (insertAt < queue.length && queue[insertAt].id == track.id) return;

    queue.insert(insertAt, track);
    state = state.copyWith(queue: queue);
    unawaited(_persist(state));
  }

  /// Menambahkan [track] ke akhir antrean (task 3.5). Bila antrean kosong,
  /// trek langsung diputar. Trek duplikat diabaikan.
  Future<void> addToQueue(Track track) async {
    final queue = List<Track>.of(state.queue);
    if (queue.isEmpty) {
      await playTrack(track);
      return;
    }
    if (queue.any((item) => item.id == track.id)) return;

    queue.add(track);
    state = state.copyWith(queue: queue);
    unawaited(_persist(state));
  }

  /// Memutar [tracks] dalam urutan acak (task 3.5).
  ///
  /// Mengocok salinan antrean lalu memutar trek pertamanya — trek yang
  /// sama tidak akan terpilih dua kali berturut-turut selama mode acak
  /// aktif (lihat [_skipBy]).
  Future<void> playShuffled(List<Track> tracks) async {
    if (tracks.isEmpty) return;

    final shuffled = List<Track>.of(tracks)..shuffle(_random);
    state = state.copyWith(isShuffling: true);
    unawaited(_persist(state));
    await playTrack(shuffled.first, queue: shuffled);
  }

  /// Memutar trek terakhir yang dimainkan dalam [tracks] (task 3.5).
  ///
  /// Mencari trek [tracks] paling baru yang tercatat di riwayat pemutaran
  /// (lihat [RecentPlaysController]) dan memutarnya. Bila **tidak ada**
  /// trek [tracks] yang pernah diputar, memutar trek pertama secara
  /// berurutan seperti [playTrack] biasa — sesuai permintaan: "berlaku ke
  /// seluruh playlist jika lagunya ada yang diputar terakhir, tetapi jika
  /// tidak ada lagu yang diputar terakhir di playlist tersebut, maka play
  /// berurutan seperti biasa".
  Future<void> playLastPlayed(List<Track> tracks) async {
    if (tracks.isEmpty) return;

    final recents = ref.read(recentPlaysControllerProvider);
    final trackIds = tracks.map((track) => track.id).toSet();

    final lastPlayed = recents
        .where((track) => trackIds.contains(track.id))
        .firstOrNull;
    await playTrack(lastPlayed ?? tracks.first, queue: tracks);
  }

  /// Mengatur ulang antrean via drag (task 2.9).
  ///
  /// Memakai konvensi `ReorderableListView.onReorderItem`: [newIndex] sudah
  /// disesuaikan untuk item yang dihapus dari [oldIndex], sehingga cukup
  /// `removeAt` lalu `insert`. Trek aktif tetap terpilih.
  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    final queue = List<Track>.of(state.queue);
    if (oldIndex < 0 || oldIndex >= queue.length) return;
    if (newIndex < 0 || newIndex > queue.length) return;

    final current = state.currentTrack;
    final moved = queue.removeAt(oldIndex);
    queue.insert(newIndex, moved);

    state = state.copyWith(
      queue: queue,
      currentIndex: current == null ? -1 : queue.indexOf(current),
    );
    unawaited(_persist(state));
  }

  /// Menghapus trek pada [index] dari antrean (task 2.9).
  ///
  /// Bila trek aktif yang dihapus, trek pengganti pada indeks tersebut
  /// diputar; bila antrean jadi kosong, playback dihentikan.
  Future<void> removeFromQueue(int index) async {
    final queue = List<Track>.of(state.queue);
    if (index < 0 || index >= queue.length) return;

    if (index == state.currentIndex) {
      queue.removeAt(index);
      if (queue.isEmpty) {
        await _dsp.stop();
        _stopPositionTimer();
        state = state.copyWith(
          queue: const <Track>[],
          currentIndex: -1,
          isPlaying: false,
        );
        unawaited(_persist(state));
        return;
      }
      final replacement =
          queue[index < queue.length ? index : queue.length - 1];
      await playTrack(replacement, queue: queue);
      return;
    }

    final current = state.currentTrack;
    queue.removeAt(index);
    state = state.copyWith(
      queue: queue,
      currentIndex: current == null ? -1 : queue.indexOf(current),
    );
    unawaited(_persist(state));
  }

  // ── Persistensi antrean (task 1.10) ──────────────────────────────

  /// Membaca antrean tersimpan dari `queueBox` menjadi [PlayerState]
  /// awal dengan frekuensi [frequencyHz].
  ///
  /// Bersifat *inert* (mengembalikan antrean kosong) bila box belum
  /// terbuka, isinya bukan list, atau kosong — sama seperti controller
  /// recents/search history.
  PlayerState _restoreQueue(double frequencyHz) {
    if (!Hive.isBoxOpen(HiveBoxes.queue)) {
      return PlayerState(queue: const <Track>[], frequencyHz: frequencyHz);
    }
    _box = Hive.box<dynamic>(HiveBoxes.queue);

    final tracks = <Track>[];
    final raw = _box?.get(_queueKey);
    if (raw is List) {
      for (final entry in raw) {
        if (entry is! Map) continue;
        final track = TrackMapper.fromJson(Map<String, dynamic>.from(entry));
        if (track != null) tracks.add(track);
      }
    }
    if (tracks.isEmpty) {
      return PlayerState(queue: const <Track>[], frequencyHz: frequencyHz);
    }

    final storedIndex = (_box?.get(_indexKey) as int?) ?? -1;
    final storedRepeat = _box?.get(_repeatKey) as String?;
    final storedShuffle = (_box?.get(_shuffleKey) as bool?) ?? false;
    return PlayerState(
      queue: List<Track>.unmodifiable(tracks),
      // Jaga indeks tetap valid walau antrean menyusut sebelum disimpan.
      currentIndex: storedIndex.clamp(-1, tracks.length - 1),
      repeatMode: LoopMode.values.firstWhere(
        (mode) => mode.name == storedRepeat,
        orElse: () => LoopMode.off,
      ),
      isShuffling: storedShuffle,
      frequencyHz: frequencyHz,
    );
  }

  /// Menyimpan antrean, trek aktif, dan mode pengulangan ke `queueBox`.
  ///
  /// Trek diserialkan via [TrackMapper] (Map murni) sehingga tetap bisa
  /// diputar walau pemindaian MediaStore belum selesai saat aplikasi
  /// dibuka kembali.
  Future<void> _persist(PlayerState value) async {
    final box = _box;
    if (box == null) return;
    await box.putAll(<String, dynamic>{
      _queueKey: value.queue.map(TrackMapper.toJson).toList(growable: false),
      _indexKey: value.currentIndex,
      _repeatKey: value.repeatMode.name,
      _shuffleKey: value.isShuffling,
    });
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
