import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/features/player/mini_player.dart';
import 'package:lirih/features/player/player_controller.dart';
import 'package:lirih/shared/widgets/track_row.dart';

/// Layar daftar trek generik untuk *playlist otomatis* seperti "Putar
/// terakhir" dan "Favorit" (task 3.1).
///
/// Berbeda dengan layar detail playlist yang terikat pada sebuah playlist
/// di Hive, layar ini menerima daftar trek secara langsung — sumbernya
/// bisa berubah setiap saat (mis. riwayat pemutaran). Memutar trek
/// menjadikan seluruh daftar sebagai antrean.
class TrackListScreen extends ConsumerWidget {
  /// Membuat layar daftar trek berjudul [title].
  const TrackListScreen({
    required this.title,
    required this.tracks,
    this.icon = Icons.playlist_play,
    super.key,
  });

  /// Judul layar (nama playlist otomatis).
  final String title;

  /// Trek yang ditampilkan.
  final List<Track> tracks;

  /// Ikon pembeda (mis. history untuk Putar terakhir).
  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.soga900,
      appBar: AppBar(
        backgroundColor: AppColors.soga800,
        foregroundColor: AppColors.soga50,
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      // Mini player hidup di MainShell, tetapi layar ini di-push sebagai
      // route penuh yang menutupinya — pasang ulang di sini (task 3.5).
      bottomNavigationBar: const MiniPlayerBottomBar(),
      body: tracks.isEmpty
          ? _EmptyList(icon: icon, title: title)
          : ListView(
              children: [
                _Header(
                  title: title,
                  count: tracks.length,
                  icon: icon,
                  onPlay: () => ref
                      .read(playerControllerProvider.notifier)
                      .playTrack(tracks.first, queue: tracks),
                ),
                const Divider(color: AppColors.soga700, height: 1),
                ...tracks.map((track) => TrackRow(track: track, queue: tracks)),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

/// Bagian kepala: ikon besar, judul, jumlah trek, dan tombol putar semua.
class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.count,
    required this.icon,
    required this.onPlay,
  });

  final String title;

  final int count;

  final IconData icon;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.soga850,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.nila600, width: 1.5),
            ),
            child: Icon(icon, color: AppColors.nila400, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.soga50,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count trek',
                  style: const TextStyle(
                    color: AppColors.soga400,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: onPlay,
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Putar semua'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.kunir600,
                    foregroundColor: AppColors.soga50,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pesan saat playlist otomatis masih kosong.
class _EmptyList extends StatelessWidget {
  const _EmptyList({required this.icon, required this.title});

  final IconData icon;

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.soga400),
            const SizedBox(height: 16),
            Text(
              '"$title" masih kosong.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.soga200, fontSize: 15),
            ),
            const SizedBox(height: 4),
            const Text(
              'Putar sebuah lagu untuk mengisinya.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.soga400, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
