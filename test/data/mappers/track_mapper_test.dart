import 'package:flutter_test/flutter_test.dart';

import 'package:lirih/data/mappers/track_mapper.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/domain/entities/track_source.dart';

void main() {
  group('TrackMapper', () {
    test('toJson/fromJson pulang-pergi menjaga seluruh field', () {
      const track = Track(
        id: 'local_abc123',
        title: 'Hingga Ujung Waktu',
        artist: 'Sheila on 7',
        album: 'Sheila on 7',
        durationMs: 275000,
        source: TrackSource.local(
          filePath: 'content://media/external/audio/media/42',
          durationMs: 275000,
          mediaStoreId: 42,
        ),
      );

      final restored = TrackMapper.fromJson(TrackMapper.toJson(track));

      expect(restored, isNotNull);
      final t = restored!;
      expect(t.id, track.id);
      expect(t.title, track.title);
      expect(t.artist, track.artist);
      expect(t.album, track.album);
      expect(t.durationMs, track.durationMs);
      expect(t.sourcePath, track.sourcePath);
      expect(t.mediaStoreId, track.mediaStoreId);
    });

    test('toJson menghasilkan mediaStoreId null untuk trek non-MediaStore', () {
      const track = Track(
        id: 'local_saf',
        title: 'Lagu SAF',
        artist: '<unknown>',
        durationMs: 60000,
        source: TrackSource.local(
          filePath: 'content://com.android.providers.documents/xyz',
        ),
      );

      final json = TrackMapper.toJson(track);

      expect(json['mediaStoreId'], isNull);
      expect(TrackMapper.fromJson(json)!.mediaStoreId, isNull);
    });

    test('fromJson mengembalikan null bila field wajib hilang', () {
      expect(TrackMapper.fromJson(<String, dynamic>{}), isNull);
      expect(TrackMapper.fromJson(<String, dynamic>{'id': 'x'}), isNull);
      expect(
        TrackMapper.fromJson(<String, dynamic>{
          'id': 'x',
          'title': 'Judul',
          'artist': 'Artis',
        }),
        isNull,
      );
    });
  });
}
