import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/core/utils/duration_format.dart';
import 'package:lirih/core/utils/pitch_math.dart';
import 'package:lirih/domain/entities/frequency_preset.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/features/player/player_controller.dart';
import 'package:lirih/features/player/player_state.dart';

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
      appBar: AppBar(
        backgroundColor: AppColors.soga800,
        foregroundColor: AppColors.soga50,
        title: const Text('Pemutar'),
      ),
      body: track == null
          ? const _EmptyPlayer()
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _AlbumArt(track: track),
                const SizedBox(height: 20),
                _TrackMeta(track: track),
                const SizedBox(height: 12),
                _ProgressBar(player: player),
                const SizedBox(height: 8),
                _Controls(player: player),
                const SizedBox(height: 28),
                const _FrequencyTuner(),
              ],
            ),
    );
  }
}

/// Placeholder sampul album bila trek belum punya artwork.
class _AlbumArt extends StatelessWidget {
  const _AlbumArt({required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.soga700, AppColors.kunir700],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.music_note, size: 88, color: AppColors.soga50),
      ),
    );
  }
}

/// Judul & artis trek aktif.
class _TrackMeta extends StatelessWidget {
  const _TrackMeta({required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    return Column(
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
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
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
      ],
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
                'Penyetelan frekuensi',
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
            'Geser untuk frekuensi bebas (400–600 Hz). Pitch berubah '
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
