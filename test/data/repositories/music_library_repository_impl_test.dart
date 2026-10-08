import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lirih/core/errors/failures.dart';
import 'package:lirih/core/extensions/either_x.dart';
import 'package:lirih/data/datasources/local/media_store_scanner.dart';
import 'package:lirih/data/repositories/music_library_repository_impl.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/domain/entities/track_source.dart';
import 'package:mocktail/mocktail.dart';
import 'package:on_audio_query/on_audio_query.dart';

class _MockMediaStoreScanner extends Mock implements MediaStoreScanner;

/// Membuat [SongModel] uji dengan field yang dipakai pemetaan.
SongModel _song({
  String title = 'Hingga Ujung Waktu',
  String? artist = 'Sheila on 7',
  String? album = 'Sheila on 7',
  int? duration = 275000,
  String uri = 'content://media/external/audio/media/42',
  String fileExtension = 'mp3',
}) => SongModel(<dynamic, dynamic>{
  '_id': 42,
  '_data': '/storage/emulated/0/Music/lagu.mp3',
  '_uri': uri,
  '_display_name': 'lagu.mp3',
  '_display_name_wo_ext': 'lagu',
  '_size': 7239603,
  'album': album,
  'artist': artist,
  'duration': duration,
  'title': title,
  'file_extension': fileExtension,
});

/// Mengasumsikan [result] adalah Left; mengembalikan nilai kiri untuk diuji.
Failure requireLeft(Either<Failure, List<Track>> result) =>
    result.fold((f) => f, (_) => fail('seharusnya Left'));

void main() {
  late MediaStoreScanner scanner;
  late MusicLibraryRepositoryImpl repository;

  setUp(() {
    scanner = _MockMediaStoreScanner();
    repository = MusicLibraryRepositoryImpl(scanner);
  });

  group('MusicLibraryRepositoryImpl', () {
    test('scanLibrary memetakan SongModel menjadi Track', () async {
      when(() => scanner.hasPermission()).thenAnswer((_) async => true);
      when(() => scanner.querySongs()).thenAnswer((_) async => [_song()]);

      final result = await repository.scanLibrary();

      expect(result.isRight(), true);
      final tracks = result.getOrThrow();
      expect(tracks, hasLength(1));

      final track = tracks.single;
      expect(track.title, 'Hingga Ujung Waktu');
      expect(track.artist, 'Sheila on 7');
      expect(track.album, 'Sheila on 7');
      expect(track.durationMs, 275000);
      expect(track.source, isA<LocalSource>());
      expect(
        (track.source as LocalSource).filePath,
        'content://media/external/audio/media/42',
      );
    });

    test('izin sudah diberikan → tidak meminta ulang', () async {
      when(() => scanner.hasPermission()).thenAnswer((_) async => true);
      when(() => scanner.querySongs()).thenAnswer((_) async => [_song()]);

      await repository.scanLibrary();

      verifyNever(() => scanner.requestPermission());
    });

    test('izin awal ditolak lalu diberikan → tetap memindai', () async {
      when(() => scanner.hasPermission()).thenAnswer((_) async => false);
      when(() => scanner.requestPermission()).thenAnswer((_) async => true);
      when(() => scanner.querySongs()).thenAnswer((_) async => [_song()]);

      final result = await repository.scanLibrary();

      expect(result.isRight(), true);
      verify(() => scanner.requestPermission()).called(1);
    });

    test('izin ditolak permanen → PermissionDeniedFailure', () async {
      when(() => scanner.hasPermission()).thenAnswer((_) async => false);
      when(() => scanner.requestPermission()).thenAnswer((_) async => false);

      final result = await repository.scanLibrary();

      expect(requireLeft(result), isA<PermissionDeniedFailure>());
      verifyNever(() => scanner.querySongs());
    });

    test('pustaka kosong → EmptyLibraryFailure', () async {
      when(() => scanner.hasPermission()).thenAnswer((_) async => true);
      when(() => scanner.querySongs()).thenAnswer((_) async => const []);

      final result = await repository.scanLibrary();

      expect(requireLeft(result), isA<EmptyLibraryFailure>());
    });

    test('format tidak didukung disaring (mis. .amr)', () async {
      when(() => scanner.hasPermission()).thenAnswer((_) async => true);
      when(() => scanner.querySongs()).thenAnswer(
        (_) async => [
          _song(title: 'Lagu MP3', uri: 'content://a/1'),
          _song(
            title: 'Pesan Suara',
            uri: 'content://a/2',
            fileExtension: 'amr',
          ),
        ],
      );

      final result = await repository.scanLibrary();

      final tracks = result.getOrThrow();
      expect(tracks, hasLength(1));
      expect(tracks.single.title, 'Lagu MP3');
    });

    test('SongModel tanpa uri disaring', () async {
      when(() => scanner.hasPermission()).thenAnswer((_) async => true);
      when(() => scanner.querySongs()).thenAnswer(
        (_) async => [
          _song(uri: 'content://a/1'),
          // Tidak ada key _uri → getter SongModel.uri mengembalikan null.
          SongModel(<dynamic, dynamic>{
            'title': 'Tanpa URI',
            'file_extension': 'mp3',
          }),
        ],
      );

      final result = await repository.scanLibrary();

      final tracks = result.getOrThrow();
      // Hanya lagu dengan uri yang lolos; lagu "Tanpa URI" disaring.
      expect(tracks, hasLength(1));
      expect(tracks.single.title, 'Hingga Ujung Waktu');
    });

    test('artis/album kosong dinormalisasi', () async {
      when(() => scanner.hasPermission()).thenAnswer((_) async => true);
      when(() => scanner.querySongs()).thenAnswer(
        (_) async => [
          _song(title: '  Judul Ber-spasi  ', artist: '', album: '   '),
        ],
      );

      final result = await repository.scanLibrary();

      final track = result.getOrThrow().single;
      expect(track.title, 'Judul Ber-spasi');
      expect(track.artist, '<unknown>');
      expect(track.album, isNull);
    });

    test('galat MediaStore → ScanFailure', () async {
      when(() => scanner.hasPermission()).thenAnswer((_) async => true);
      when(() => scanner.querySongs()).thenThrow(Exception('MediaStore down'));

      final result = await repository.scanLibrary();

      expect(requireLeft(result), isA<ScanFailure>());
    });

    test(
      'id stabil identik untuk lagu yang sama (lintas pemindaian)',
      () async {
        when(() => scanner.hasPermission()).thenAnswer((_) async => true);
        when(() => scanner.querySongs()).thenAnswer((_) async => [_song()]);

        final first = (await repository.scanLibrary()).getOrThrow().single;
        final second = (await repository.scanLibrary()).getOrThrow().single;

        expect(first.id, second.id);
      },
    );

    test('hasPermission/requestPermission diteruskan ke scanner', () async {
      when(() => scanner.hasPermission()).thenAnswer((_) async => true);
      when(() => scanner.requestPermission()).thenAnswer((_) async => false);

      expect(await repository.hasPermission(), true);
      expect(await repository.requestPermission(), false);
    });
  });
}
