# AGENTS.md — Lirih

Panduan padat untuk sesi OpenCode berikutnya. Hanya berisi hal yang **mudah dilewatkan** atau **tidak terlihat dari nama berkas**.

**Lirih** = pemutar musik **offline** (Flutter, Android-first untuk v1). Penerbit: **Sakadabra**. Fitur inti: preset frekuensi **440 / 432 / 528 Hz** (pitch shift). Cari konteks lengkap di `docs/` (lokal, lihat §Git).

---

## Batasan keras — jangan dilanggar

- **`applicationId` `io.github.bidinon07.lirih` TERKUNCI.** Tidak bisa diubah setelah AAB pertama diunggah ke Google Play. MethodChannel DSP: `io.github.bidinon07.lirih/dsp`. Plugin native rencana: package `lirih_audio`.
- **Tanpa jaringan, tanpa akun, tanpa iklan.** v1 murni offline — **jangan tambahkan permission `INTERNET`** atau dependensi runtime yang butuh koneksi. Privacy policy & form Data Safety Play menyatakan "tidak mengumpulkan data"; manifest wajib diverifikasi bebas `INTERNET` sebelum rilis.
- **432/528 Hz murni pengaturan pemutaran (pitch).** Dilarang menulis klaim kesehatan/medis/terapi di kode, aset, maupun listing Play. Risiko kebijakan Play.
- **Identitas harus orisinal:** BUKAN `#121212`+hijau ala Spotify, BUKAN font Circular, tidak menyebut merek pemutar musik lain di aset/listing/keyword. Pakai palet Gamelan (`AppColors`: soga/kunir/nila) + **Plus Jakarta Sans**.

## Toolchain (terkunci — jangan naikkan sembarangan)

Flutter **3.47.6 stable** / Dart 3.13.5 · AGP **9.1.0** · Kotlin **2.4.0** · Gradle **9.3.1** · Java/JVM target **17** · compileSdk **36** · targetSdk **36** · minSdk **24**.

- **`kotlin.incremental=false`** di `android/gradle.properties` **sengaja** — cache incremental Kotlin 2.4 gagal lintas-drive di Windows (pub cache di `C:\`, build dir di `E:\`). Jangan "perbaiki".
- **Blok patch AGP 9 di `android/build.gradle.kts`** (`subprojects { afterEvaluate ... }`) menambal plugin lawas `on_audio_query_android` (namespace dari `group`, Java 17, compileSdk 36). Hapus = build gagal.
- **Patch izin `on_audio_query_android` di `android/build.gradle.kts`** (task `patchOnAudioQueryPermission`, idempoten, jalan sebelum `compileDebugKotlin`/`compileReleaseKotlin`): plugin meminta **DUA** izin di Android 13+ (`READ_MEDIA_AUDIO` + `READ_MEDIA_IMAGES`). Ini ganda-buruk: (a) overreach privasi untuk pemutar musik, (b) `permissionStatus()` AND kedua izin tapi `requestPermission()` hanya cek `grantResults[0]` → inkonsistensi → query tanpa izin → plugin membalas method channel **dua kali** (`result.error` + `find()` → `result.success`) → `IllegalStateException: Reply already submitted` → **FATAL crash**. Patch mengecilkan array jadi audio saja (API 33+) / read storage saja (≤32) dan menyederhanakan `retryRequestPermission()`. **Jangan hapus blok ini.**
- **Manifest (`android/app/src/main/AndroidManifest.xml`) wajib deklarasi `READ_MEDIA_AUDIO` (+ `READ_EXTERNAL_STORAGE` maxSdkVersion 32).** Tanpa ini sistem menolak permintaan izin baca media secara diam-diam → pustaka kosong → akhirnya memicu jalur crash plugin di atas. `INTERNET`/`ACCESS_NETWORK_STATE` dibuang via `tools:node="remove"` (v1 offline); sisanya di manifest **debug** (`src/debug/AndroidManifest.xml`, bawaan Flutter untuk komunikasi VM service) hanya muncul di build debug, bukan release.
- **Semua akses `on_audio_query` diserialkan** di `OnAudioQueryMediaStoreScanner` (`_serialize`). `PluginProvider` plugin menyimpan result method channel di **singleton global yang ditimpa setiap method call** → pemanggilan paralel (mis. minta izin sementara Beranda muat sampul) saling menimpa result → crash "Reply already submitted". Lengkapnya: `artworkFor` dicek izinnya dulu, dan `artworkCacheProvider` hanya mengambil sampul setelah `libraryScanControllerProvider` punya data (scan sukses ⟹ izin ada) — saat dialog izin terbuka, tidak ada method plugin lain yang berjalan.
- **`permission_handler` dipin `^12.0.3`** dengan sengaja — 13.0.x menarik `compileSdk 37` yang tidak didukung AGP 9.1.0 (maks 36). Lihat catatan di `pubspec.yaml`. Naikkan hanya setelah Flutter pakai AGP ≥ 9.2.
- **`on_audio_query_android` tak terawat** (per 2023, masih KGP lama). Harus diganti saat Flutter mencabut dukungan KGP.

## Perintah utama

```bash
flutter pub get

# Gate CI — urutan ini wajib: format → analyze → test
dart format .                                          # perbaiki format
dart format --output=none --set-exit-if-changed .     # cek (ini yang jalan di CI)
flutter analyze                      # WAJIB 0 issue. Sengaja TANPA --fatal-infos.
flutter test                         # atau: flutter test --coverage
flutter test test/widget_test.dart   # satu berkas tes

flutter build appbundle --release    # Play HANYA menerima .aab (bukan .apk)

# Codegen (freezed / riverpod_annotation / hive_ce_generator) — belum ada outputnya;
# jalankan setelah model pertama dibuat:
dart run build_runner build --delete-conflicting-outputs

# Regenerasi ikon launcher + aset branding (Windows/PowerShell):
pwsh ./ignore/tools/generate_lirih_branding.ps1
```

## Struktur & arsitektur

Clean architecture di `lib/`: `core/` · `data/` · `domain/` · `features/` · `shared/`. `app.dart` sengaja dipisah dari `main.dart`.

- Entrypoint: `lib/main.dart` → `ProviderScope` → `LirihApp` (`lib/app.dart`).
- Kini hanya ada: placeholder home (logo + wordmark), token desain (`lib/core/constants/app_colors.dart`, `app_typography.dart`), dan widget brand (`lib/shared/widgets/`).
- Model domain rencana (TDD §3): `TrackSource` (sealed), `Track`, `FrequencyPreset`. Matematika pitch: `ratio = target / 440`.
- Box Hive rencana (TDD §7): `queueBox`, `recentsBox`, `searchHistoryBox`, `playlistsBox`, `lyricsBox`.
- Tidak ada layer network — sengaja dihapus dari rancangan karena v1 offline (TDD §6 adalah konten Versi B yang **tidak akan pernah dibangun** di repo ini).

## Konvensi kode (berbeda dari default)

Linter: `very_good_analysis` 11.0.0 (sangat ketat) + tambahan proyek di `analysis_options.yaml`.

- **`sort_pub_dependencies`** — dependensi di `pubspec.yaml` **wajib urut alfabet**.
- `prefer_single_quotes`, `directives_ordering` aktif.
- **Maksimum 80 karakter per baris** (`lines_longer_than_80`).
- **Semua member publik di `lib/` wajib berdokumentasi** (`public_member_api_docs`) — tulis doc comment `[...]`.
- `unnecessary_type_name_in_constructor` **sengaja dimatikan** (template Flutter 3.47 masih pakai konstruktor berNama). Aktifkan kembali hanya setelah Flutter mengadopsi sintaks `new`.
- `avoid_print` — jangan pakai `print`.
- **Bahasa dokumen/doc comment memakai Bahasa Indonesia** — ikuti gaya berkas di sekitar.
- File generated (`*.g.dart`, `*.freezed.dart`, `*.mocks.dart`) dikecualikan dari analyzer.

## Sinkronisasi lintas-berkas (mudah pecah)

- **Geometri logo ada di dua tempat** — konstanta di `lib/shared/widgets/lirih_logo.dart` **harus identik** dengan `ignore/tools/generate_lirih_branding.ps1` (yang menghasilkan ikon launcher). Ubah satu tanpa yang lain → logo dalam app ≠ ikon launcher.
- **Token warna juga duplikat** — hex di `app_colors.dart` vs di script branding tersebut. Jaga sinkron.
- **Wordmark = widget `LirihWordmark`** ("LIRIH" kapital, Plus Jakarta Sans Bold, `letterSpacing = 0.22 × fontSize`) — **bukan** `AppTypography.display`.

## Git & rahasia

- Branch `main`; remote bernama `lirih`.
- **`docs/` dan `ignore/` di-gitignore** — dokumentasi perencanaan internal, **sengaja tidak diterbitkan** (README menyatakannya). Jangan pernah commit. Ini tetap sumber kebenaran lokal untuk roadmap & desain.
- **Material tanda tangan tidak boleh masuk repo:** `key.properties`, `*.jks`, `*.keystore`, `*.p12`, `*.pem`, `service-account*.json`. Job CI `signing-guard` akan **gagalkan build** jika ter-track.
- AAB untuk Play dibuat **lokal** dengan keystore di luar repo; artefak job CI `build` **unsigned** dan hanya untuk verifikasi.

## PoC pitch shift (task 0.6/0.8 — sementara)

Risiko teknis tertinggi sudah dijalankan. Yang perlu diketahui sesi berikutnya:

- **Native:** `android/.../dsp/LirihDspPlayer.kt` (ExoPlayer + `PlaybackParameters(tempo, pitch)`) + `DspPlugin.kt` (MethodChannel), terdaftar di `MainActivity.kt`.
- **Dart:** `lib/features/poc_pitch/` — `DspChannel` (client channel), `WavToneGenerator` (nada uji 440 Hz ke `Directory.systemTemp`), `PoCPitchScreen` (alat uji). **Sementara** — dipindah ke plugin `lirih_audio` di Minggu 3 (task 1.x); pintu sementaranya di `lib/app.dart`.
- **Pitch math permanen & teruji:** `lib/core/utils/pitch_math.dart` + `test/core/utils/pitch_math_test.dart`. `ratio = target/440`; `cents = 1200·log2(target/440)`. Catatan: 528 Hz = **+315.64 cents** (rasio 1.2×).
- **Pilihan desain:** `PlaybackParameters` (AudioTrack time-stretch, API 23+) diuji duluan karena paling murah. **Eskalasi bila ada artifact (validasi 0.9):** `PitchAudioProcessor` (Sonic) pada custom audio sink — lihat TDD §4.3.
- **Status:** kompilasi & unit test hijau; **belum divalidasi di perangkat**. Validasi telinga pada 432/528 Hz (task 0.9) butuh device fisik + headphone.

## Notifikasi media & foreground service (task 1.7)

`LirihPlaybackService` (MediaSessionService media3) sudah diverifikasi di device Xiaomi MIUI/HyperOS. **Dua jebakan yang sudah ditambal — jangan dikembalikan:**

- **`startForeground()` WAJIB dipanggil sinkron di `onCreate()`.** `DspPlugin.startPlaybackService()` memanggil `startForegroundService()` tepat saat ExoPlayer transisi ke *playing*, tapi media3 membangun notifikasi secara **asinkron** (koneksi `MediaController` + muat bitmap sampul). Sistem hanya beri ~5–10 d; bila `startForeground()` belum dipanggil → **`ForegroundServiceDidNotStartInTimeException` → app dibunuh** (crash nyata, terjadi 2× di device). Fix: notifikasi minimal diposting sinkron di `onCreate`, **dengan ID/channel yang sama** persis dengan `DefaultMediaNotificationProvider` yang dipasang via `setMediaNotificationProvider` (ID `1001`, channel `lirih_playback`) — saat media3 selesai, ia **menimpa** notifikasi itu (tak ada notifikasi ganda).
- **`addSession()` WAJIB dipanggil eksplisit di `onCreate()`.** Intent start service dari Dart **tidak membawa media action**, sehingga `onStartCommand` bawaan media3 mengabaikannya dan session tak pernah terdaftar ke notification manager → notifikasi tak pernah muncul walau izin diberikan.
- **Metadata trek** (judul/artis/sampul) HARUS dikirim ke native: `DspChannel.play(path, title:, artist:, artUri:)` → `MediaItem.MediaMetadata`. Tanpa ini notifikasi media3 tampil kosong; di MIUI notifikasi kosong bahkan disembunyikan. Sumber: `Track.title/artist/artUri`.

## Sampel musik uji (task 0.9)

- **`assets/samples/`** berisi sampel audio **berhak cipta** untuk pengujian debug di perangkat sendiri. Isi folder **di-gitignore** (`!assets/samples/.gitkeep`) — **jangan pernah commit**, dan **jangan masukkan ke AAB rilis**.
- Deklarasi di `pubspec.yaml` memakai **direktori** (`- assets/samples/`) agar CI tetap hijau saat folder kosong (fresh clone tidak punya sampel).
- **Guard wajib sebelum `flutter build appbundle --release`:** `powershell ./ignore/tools/check-release-samples.ps1` — gagal (exit 1) jika masih ada audio di folder.
- Di app: tombol "Putar sampel musik" (`BundledSample`) mengekstrak asset ke `Directory.systemTemp` lalu diputar mesin DSP. Bila sampel tak ada, tombol menampilkan pesan (tidak crash).

## Arsitektur domain (task 1.12 — berjalan)

- **Model freezed:** `Track`, `TrackSource` (sealed, hanya `LocalSource`), `FrequencyPreset` — di `lib/domain/entities/`. Codegen: `dart run build_runner build` (~10 d; flag `--delete-conflicting-outputs` sudah tidak didukung build_runner 2.16).
- **Riverpod 4.x:** provider fungsi memakai `Ref ref` generik (BUKAN `{Nama}Ref`); AsyncNotifier via `@riverpod class`. DI di `lib/core/di/injection.dart`.
- **Repository:** `MusicLibraryRepositoryImpl` memetakan `SongModel` → `Track`, menyaring ekstensi (`.mp3/.flac/.wav/.m4a/.aac/.oga/.opus`), menormalkan artis/album kosong. Galat via dartz `Either<Failure, T>`; `Failure implements Exception` agar bisa `throw` di AsyncNotifier (`lib/core/extensions/either_x.dart` → `getOrThrow`).
- **ID stabil:** `stableTrackId()` deterministik dari konten (path+judul+artis+durasi) — **penyimpangan disengaja dari TDD §3.2** (UUID acak justru berubah tiap scan, memutus referensi Hive).
- **Ekstensi `fileExtension`:** berasal dari key map `file_extension` di `SongModel`, bukan nama file. Dipakai menampilkan codec (track_info_sheet, `Track.formatLabel`).
- **`trackNumber`** berasal dari key `track` di `SongModel` (tag TRK). `AlbumDetailScreen.sortByTrackNumber` mengurutkan album per nomor trek (null di belakang, fallback judul) — **bukan** per judul.

## Sampul album & artwork

- **Artwork HD:** `OnAudioQueryMediaStoreScanner.artworkFor` memanggil `queryArtwork(size: 600)` — native memakai `loadThumbnail(size, size)`. Default plugin 200 terlihat buram saat diperbesar (grid Pustaka ~180 dp, layar pemutar ~300 dp). 600 adalah kompromi ketajaman vs memori (cache `ArtworkCache` menyimpan byte per mediaStoreId seumur hidup app).
- **`TrackArtwork`** butuh ukuran eksplisit (default 48). Di grid (`GroupCard`) dipakai `LayoutBuilder` + `AspectRatio(1)` agar kotak mengikuti lebar kartu.

## Playlist (task 3.1) — CRUD + impor

- **CRUD** di `PlaylistsController` (box `playlistsBox`, key = `Playlist.id`, value map `{name, tracks[], lastPlayedAt}`); trek disimpan *inline* via `TrackMapper` agar playlist tetap bisa diputar sebelum scan selesai.
- **`lastPlayedAt`** (ms epoch) diperbarui `markPlayed()` saat playlist diputar → Beranda mengurutkan playlist dengan yang terakhir diputar di depan ("favorit").
- **Auto-import (playlist perangkat):** `DspPlugin.queryDevicePlaylists` (Kotlin) baca `MediaStore.Audio.Playlists` + `Members` (PLAY_ORDER) di thread latar → `DspChannel.queryDevicePlaylists()` → `PlaylistsController.importDevicePlaylists()` mencocokkan `audioIds` ke `Track.mediaStoreId`. **Dedup per nama** (playlist dengan nama yang sama dilewati) agar idempoten. Dijalankan otomatis setelah pemindaian pustaka sukses (`LibraryScanController._importDevicePlaylists`, fire-and-forget). Di MIUI tabel ini biasanya **kosong** — jangan kaget bila tak ada yang terimpor.
- **Impor berkas .m3u/.m3u8:** `DspPlugin.pickPlaylistFile` (SAF, `type = "*/*"`, request code `RC_PICK_PLAYLIST_FILE = 42421`) mengembalikan `{name, content}` via `playlistFileResult` (pending MethodChannel.Result diselesaikan di `onActivityResult`). Dart: `M3uParser.entries()` + pencocokan **basename** (case-insensitive, URL-decoded) terhadap `Track.sourcePath`. `on_audio_query` 2.9.0 **tidak** menyediakan query anggota playlist — itu alasan kueri native.
- **UI:** tombol "Impor dari perangkat" & "Impor file (.m3u)" di bagian Playlist Pustaka; balasan via SnackBar.

## Pencarian (task 3.5)

- **Riwayat** (`searchHistoryBox`): daftar String (auto-increment key). **Hasil terakhir** disimpan di key `"__last_search__"` (map `{query, tracks[]}`) — `SearchHistoryController.add()` **hanya menghapus value bertipe String** (bukan `box.clear()`), agar key hasil terakhir tidak ikut terhapus. `LastSearch` ditampilkan saat kolom kosong dan bisa langsung diputar.
- Kolom pencarian ada di **body** (padding), bukan di AppBar — ruang lega di puncak.

## Mini player

- Tinggi ~68 dp (artwork 52, padding vertikal 8). **Enam** tombol: acak, sebelumnya, putar/jeda, berikutnya, ulang, opsi (⋯). Tombol opsi membuka `showTrackInfoSheet`: judul, artis, album, trek ke-, format, durasi. Tombol dipadatkan (`minWidth: 30`) agar judul tak terlalu terjepit di layar 360 dp.

## Keputusan penundaan

- **FLAC:** dekoder native media3 (`media3-decoder-flac`) **tidak ada di Maven** — ekstensi decoder media3 harus dibangun dari source + NDK. Sementara FLAC hanya jalan di **API 31+** (dekoder platform). Penyebab: ini masalah *packaging*, bukan risiko pitch-shift. Ditangani terpisah untuk v1.
- **Plugin `lirih_audio` (Minggu 3):** ditunda — mesin in-app sudah berfungsi; prioritas diberikan ke fitur yang bisa diuji pengguna (pemindai pustaka, UI).

## Rujukan

- `docs/MelodicDSP-v1-Checklist.md` — checklist harian; centang `[x]` setiap task selesai. Nomor task menyilang ke roadmap.
- `docs/MelodicDSP-Roadmap-v1-Offline.md` — sumber kebenaran *apa & mengapa*.
- `docs/MelodicDSP-Technical-Design-Doc.md` — desain arsitektur. ⚠️ Bagian §6 (backend API) adalah Versi B yang tidak dibangun di repo ini, dan nama plugin masih ditulis `melodic_audio` (kini `lirih_audio`) — **percayai checklist/README** bila berbenturan.
- Root: `README.md`, `PRIVACY-POLICY.md`, `THIRD_PARTY_NOTICES.md` (semua diterbitkan).
- CI: `.github/workflows/ci.yml` — 3 job: `quality` (format+analyze+test, tiap push/PR ke main), `signing-guard`, `build` appbundle (hanya `workflow_dispatch` manual).
