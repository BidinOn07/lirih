import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/domain/entities/playlist.dart';
import 'package:lirih/features/playlists/playlists_controller.dart';

/// Membuka *bottom sheet* untuk membuat atau mengganti nama playlist
/// (task 3.1).
///
/// Bila [editId] `null` → membuat playlist baru. Mengembalikan playlist
/// terpilih, atau `null` bila pengguna membatalkan/mengosongkan nama.
Future<Playlist?> showPlaylistFormSheet(
  BuildContext context, {
  String? editId,
  String initialName = '',
}) {
  return showModalBottomSheet<Playlist>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.soga850,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) =>
        _PlaylistFormSheet(editId: editId, initialName: initialName),
  );
}

class _PlaylistFormSheet extends ConsumerStatefulWidget {
  const _PlaylistFormSheet({this.editId, this.initialName = ''});

  final String? editId;

  final String initialName;

  @override
  ConsumerState<_PlaylistFormSheet> createState() => _PlaylistFormSheetState();
}

class _PlaylistFormSheetState extends ConsumerState<_PlaylistFormSheet> {
  late final TextEditingController _field;

  @override
  void initState() {
    super.initState();
    _field = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _field.text.trim();
    if (name.isEmpty) return;

    final notifier = ref.read(playlistsControllerProvider.notifier);
    final playlist = widget.editId == null
        ? await notifier.createPlaylist(name)
        : await _renameAndReturn(name);

    if (mounted) Navigator.of(context).pop(playlist);
  }

  Future<Playlist> _renameAndReturn(String name) async {
    final notifier = ref.read(playlistsControllerProvider.notifier);
    await notifier.renamePlaylist(widget.editId!, name);
    return ref
        .read(playlistsControllerProvider)
        .firstWhere((playlist) => playlist.id == widget.editId);
  }

  @override
  Widget build(BuildContext context) {
    final creating = widget.editId == null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            creating ? 'Playlist baru' : 'Ganti nama playlist',
            style: const TextStyle(
              color: AppColors.soga50,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _field,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            style: const TextStyle(color: AppColors.soga50, fontSize: 16),
            cursorColor: AppColors.kunir500,
            decoration: const InputDecoration(
              hintText: 'Nama playlist',
              hintStyle: TextStyle(color: AppColors.soga400),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.soga600),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.kunir500),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.kunir600,
                foregroundColor: AppColors.soga50,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(creating ? 'Buat' : 'Simpan'),
            ),
          ),
        ],
      ),
    );
  }
}
