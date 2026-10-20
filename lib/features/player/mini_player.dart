import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/core/constants/app_motion.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/features/favorites/favorites_controller.dart';
import 'package:lirih/features/player/player_controller.dart';
import 'package:lirih/features/player/player_screen.dart';
import 'package:lirih/features/player/repeat_mode.dart';
import 'package:lirih/shared/widgets/switching_icon.dart';
import 'package:lirih/shared/widgets/track_artwork.dart';

/// Bar pemutar ringkas yang muncul di atas navigasi bawah (task 2.7).
///
/// Menekan bar (di luar tombol aksi) membuka layar Pemutar penuh; tombol
/// aksi memberi kontrol cepat tanpa berpindah layar: favorit, acak,
/// sebelumnya, putar/jeda, berikutnya, dan mode pengulangan.
///
/// [track] disuplai oleh pemanggil (lihat [MiniPlayerBottomBar]) — bukan
/// dibaca sendiri dari provider — sehingga saat trek terakhir dihapus,
/// bar yang sedang memudar keluar tetap menampilkan lagunya sampai
/// animasi selesai, bukan mendadak kosong.
class MiniPlayerBar extends ConsumerWidget {
  /// Membuat bar [MiniPlayerBar] untuk [track].
  const MiniPlayerBar({
    required this.track,
    required this.onOpenPlayer,
    super.key,
  });

  /// Trek yang ditampilkan.
  final Track track;

  /// Dipanggil saat bar ditekan (membuka layar Pemutar penuh).
  final VoidCallback onOpenPlayer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerControllerProvider);
    final notifier = ref.read(playerControllerProvider.notifier);
    final favorites = ref.watch(favoritesControllerProvider);
    final isFavorite = favorites.any((item) => item.id == track.id);

    return Material(
      color: AppColors.soga800,
      child: InkWell(
        onTap: onOpenPlayer,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 6, 12),
          child: Row(
            children: [
              // Silang-pudar sampul + judul saat lagu berganti.
              Expanded(
                child: AnimatedSwitcher(
                  duration: AppMotion.fast,
                  switchInCurve: AppMotion.easeOut,
                  switchOutCurve: AppMotion.easeIn,
                  child: Row(
                    key: ValueKey(track.id),
                    children: [
                      TrackArtwork(track: track, size: 56),
                      const SizedBox(width: 12),
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
                    ],
                  ),
                ),
              ),
              _MiniIconButton(
                icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                iconSize: 18,
                active: isFavorite,
                tooltip: isFavorite
                    ? 'Hapus dari favorit'
                    : 'Tambah ke favorit',
                onPressed: () => ref
                    .read(favoritesControllerProvider.notifier)
                    .toggle(track),
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
      // [SwitchingIcon] memudar + mengecil saat ikon bertukar (putar/jeda,
      // favorit, ulang-satu). Ikon yang tidak berubah tetap sama tanpa
      // memicu animasi ulang.
      icon: SwitchingIcon(icon: icon, color: color, size: iconSize),
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
///
/// Mengawasi [PlayerController] sendiri: seluruh widget (termasuk garis
/// pemisah [DecoratedBox]) ikut hilang saat tidak ada trek aktif —
/// bila hanya isinya yang disembunyikan, `DecoratedBox` yang ditinggalkan
/// tetap menggambar border tipis di bagian bawah layar.
///
/// **Animasi:** bar naik dari balik [NavigationBar] saat trek mulai diputar
/// ([SizeTransition] memotong tinggi dari sisi atas + [FadeTransition]),
/// dan menyusut kembali saat antrean dikosongkan. Kunci yang berbeda
/// antara "ada bar" dan "kosong" membuat [AnimatedSwitcher] benar-benar
/// memulai animasi; rebuild biasa (posisi pemutar tiap tick) memakai kunci
/// yang sama sehingga animasi tidak diulang. Bar yang sedang memudar keluar
/// disimpan [AnimatedSwitcher] apa adanya, sehingga ia tetap menampilkan
/// trek terakhir sampai animasi selesai.
class MiniPlayerBottomBar extends ConsumerWidget {
  /// Membuat bar untuk dipasang di `bottomNavigationBar`.
  const MiniPlayerBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = ref.watch(
      playerControllerProvider.select((state) => state.currentTrack),
    );

    return AnimatedSwitcher(
      duration: AppMotion.medium,
      switchInCurve: AppMotion.easeOut,
      switchOutCurve: AppMotion.easeIn,
      transitionBuilder: (child, animation) => SizeTransition(
        sizeFactor: animation,
        // Sisi bawah menempel di puncak NavigationBar, sisi atas naik —
        // bar terasa "keluar" dari balik navigasi, bukan menjorok ke bawah.
        alignment: Alignment.topLeft,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: track != null
          ? DecoratedBox(
              key: const ValueKey('mini-player'),
              // Beri garis pemisah tipis agar mini player tidak menyatu
              // dengan konten detail di atasnya.
              decoration: const BoxDecoration(
                color: AppColors.soga800,
                border: Border(
                  top: BorderSide(color: AppColors.soga700, width: 0.5),
                ),
              ),
              child: MiniPlayerBar(
                track: track,
                onOpenPlayer: () => openPlayerScreen(context),
              ),
            )
          : const SizedBox.shrink(key: ValueKey('mini-player-empty')),
    );
  }
}
