import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/core/constants/app_motion.dart';
import 'package:lirih/core/utils/duration_format.dart';
import 'package:lirih/core/utils/pitch_math.dart';
import 'package:lirih/domain/entities/frequency_preset.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/features/favorites/favorites_controller.dart';
import 'package:lirih/features/lyrics/lyrics_panel.dart';
import 'package:lirih/features/player/player_controller.dart';
import 'package:lirih/features/player/player_state.dart';
import 'package:lirih/features/player/queue_sheet.dart';
import 'package:lirih/features/player/repeat_mode.dart';
import 'package:lirih/features/player/sleep_timer_controller.dart';
import 'package:lirih/features/player/track_info_sheet.dart';
import 'package:lirih/shared/widgets/switching_icon.dart';
import 'package:lirih/shared/widgets/track_artwork.dart';

/// Membuka layar Pemutar penuh dengan transisi **naik dari bawah**.
///
/// Pemutar adalah layar "sekarang diputar" khas aplikasi musik: alih-alih
/// mendorong layar lama ke samping (bawaan Android), layar ini meluncur
/// naik menutupi shell — terasa seperti mengambil lagu yang sedang berjalan
/// keluar dari mini player. Lihat [AppMotion.route].
void openPlayerScreen(BuildContext context) {
  Navigator.of(context).push<void>(
    PageRouteBuilder<void>(
      transitionDuration: AppMotion.route,
      reverseTransitionDuration: AppMotion.medium,
      pageBuilder: (context, animation, secondaryAnimation) =>
          const PlayerScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: AppMotion.easeOut,
          reverseCurve: AppMotion.easeIn,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curved),
          // Pudar ringan agar batas atas layar tidak terasa "menyapu".
          child: FadeTransition(opacity: curved, child: child),
        );
      },
    ),
  );
}

/// Layar Pemutar (task 2.7) + **penyetel frekuensi** 440/432/528 Hz
/// (task 2.8) — fitur pembeda Lirih.
///
/// Seluruh status dibaca dari [PlayerController]; kontrol memanggil
/// method-nya. Penyetel diterapkan real-time ke mesin native tanpa
/// mengubah tempo.
class PlayerScreen extends ConsumerWidget {
  /// Membuat layar Pemutar.
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerControllerProvider);
    final track = player.currentTrack;

    return Scaffold(
      backgroundColor: AppColors.soga900,
      // appBar: AppBar(
      //   backgroundColor: AppColors.soga800,
      //   foregroundColor: AppColors.soga50,
      //   title: const Text('Pemutar'),
      // ),
      body: track == null
          ? const _EmptyPlayer()
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Silang-pudar antara sampul dan panel lirik — keduanya
                // berbentuk persegi (rasio 1) sehingga tinggi ListView
                // tidak melonjak saat bertukar.
                AnimatedSwitcher(
                  duration: AppMotion.medium,
                  switchInCurve: AppMotion.easeOut,
                  switchOutCurve: AppMotion.easeIn,
                  child: ref.watch(lyricsVisibilityProvider)
                      ? const AspectRatio(
                          key: ValueKey('lyrics'),
                          aspectRatio: 1,
                          child: LyricsPanel(),
                        )
                      : _AlbumArt(
                          key: ValueKey('artwork-${track.id}'),
                          track: track,
                        ),
                ),
                const SizedBox(height: 20),
                _TrackMeta(track: track),
                const SizedBox(height: 12),
                _ProgressBar(player: player),
                const SizedBox(height: 8),
                _Controls(player: player),
                const SizedBox(height: 4),
                const _PlayerActions(),
                const SizedBox(height: 28),
                const _FrequencyTuner(),
              ],
            ),
    );
  }
}

/// Baris aksi tambahan: favorit, antrean, lirik, sleep timer, dan info
/// lagu — ikon saja agar ringkas (task 3.1 & 3.5).
class _PlayerActions extends StatelessWidget {
  const _PlayerActions();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _FavoriteButton(),
        _QueueButton(),
        _LyricsButton(),
        _SleepTimerButton(),
        _TrackInfoButton(),
      ],
    );
  }
}

/// Tombol membuka sheet info lagu lengkap (judul, artis, album, trek,
/// durasi, format, frekuensi, ukuran, berkas, folder) plus aksi edit —
/// task 3.5.
class _TrackInfoButton extends ConsumerWidget {
  const _TrackInfoButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = ref.watch(playerControllerProvider).currentTrack;
    if (track == null) return const SizedBox.shrink();

    return IconButton(
      tooltip: 'Info lagu',
      onPressed: () => showTrackInfoSheet(context, track),
      icon: const Icon(Icons.more_vert, color: AppColors.soga200),
    );
  }
}

/// Tombol menandai trek aktif sebagai favorit (task 3.1).
class _FavoriteButton extends ConsumerWidget {
  const _FavoriteButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = ref.watch(playerControllerProvider).currentTrack;
    if (track == null) return const SizedBox.shrink();

    final isFavorite = ref
        .watch(favoritesControllerProvider)
        .any((favorite) => favorite.id == track.id);
    final notifier = ref.read(favoritesControllerProvider.notifier);

    return IconButton(
      tooltip: isFavorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
      onPressed: () => notifier.toggle(track),
      icon: SwitchingIcon(
        icon: isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? AppColors.kunir500 : AppColors.soga200,
        size: 22,
      ),
    );
  }
}

/// Tombol membuka sheet antrean (task 2.9).
class _QueueButton extends StatelessWidget {
  const _QueueButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Antrean',
      onPressed: () => showQueueSheet(context),
      icon: const Icon(Icons.queue_music, color: AppColors.soga200, size: 22),
    );
  }
}

/// Tombol memunculkan/menyembunyikan panel lirik (task 3.3).
class _LyricsButton extends ConsumerWidget {
  const _LyricsButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(lyricsVisibilityProvider);
    final notifier = ref.read(lyricsVisibilityProvider.notifier);

    return IconButton(
      tooltip: 'Lirik',
      onPressed: notifier.toggle,
      icon: SwitchingIcon(
        icon: visible ? Icons.lyrics : Icons.lyrics_outlined,
        color: visible ? AppColors.nila400 : AppColors.soga200,
        size: 22,
      ),
    );
  }
}

/// Sleep timer — pilih durasi; playback dijeda otomatis saat habis (2.9).
class _SleepTimerButton extends ConsumerWidget {
  const _SleepTimerButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining = ref.watch(sleepTimerControllerProvider);
    final notifier = ref.read(sleepTimerControllerProvider.notifier);
    final active = remaining != null;

    return PopupMenuButton<int>(
      tooltip: 'Sleep timer',
      onSelected: (minutes) {
        if (minutes == 0) {
          notifier.cancel();
        } else {
          notifier.start(Duration(minutes: minutes));
        }
      },
      itemBuilder: (_) => <PopupMenuEntry<int>>[
        const PopupMenuItem<int>(value: 0, child: Text('Mati')),
        ...kSleepTimerMinutes.map(
          (minutes) =>
              PopupMenuItem<int>(value: minutes, child: Text('$minutes menit')),
        ),
      ],
      child: Badge(
        isLabelVisible: active,
        backgroundColor: AppColors.kunir600,
        label: active
            ? Text(
                '${remaining.inMinutes}',
                style: const TextStyle(color: AppColors.soga50, fontSize: 10),
              )
            : const SizedBox.shrink(),
        child: Icon(
          active ? Icons.timer : Icons.timer_outlined,
          color: active ? AppColors.kunir500 : AppColors.soga200,
          size: 22,
        ),
      ),
    );
  }
}

/// Sampul album trek aktif (task 3.4) — ukuran penuh sesuai lebar layar.
class _AlbumArt extends StatelessWidget {
  const _AlbumArt({required this.track, super.key});

  final Track track;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        return TrackArtwork(track: track, size: size);
      },
    );
  }
}

/// Judul & artis trek aktif.
class _TrackMeta extends StatelessWidget {
  const _TrackMeta({required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    // Silang-pudar judul/artis saat lagu berganti — durasi & tinggi teks
    // hampir selalu sama, jadi lonjakan tinggi saat transisi minim.
    return AnimatedSwitcher(
      duration: AppMotion.fast,
      switchInCurve: AppMotion.easeOut,
      switchOutCurve: AppMotion.easeIn,
      child: Column(
        key: ValueKey(track.id),
        children: [
          Text(
            track.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.soga50,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            track.artist,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.soga300, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

/// Slider progres + label posisi/durasi.
class _ProgressBar extends ConsumerWidget {
  const _ProgressBar({required this.player});

  final PlayerState player;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positionMs = player.positionMs;
    final durationMs = player.durationMs;
    final duration = durationMs > 0 ? durationMs : 1;

    return Row(
      children: [
        Text(
          formatTrackDuration(positionMs),
          style: const TextStyle(color: AppColors.soga300, fontSize: 12),
        ),
        Expanded(
          child: Slider(
            value: positionMs.clamp(0, duration).toDouble(),
            max: duration.toDouble(),
            activeColor: AppColors.kunir500,
            thumbColor: AppColors.kunir400,
            onChanged: (value) => ref
                .read(playerControllerProvider.notifier)
                .seekTo(Duration(milliseconds: value.toInt())),
          ),
        ),
        Text(
          formatTrackDuration(durationMs),
          style: const TextStyle(color: AppColors.soga300, fontSize: 12),
        ),
      ],
    );
  }
}

/// Tombol putar/jeda, sebelumnya, berikutnya.
class _Controls extends ConsumerWidget {
  const _Controls({required this.player});

  final PlayerState player;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = player.isPlaying;
    final notifier = ref.read(playerControllerProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _ShuffleButton(),
        const SizedBox(width: 8),
        IconButton(
          onPressed: notifier.skipPrevious,
          icon: const Icon(Icons.skip_previous),
          color: AppColors.soga50,
          iconSize: 40,
        ),
        const SizedBox(width: 16),
        Container(
          decoration: const BoxDecoration(
            color: AppColors.kunir500,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: notifier.togglePlay,
            icon: SwitchingIcon(
              icon: isPlaying ? Icons.pause : Icons.play_arrow,
              color: AppColors.soga950,
              size: 44,
            ),
            color: AppColors.soga950,
            iconSize: 44,
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: notifier.skipNext,
          icon: const Icon(Icons.skip_next),
          color: AppColors.soga50,
          iconSize: 40,
        ),
        const SizedBox(width: 8),
        const _RepeatButton(),
      ],
    );
  }
}

/// Tombol mode acak: trek berikutnya dipilih sembarang (task 2.7).
class _ShuffleButton extends ConsumerWidget {
  const _ShuffleButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isShuffling = ref.watch(
      playerControllerProvider.select((state) => state.isShuffling),
    );
    final notifier = ref.read(playerControllerProvider.notifier);

    return IconButton(
      onPressed: notifier.toggleShuffle,
      icon: const Icon(Icons.shuffle),
      color: isShuffling ? AppColors.kunir500 : AppColors.soga300,
      iconSize: 26,
      tooltip: isShuffling ? 'Acak: aktif' : 'Acak: mati',
    );
  }
}

/// Tombol mode pengulangan: off → all → one (task 1.11).
class _RepeatButton extends ConsumerWidget {
  const _RepeatButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(
      playerControllerProvider.select((state) => state.repeatMode),
    );
    final notifier = ref.read(playerControllerProvider.notifier);
    final active = mode != LoopMode.off;

    return IconButton(
      onPressed: notifier.toggleRepeat,
      icon: SwitchingIcon(
        icon: mode == LoopMode.one ? Icons.repeat_one : Icons.repeat,
        color: active ? AppColors.kunir500 : AppColors.soga300,
        size: 26,
      ),
      color: active ? AppColors.kunir500 : AppColors.soga300,
      iconSize: 26,
      tooltip: mode == LoopMode.off
          ? 'Ulang: mati'
          : mode == LoopMode.all
          ? 'Ulang: semua trek'
          : 'Ulang: satu trek',
    );
  }
}

/// Penyetel frekuensi — preset 440/432/528 Hz + slider kontinu (task 2.8).
class _FrequencyTuner extends ConsumerWidget {
  const _FrequencyTuner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerControllerProvider);
    final notifier = ref.read(playerControllerProvider.notifier);
    final hz = player.frequencyHz;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.soga850,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.nila600, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Set Frekuensi (Hz)',
                style: TextStyle(
                  color: AppColors.soga100,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${centsOffsetForFrequency(hz) >= 0 ? '+' : ''}'
                '${centsOffsetForFrequency(hz).toStringAsFixed(1)} cents',
                style: const TextStyle(color: AppColors.nila400, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${hz.toStringAsFixed(hz == hz.roundToDouble() ? 0 : 1)} Hz',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.kunir500,
              fontSize: 34,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: FrequencyPreset.builtins.map((preset) {
              final selected = (hz - preset.frequencyHz).abs() < 0.5;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilledButton(
                    onPressed: () => notifier.setFrequency(preset.frequencyHz),
                    style: FilledButton.styleFrom(
                      backgroundColor: selected
                          ? AppColors.nila500
                          : AppColors.soga700,
                      foregroundColor: AppColors.soga50,
                    ),
                    child: Text(
                      preset.frequencyHz.toStringAsFixed(0),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Slider(
            value: hz.clamp(kMinFrequencyHz, kMaxFrequencyHz),
            min: kMinFrequencyHz,
            max: kMaxFrequencyHz,
            divisions: 200,
            activeColor: AppColors.nila500,
            thumbColor: AppColors.nila400,
            label: '${hz.toStringAsFixed(0)} Hz',
            onChanged: notifier.setFrequency,
          ),
          const Text(
            'Geser untuk frekuensi bebas (400–600 Hz). "Pitch berubah" '
            'real-time tanpa mengubah tempo.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.soga400, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Tampilan saat belum ada trek yang diputar.
class _EmptyPlayer extends StatelessWidget {
  const _EmptyPlayer();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_circle_outline, size: 72, color: AppColors.soga400),
          SizedBox(height: 16),
          Text(
            'Belum ada lagu yang diputar.',
            style: TextStyle(color: AppColors.soga200, fontSize: 15),
          ),
          SizedBox(height: 4),
          Text(
            'Buka tab Pustaka dan pilih sebuah lagu.',
            style: TextStyle(color: AppColors.soga400, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
