import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/features/player/player_controller.dart';
import 'package:lirih/features/player/player_screen.dart';
import 'package:lirih/features/player/repeat_mode.dart';
import 'package:lirih/features/player/track_info_sheet.dart';
import 'package:lirih/shared/widgets/track_artwork.dart';

/// Bar pemutar ringkas yang muncul di atas navigasi bawah (task 2.7).
///
/// Bar ini **hanya tampil saat ada trek aktif** — muncul otomatis begitu
/// pengguna memutar lagu dari tab mana pun, dan hilang saat antrean
/// dikosongkan. Menekan bar (di luar tombol aksi) membuka layar Pemutar
/// penuh; tombol aksi memberi kontrol cepat tanpa berpindah layar:
/// acak, sebelumnya, putar/jeda, berikutnya, mode pengulangan, dan info
/// lagu (tombol opsi).
class MiniPlayerBar extends ConsumerWidget {
  /// Membuat bar [MiniPlayerBar].
  const MiniPlayerBar({required this.onOpenPlayer, super.key});

  /// Dipanggil saat bar ditekan (membuka layar Pemutar penuh).
  final VoidCallback onOpenPlayer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerControllerProvider);
    final track = player.currentTrack;
    if (track == null) return const SizedBox.shrink();

    final notifier = ref.read(playerControllerProvider.notifier);

    return Material(
      color: AppColors.soga800,
      child: InkWell(
        onTap: onOpenPlayer,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
          child: Row(
            children: [
              TrackArtwork(track: track, size: 52),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.soga50,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      track.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.soga300,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _MiniIconButton(
                icon: Icons.shuffle,
                iconSize: 16,
                active: player.isShuffling,
                tooltip: player.isShuffling ? 'Acak: aktif' : 'Acak: mati',
                onPressed: notifier.toggleShuffle,
              ),
              _MiniIconButton(
                icon: Icons.skip_previous_rounded,
                iconSize: 22,
                tooltip: 'Sebelumnya',
                onPressed: notifier.skipPrevious,
              ),
              _MiniIconButton(
                icon: player.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                iconSize: 26,
                primary: true,
                tooltip: player.isPlaying ? 'Jeda' : 'Putar',
                onPressed: notifier.togglePlay,
              ),
              _MiniIconButton(
                icon: Icons.skip_next_rounded,
                iconSize: 22,
                tooltip: 'Berikutnya',
                onPressed: notifier.skipNext,
              ),
              _MiniIconButton(
                icon: player.repeatMode == LoopMode.one
                    ? Icons.repeat_one_rounded
                    : Icons.repeat_rounded,
                iconSize: 16,
                active: player.repeatMode != LoopMode.off,
                tooltip: player.repeatMode == LoopMode.off
                    ? 'Ulang: mati'
                    : player.repeatMode == LoopMode.all
                    ? 'Ulang: semua trek'
                    : 'Ulang: satu trek',
                onPressed: notifier.toggleRepeat,
              ),
              _MiniIconButton(
                icon: Icons.more_vert,
                iconSize: 18,
                tooltip: 'Info lagu',
                onPressed: () => showTrackInfoSheet(context, track),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tombol ikon ukuran kompak untuk bar mini player.
///
/// Ukuran default [IconButton] (48 dp) terlalu lebar untuk enam tombol
/// sekaligus; tombol ini dipadatkan agar muat tanpa terasa sempit.
class _MiniIconButton extends StatelessWidget {
  /// Membuat tombol [icon] dengan handler [onPressed].
  const _MiniIconButton({
    required this.icon,
    required this.iconSize,
    required this.onPressed,
    this.active = false,
    this.primary = false,
    this.tooltip,
  });

  /// Ikon yang ditampilkan.
  final IconData icon;

  /// Ukuran ikon dalam dp.
  final double iconSize;

  /// Handler saat ditekan.
  final VoidCallback onPressed;

  /// `true` bila fitur sedang aktif (acak/pengulangan) — ikon berwarna kunir.
  final bool active;

  /// `true` bila ini tombol utama (putar/jeda) — ikon berwarna kunir.
  final bool primary;

  /// Tooltip aksesibilitas.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final color = (active || primary) ? AppColors.kunir400 : AppColors.soga200;

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      iconSize: iconSize,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 30, minHeight: 40),
    );
  }
}

/// Versi [MiniPlayerBar] yang siap dipasang di `bottomNavigationBar` layar
/// detail (task 3.5).
///
/// Layar detail seperti album, artis, dan playlist di-push sebagai route
/// penuh yang menutupi shell utama — padahal mini player hidup di sana.
/// Tanpa widget ini, mini player tidak muncul di layar tersebut walau ada
/// trek aktif. Widget ini membuka layar Pemutar sendiri lewat Navigator,
/// sehingga mini player tetap sinkron di mana pun trek dimainkan.
class MiniPlayerBottomBar extends StatelessWidget {
  /// Membuat bar untuk dipasang di `bottomNavigationBar`.
  const MiniPlayerBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return MiniPlayerBar(
      onOpenPlayer: () => Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => const PlayerScreen())),
    );
  }
}
