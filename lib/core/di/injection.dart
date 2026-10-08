import 'package:lirih/data/datasources/local/media_store_scanner.dart';
import 'package:lirih/data/repositories/music_library_repository_impl.dart';
import 'package:lirih/domain/repositories/music_library_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'injection.g.dart';

/// Sumber data MediaStore (task 1.12). Singleton implisit via Riverpod.
@riverpod
MediaStoreScanner mediaStoreScanner(Ref ref) => OnAudioQueryMediaStoreScanner();

/// Kontrak domain MusicLibraryRepository — selalu akses lewat provider ini
/// agar layer presentation tidak bergantung pada implementasi `on_audio_query`.
@riverpod
MusicLibraryRepository musicLibraryRepository(Ref ref) =>
    MusicLibraryRepositoryImpl(ref.watch(mediaStoreScannerProvider));
