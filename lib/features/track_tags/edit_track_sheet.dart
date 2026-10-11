import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/core/utils/duration_format.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/features/library/library_scan_controller.dart';
import 'package:lirih/features/lyrics/lyrics_controller.dart';
import 'package:lirih/features/track_tags/track_tags_controller.dart';

/// Membuka *bottom sheet* untuk mengubah metadata [track]: judul, artis,
/// album, nomor trek, dan lirik (task 3.5).
///
/// Perubahan disimpan di `trackTagsBox` (bukan ditulis ulang ke berkas)
/// dan langsung diterapkan saat pustaka dipindai ulang — lihat
/// [TrackTagsController]. Lirik yang diisi menimpa lirik tertanam; bila
/// trek belum punya lirik, ini membuatnya.
Future<void> showEditTrackSheet(BuildContext context, Track track) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.soga850,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _EditTrackSheet(track: track),
  );
}

class _EditTrackSheet extends ConsumerStatefulWidget {
  const _EditTrackSheet({required this.track});

  final Track track;

  @override
  ConsumerState<_EditTrackSheet> createState() => _EditTrackSheetState();
}

class _EditTrackSheetState extends ConsumerState<_EditTrackSheet> {
  late final TextEditingController _title;
  late final TextEditingController _artist;
  late final TextEditingController _album;
  late final TextEditingController _trackNumber;
  late final TextEditingController _lyrics;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.track.title);
    _artist = TextEditingController(text: widget.track.artist);
    _album = TextEditingController(text: widget.track.album ?? '');
    _trackNumber = TextEditingController(
      text: widget.track.trackNumber?.toString() ?? '',
    );
    // Lirik override bila sudah pernah disimpan; jika belum, muat lirik
    // tertanam (async) sebagai nilai awal.
    final tags =
        ref.read(trackTagsControllerProvider)[widget.track.sourcePath] ??
        const <String, dynamic>{};
    final savedLyrics = tags[kTagLyrics] as String?;
    if (savedLyrics != null) {
      _lyrics = TextEditingController(text: savedLyrics);
    } else {
      _lyrics = TextEditingController();
      unawaited(_loadEmbeddedLyrics());
    }
  }

  Future<void> _loadEmbeddedLyrics() async {
    final lyrics = await ref.read(lyricsControllerProvider.future);
    if (!mounted || _lyrics.text.isNotEmpty) return;
    if (lyrics != null && lyrics.trim().isNotEmpty) {
      _lyrics.value = TextEditingValue(
        text: lyrics,
        selection: TextSelection.collapsed(offset: lyrics.length),
      );
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _artist.dispose();
    _album.dispose();
    _trackNumber.dispose();
    _lyrics.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final trackNumberText = _trackNumber.text.trim();
    final trackNumber = int.tryParse(trackNumberText);

    await ref
        .read(trackTagsControllerProvider.notifier)
        .saveTags(
          widget.track.sourcePath,
          title: _title.text,
          artist: _artist.text,
          album: _album.text,
          trackNumber: trackNumber,
          lyrics: _lyrics.text,
        );

    // Bersihkan cache lirik lalu pindai ulang agar perubahan langsung
    // terlihat di seluruh aplikasi.
    ref.read(lyricsControllerProvider.notifier).clearCache();
    await ref.read(libraryScanControllerProvider.notifier).rescan();

    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Info "${_title.text.trim()}" disimpan'),
          backgroundColor: AppColors.soga800,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text(
                    'Edit info lagu',
                    style: TextStyle(
                      color: AppColors.soga50,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formatTrackDuration(widget.track.durationMs),
                    style: const TextStyle(
                      color: AppColors.soga400,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const Divider(color: AppColors.soga700, height: 20),
              _Field(label: 'Judul', controller: _title),
              _Field(label: 'Artis', controller: _artist),
              _Field(label: 'Album', controller: _album),
              _Field(
                label: 'Nomor trek',
                controller: _trackNumber,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Lirik',
                  style: TextStyle(color: AppColors.soga300, fontSize: 13),
                ),
              ),
              const SizedBox(height: 6),
              _LyricsField(controller: _lyrics),
              const SizedBox(height: 8),
              const Text(
                'Lirik disimpan di aplikasi (tidak mengubah berkas asli). '
                'Lirik yang diisi menimpa lirik tertanam.',
                style: TextStyle(color: AppColors.soga400, fontSize: 11),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.kunir600,
                  foregroundColor: AppColors.soga50,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Simpan',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Satu field teks dengan label.
class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  final String label;

  final TextEditingController controller;

  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.soga300, fontSize: 13),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: AppColors.soga50, fontSize: 15),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.soga800,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Field lirik multi-baris.
class _LyricsField extends StatelessWidget {
  const _LyricsField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 8,
      minLines: 4,
      style: const TextStyle(
        color: AppColors.soga50,
        fontSize: 14,
        height: 1.5,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.soga800,
        hintText: 'Tulis lirik di sini…',
        hintStyle: const TextStyle(color: AppColors.soga400, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }
}
