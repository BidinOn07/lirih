import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/core/utils/pitch_math.dart';
import 'package:lirih/domain/entities/frequency_preset.dart';
import 'package:lirih/domain/entities/playlist.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/features/favorites/favorites_controller.dart';
import 'package:lirih/features/home/recent_plays_controller.dart';
import 'package:lirih/features/library/library_scan_controller.dart';
import 'package:lirih/features/player/player_controller.dart';
import 'package:lirih/features/playlists/playlist_detail_screen.dart';
import 'package:lirih/features/playlists/playlists_controller.dart';
import 'package:lirih/features/playlists/track_list_screen.dart';
import 'package:lirih/features/settings/settings_screen.dart';
import 'package:lirih/shared/widgets/track_row.dart';

/// Layar Beranda (task 2.6) — titik mula aplikasi.
///
/// Menampilkan **penyetel frekuensi** (preset 440/432/528 Hz, bisa diubah
/// langsung), tombol **Acak semua** di bawahnya, **grid daftar putar**
/// (Putar terakhir, Favorit, dan playlist yang paling sering diputar —
/// dinamis berdasarkan playlist yang sudah dibuat/diimpor), serta
/// **seluruh lagu yang ada di perangkat**.
class HomeScreen extends ConsumerWidget {
  /// Membuat layar Beranda.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref
        .watch(libraryScanControllerProvider)
        .maybeWhen(data: (tracks) => tracks, orElse: () => const <Track>[]);

    return Scaffold(
      backgroundColor: AppColors.soga900,
      appBar: AppBar(
        backgroundColor: AppColors.soga800,
        foregroundColor: AppColors.soga50,
        title: const Text('Lirih'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Pengaturan',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FrequencyCard(),
                  const SizedBox(height: 16),
                  _ShuffleAll(library: library),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: _PlaylistsGrid(library: library)),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          if (library.isEmpty)
            const SliverToBoxAdapter(
              child: _SectionHint(
                icon: Icons.library_music_outlined,
                text:
                    'Belum ada lagu di perangkat. Buka tab Pustaka untuk '
                    'memindai.',
              ),
            )
          else ...[
            const SliverToBoxAdapter(child: _AllSongsHeader()),
            SliverList.separated(
              itemCount: library.length,
              separatorBuilder: (_, _) =>
                  const Divider(color: AppColors.soga700, height: 1),
              itemBuilder: (context, index) {
                final track = library[index];
                return TrackRow(track: track, queue: library);
              },
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

/// Kartu frekuensi penalaan aktif — tanda tangan Lirih. Tombol preset
/// 440/432/528 Hz mengubah frekuensi langsung dari Beranda (task 2.8).
class _FrequencyCard extends ConsumerWidget {
  const _FrequencyCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerControllerProvider);
    final notifier = ref.read(playerControllerProvider.notifier);
    final hz = player.frequencyHz;
    final cents = centsOffsetForFrequency(hz);
    final preset = FrequencyPreset.builtins
        .where((p) => (p.frequencyHz - hz).abs() < 0.5)
        .firstOrNull;

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
            children: [
              const Icon(Icons.tune, color: AppColors.nila400, size: 24),
              const SizedBox(width: 10),
              const Text(
                'Preset Frequency',
                style: TextStyle(color: AppColors.soga200, fontSize: 13),
              ),
              const Spacer(),
              Text(
                '${cents >= 0 ? '+' : ''}${cents.toStringAsFixed(1)} cents',
                style: const TextStyle(color: AppColors.nila400, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${hz.toStringAsFixed(hz == hz.roundToDouble() ? 0 : 1)} Hz'
            '${preset != null ? ' · ${preset.name}' : ''}',
            style: const TextStyle(
              color: AppColors.kunir500,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: FrequencyPreset.builtins.map((preset) {
              final selected = (hz - preset.frequencyHz).abs() < 0.5;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: FilledButton(
                    onPressed: () => notifier.setFrequency(preset.frequencyHz),
                    style: FilledButton.styleFrom(
                      backgroundColor: selected
                          ? AppColors.nila500
                          : AppColors.soga700,
                      foregroundColor: AppColors.soga50,
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
        ],
      ),
    );
  }
}

/// Tombol besar "Acak semua" — memutar pustaka dalam urutan acak.
class _ShuffleAll extends ConsumerWidget {
  const _ShuffleAll({required this.library});

  final List<Track> library;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = library.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: enabled
            ? () {
                final shuffled = List<Track>.of(library)..shuffle();
                unawaited(
                  ref
                      .read(playerControllerProvider.notifier)
                      .playTrack(shuffled.first, queue: shuffled),
                );
              }
            : null,
        icon: const Icon(Icons.shuffle),
        label: const Text(
          'Acak semua',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.kunir600,
          foregroundColor: AppColors.soga50,
          disabledBackgroundColor: AppColors.soga700,
          disabledForegroundColor: AppColors.soga400,
        ),
      ),
    );
  }
}

/// Grid "Daftar putar" 2 baris × 4 kolom: **Putar terakhir** & **Favorit**
/// (playlist otomatis) di depan, disusul playlist yang paling sering
/// diputar — dinamis dari playlist yang sudah dibuat/diimpor (task 3.1).
class _PlaylistsGrid extends ConsumerWidget {
  const _PlaylistsGrid({required this.library});

  /// Pustaka lengkap (untuk menghitung jumlah trek konteks bila perlu).
  final List<Track> library;

  /// Urutan playlist: yang terakhir diputar di depan, sisanya urutan buat.
  List<Playlist> _byMostPlayed(List<Playlist> playlists) {
    final sorted = [...playlists]
      ..sort((a, b) {
        final av = a.lastPlayedAt;
        final bv = b.lastPlayedAt;
        if (av == null && bv == null) return 0;
        if (av == null) return 1;
        if (bv == null) return -1;
        return bv.compareTo(av);
      });
    return sorted;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recents = ref.watch(recentPlaysControllerProvider);
    final favorites = ref.watch(favoritesControllerProvider);
    final playlists = ref.watch(playlistsControllerProvider);

    // Maks 8 sel (2 baris × 4 kolom): 2 playlist otomatis + 6 terakhir diputar.
    final mostPlayed = _byMostPlayed(playlists).take(6).toList();

    final items = <_GridCardData>[
      _GridCardData(
        title: 'Putar terakhir',
        subtitle: '${recents.length} trek',
        icon: Icons.history,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => TrackListScreen(
              title: 'Putar terakhir',
              tracks: recents,
              icon: Icons.history,
            ),
          ),
        ),
      ),
      _GridCardData(
        title: 'Favorit',
        subtitle: '${favorites.length} trek',
        icon: Icons.favorite,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => TrackListScreen(
              title: 'Favorit',
              tracks: favorites,
              icon: Icons.favorite,
            ),
          ),
        ),
      ),
      ...mostPlayed.map(
        (playlist) => _GridCardData(
          title: playlist.name,
          subtitle: '${playlist.length} trek',
          icon: Icons.queue_music,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => PlaylistDetailScreen(playlistId: playlist.id),
            ),
          ),
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daftar putar',
            style: TextStyle(
              color: AppColors.soga100,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.72,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _PlaylistGridCard(data: item);
            },
          ),
        ],
      ),
    );
  }
}

/// Data satu kartu grid daftar putar.
class _GridCardData {
  const _GridCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;

  final String subtitle;

  final IconData icon;

  final VoidCallback onTap;
}

/// Satu kartu grid (4 kolom — kompak: ikon, nama, jumlah trek).
class _PlaylistGridCard extends StatelessWidget {
  const _PlaylistGridCard({required this.data});

  final _GridCardData data;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.soga850,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(data.icon, color: AppColors.nila400, size: 22),
            const SizedBox(height: 6),
            Text(
              data.title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.soga50,
                fontSize: 11,
                height: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              data.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.soga400, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

/// Judul bagian "Semua lagu" + jumlah trek terimpor.
class _AllSongsHeader extends ConsumerWidget {
  const _AllSongsHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref
        .watch(libraryScanControllerProvider)
        .maybeWhen(data: (tracks) => tracks.length, orElse: () => 0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      child: Row(
        children: [
          const Text(
            'Semua lagu',
            style: TextStyle(
              color: AppColors.soga100,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count trek',
            style: const TextStyle(color: AppColors.soga400, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Satu baris trek di daftar "Semua lagu".
/// Pesan kosong untuk sebuah bagian.
class _SectionHint extends StatelessWidget {
  const _SectionHint({required this.icon, required this.text});

  final IconData icon;

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        children: [
          Icon(icon, color: AppColors.soga400, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.soga300, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
