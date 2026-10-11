import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/features/library/library_scan_controller.dart';
import 'package:lirih/features/search/search_history_controller.dart';
import 'package:lirih/shared/widgets/track_row.dart';

/// Layar Pencarian (task 3.5) — menyaring trek pustaka berdasarkan judul,
/// artis, atau album.
///
/// Saat kosong, menampilkan riwayat pencarian dan **hasil pencarian
/// terakhir** (lagu yang terakhir dicari dan diputar melalui pencarian),
/// keduanya tersimpan di Hive. Hasil pencarian membentuk antrean pemutaran
/// sehingga lagu yang cocok dapat diputar berurutan.
class SearchScreen extends ConsumerStatefulWidget {
  /// Membuat layar Pencarian.
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _field = TextEditingController();

  String _query = '';

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  /// Trek yang cocok [_query] (case-insensitive) pada judul/artis/album.
  List<Track> _filter(List<Track> tracks, String query) {
    final needle = query.toLowerCase();
    return tracks
        .where(
          (track) =>
              track.title.toLowerCase().contains(needle) ||
              track.artist.toLowerCase().contains(needle) ||
              (track.album?.toLowerCase().contains(needle) ?? false),
        )
        .toList(growable: false);
  }

  /// Menyimpan kueri ke riwayat dan hasilnya sebagai "terakhir dicari".
  void _submit() {
    final trimmed = _query.trim();
    if (trimmed.isEmpty) return;
    final notifier = ref.read(searchHistoryControllerProvider.notifier);
    final tracks = ref
        .read(libraryScanControllerProvider)
        .maybeWhen(data: (t) => t, orElse: () => const <Track>[]);
    unawaited(notifier.add(trimmed));
    unawaited(notifier.saveResults(trimmed, _filter(tracks, trimmed)));
  }

  /// Mengisi kolom dengan [value] dan langsung menyaring.
  void _applyQuery(String value) {
    _field.text = value;
    _field.selection = TextSelection.collapsed(offset: value.length);
    setState(() => _query = value);
  }

  @override
  Widget build(BuildContext context) {
    final scan = ref.watch(libraryScanControllerProvider);
    final history = ref.watch(searchHistoryControllerProvider);
    final notifier = ref.read(searchHistoryControllerProvider.notifier);
    final tracks = scan.maybeWhen(
      data: (tracks) => tracks,
      orElse: () => const <Track>[],
    );
    final results = _query.isEmpty ? const <Track>[] : _filter(tracks, _query);

    return Scaffold(
      backgroundColor: AppColors.soga900,
      appBar: AppBar(
        backgroundColor: AppColors.soga800,
        foregroundColor: AppColors.soga50,
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          // Kolom pencarian diletakkan di body dengan ruang yang lega,
          // bukan menempel di puncak layar.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _SearchField(
              controller: _field,
              onChanged: (value) => setState(() => _query = value),
              onSubmit: _submit,
            ),
          ),
          Expanded(
            child: _query.isEmpty
                ? _SearchHome(
                    history: history,
                    lastSearch: notifier.lastSearch,
                    onTapQuery: _applyQuery,
                  )
                : results.isEmpty
                ? _Hint(text: 'Tidak ada lagu yang cocok dengan "$_query".')
                : _Results(tracks: results),
          ),
        ],
      ),
    );
  }
}

/// Kolom pencarian dengan latar terisi dan tombol bersihkan.
class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onSubmit,
  });

  final TextEditingController controller;

  final ValueChanged<String> onChanged;

  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.soga800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        autofocus: true,
        textInputAction: TextInputAction.search,
        style: const TextStyle(color: AppColors.soga50, fontSize: 16),
        cursorColor: AppColors.kunir500,
        decoration: InputDecoration(
          hintText: 'Cari judul, artis, atau album…',
          hintStyle: const TextStyle(color: AppColors.soga400),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, _) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.soga300,
                      size: 20,
                    ),
                  ),
          ),
        ),
        onChanged: onChanged,
        onSubmitted: (_) => onSubmit(),
      ),
    );
  }
}

/// Isi layar saat kolom kosong: riwayat pencarian + hasil terakhir.
class _SearchHome extends ConsumerWidget {
  const _SearchHome({
    required this.history,
    required this.lastSearch,
    required this.onTapQuery,
  });

  final List<String> history;

  final LastSearch? lastSearch;

  final ValueChanged<String> onTapQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (history.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pencarian Terakhir',
                  style: TextStyle(
                    color: AppColors.soga200,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: ref
                      .read(searchHistoryControllerProvider.notifier)
                      .clear,
                  child: const Text(
                    'Bersihkan',
                    style: TextStyle(color: AppColors.soga400, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in history)
                  ActionChip(
                    label: Text(
                      entry,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.soga100,
                        fontSize: 13,
                      ),
                    ),
                    backgroundColor: AppColors.soga800,
                    side: const BorderSide(color: AppColors.soga700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    onPressed: () => onTapQuery(entry),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (lastSearch != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Row(
              children: [
                const Icon(Icons.history, color: AppColors.kunir500, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Terakhir dicari: ${lastSearch!.query}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.soga200,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...lastSearch!.tracks.map(
            (track) => TrackRow(track: track, queue: lastSearch!.tracks),
          ),
        ],
        if (history.isEmpty && lastSearch == null)
          const _Hint(text: 'Ketik untuk mencari lagu di perangkatmu.'),
      ],
    );
  }
}

/// Pesan kosong di tengah layar.
class _Hint extends StatelessWidget {
  const _Hint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.soga300, fontSize: 15),
        ),
      ),
    );
  }
}

/// Hasil pencarian — memutar trek dengan hasil sebagai antrean.
class _Results extends ConsumerWidget {
  const _Results({required this.tracks});

  final List<Track> tracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: tracks.length,
      separatorBuilder: (_, _) =>
          const Divider(color: AppColors.soga700, height: 1),
      itemBuilder: (context, index) {
        return TrackRow(track: tracks[index], queue: tracks);
      },
    );
  }
}
