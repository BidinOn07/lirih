# MelodicDSP — Technical Design Doc

> **Dokumen:** Desain teknis arsitektur, API contract, state management, dan DSP engine
> **Versi:** 1.0
> **Status:** Draft untuk review
> **Mengacu pada:** `MelodicDSP-Roadmap-v2.md`

---

## 1. Gambaran Arsitektur Sistem

```
┌──────────────────────────────────────────────────────────────┐
│                     MOBILE APP (Flutter)                      │
│                                                              │
│  ┌────────────┐  ┌────────────┐  ┌────────────────────────┐   │
│  │  UI Layer  │  │ State Mgmt │  │   Core Services        │   │
│  │ (Widgets)  │←→│ (Riverpod) │←→│ AudioPlayerFacade      │   │
│  └────────────┘  └────────────┘  │ QueueRepository        │   │
│                                  │ LyricsRepository       │   │
│                                  └───────────┬────────────┘   │
│                                              │                │
│  ┌───────────────────────────────────────────┴────────────┐   │
│  │  melodic_audio (plugin federated sendiri)                │   │
│  │  MethodChannel: com.melodic.dsp/dsp                     │   │
│  │  setPitch / setTempo / play / pause / seek ...         │   │
│  └───────┬───────────────────────────────┬────────────────┘   │
│          │ Android                       │ iOS                │
│  ┌───────▼───────────┐          ┌────────▼─────────────┐      │
│  │ ExoPlayer +       │          │ AVAudioEngine +      │      │
│  │ AudioSink custom  │          │ AVAudioUnitTimePitch │      │
│  │ (pitch indp tempo)│          │ (pitch indp tempo)   │      │
│  └───────────────────┘          └──────────────────────┘      │
└──────────────────────────────────────────────────────────────┘
                    │ HTTPS
┌───────────────────▼──────────────────────────────────────────┐
│              BACKEND GATEWAY (FastAPI + Docker)               │
│                                                              │
│  /search  /track  /stream  /cover  /lyrics  /health          │
│        │                                                     │
│  ┌─────▼──────────────────────────────┐  ┌───────────────┐    │
│  │  AudioProvider (interface)         │  │  Redis Cache  │    │
│  │  ├─ AudiusProvider   (stream)      │→ │  metadata 24h │    │
│  │  ├─ DeezerProvider   (preview)     │  │  streamURL 10m│    │
│  │  └─ JamendoProvider  (CC stream)   │  └───────────────┘    │
│  └────────────────────────────────────┘                       │
└──────────────────────────────────────────────────────────────┘
```

**Prinsip desain utama:**
- **Provider-agnostic:** semua sumber audio (lokal & online) memenuhi kontrak `AudioSource` yang sama, sehingga queue, player, dan UI tidak peduli asalnya.
- **DSP di native, kontrol di Dart:** perhitungan ratio dilakukan di Dart (mudah diuji), eksekusi DSP di native (performa).
- **Offline-first:** metadata & queue disimpan lokal; aplikasi tetap berfungsi penuh untuk local library tanpa internet.

---

## 2. Struktur Folder (Final)

```text
melodic_dsp/
├── melodic_audio/               # ⭐ PLUGIN FEDERATED SENDIRI (separate repo/path)
│   ├── melodic_audio/           # Dart interface + models (PlayerEvent, SourceType)
│   ├── melodic_audio_android/   # ExoPlayer + PitchAudioProcessor (Kotlin)
│   └── melodic_audio_ios/       # AVAudioEngine + AVAudioUnitTimePitch (Swift)
│
├── android/                     # registrasi plugin + permission config
├── ios/                         # registrasi plugin + Info.plist
├── backend/                     # FastAPI microservice (deploy: Railway)
│   ├── app/
│   │   ├── main.py
│   │   ├── api/                 # routers: search, track, stream, cover, lyrics
│   │   ├── providers/           # AudioProvider interface + impls
│   │   │   ├── base.py          # AudioProvider Protocol
│   │   │   ├── audius_provider.py
│   │   │   ├── deezer_provider.py
│   │   │   └── jamendo_provider.py
│   │   ├── cache.py             # Redis wrapper
│   │   └── config.py            # API keys (Railway env vars)
│   ├── Dockerfile
│   └── requirements.txt
├── lib/
│   ├── main.dart                # entry point + ProviderScope
│   ├── app.dart                 # MaterialApp.router + ThemeData
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_theme.dart
│   │   │   ├── app_dimens.dart
│   │   │   └── api_endpoints.dart
│   │   ├── errors/              # Failure classes, AppException
│   │   ├── network/             # Dio client + interceptors
│   │   ├── router/              # GoRouter configuration
│   │   └── utils/               # formatters, pitch_math.dart
│   │
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── track.dart
│   │   │   ├── track_source.dart        # sealed: LocalSource | NetworkSource
│   │   │   ├── queue_item.dart
│   │   │   ├── lyric_line.dart
│   │   │   └── frequency_preset.dart
│   │   └── repositories/        # abstract interfaces
│   │       ├── audio_player_repository.dart
│   │       ├── queue_repository.dart
│   │       ├── music_library_repository.dart
│   │       ├── online_search_repository.dart
│   │       └── lyrics_repository.dart
│   │
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── local/           # Hive boxes, on_audio_query wrapper
│   │   │   ├── remote/          # backend API client (Dio)
│   │   │   └── dsp_channel.dart # MelodicAudio wrapper + error mapping
│   │   ├── models/              # DTOs (json_serializable)
│   │   └── repositories/        # concrete implementations
│   │
│   ├── features/
│   │   ├── player/
│   │   │   ├── application/     # providers/notifiers
│   │   │   ├── presentation/    # screens + widgets
│   │   │   └── widgets/         # mini_player, full_player, frequency_tuner
│   │   ├── search/
│   │   ├── library/
│   │   ├── lyrics/
│   │   └── home/
│   │
│   └── shared/
│       └── widgets/             # reusable components
│
├── test/                        # unit tests (mirror lib/ structure)
├── integration_test/            # driver tests
└── pubspec.yaml
```

**Catatan:** spec awal menulis `main.py / app.dart` — dikoreksi menjadi `main.dart` (proyek Flutter murni). `main.py` hanya ada di folder `backend/`.

---

## 3. Domain Model Inti

### 3.1 TrackSource (sealed class — kunci abstraksi)

```dart
@freezed
sealed class TrackSource with _$TrackSource {
  const factory TrackSource.local({
    required String filePath,
    required int? durationMs,
  }) = LocalSource;

  const factory TrackSource.network({
    required String trackId,       // backend id, e.g. "audius:abc123"
    required String streamUrl,     // bisa expired
    required bool isPreview,       // Deezer 30s preview = true
  }) = NetworkSource;
}
```

### 3.2 Track

```dart
@freezed
class Track with _$Track {
  const factory Track({
    required String id,            // uuid v4 di app
    required String title,
    required String artist,
    String? album,
    String? albumArtUrl,
    int? durationMs,
    required TrackSource source,
    DateTime? lastPlayedAt,
  }) = _Track;
}
```

### 3.3 FrequencyPreset

```dart
@freezed
class FrequencyPreset with _$FrequencyPreset {
  const factory FrequencyPreset({
    required String name,
    required double frequencyHz,   // base reference: 440 Hz
  }) = _FrequencyPreset;

  // Presets built-in
  static const standard = FrequencyPreset(name: 'Standard', frequencyHz: 440.0);
  static const verdi    = FrequencyPreset(name: "Verdi's Tuning", frequencyHz: 432.0);
  static const solfeggio = FrequencyPreset(name: 'Solfeggio', frequencyHz: 528.0);
}
```

---

## 4. DSP Engine — Pitch Shift Tempo-Locked

### 4.1 Matematika dasar (di Dart, mudah diuji)

```dart
// core/utils/pitch_math.dart

/// Reference tuning semua preset dihitung relatif terhadap A4 = 440 Hz.
const double kReferenceFrequencyHz = 440.0;

/// Pitch ratio untuk native engine. Pitch naik jika > 1.0.
double pitchRatioForFrequency(double frequencyHz) {
  return frequencyHz / kReferenceFrequencyHz;
}

/// Offset dalam satuan cents (100 cents = 1 semitone). Untuk tampilan UI.
double centsOffsetForFrequency(double frequencyHz) {
  return 1200.0 * (log(frequencyHz / kReferenceFrequencyHz) / log(2));
}
```

**Validasi:**
- `pitchRatioForFrequency(440)` = `1.0` ✅
- `pitchRatioForFrequency(432)` = `0.981818...` ✅ (−31.77 cents, sesuai spec)
- `pitchRatioForFrequency(528)` = `1.2` ✅ — **penting:** 528 dihitung dari 440, BUKAN hardcoded konstanta. Kalau user pilih base lain (mis. 432), rumus ini tetap konsisten.

### 4.2 Kontrak MethodChannel

**Channel:** `com.melodic.dsp/dsp`

| Method | Params | Return | Keterangan |
|---|---|---|---|
| `play` | `{path: String, sourceType: String}` | `void` | `sourceType`: `"local"` \| `"network"` |
| `pause` | — | `void` | |
| `resume` | — | `void` | |
| `seek` | `{positionMs: int}` | `void` | |
| `stop` | — | `void` | |
| `setPitch` | `{ratio: double}` | `void` | 0.5–2.0, real-time |
| `setTempo` | `{ratio: double}` | `void` | Terpisah dari pitch |
| `getPosition` | — | `int` (ms) | Polling 500ms oleh Dart |
| `getDuration` | — | `int` (ms) | |

**Event channel** `com.melodic.dsp/dsp/events` → stream: `{"event": "completed"|"error", "data": ...}`

### 4.3 Android — ExoPlayer (Kotlin)

Pendekatan: custom `AudioSink` yang membungkus default sink dan menerapkan pitch via `Sonic` / native resampler.

```kotlin
class PitchAudioProcessor : BaseAudioProcessor() {
    private var pitchRatio: Float = 1.0f
    fun setPitch(ratio: Float) { pitchRatio = ratio }  // thread-safe via handler
    // buffer processing: pitch shift independent dari playback speed
}
```

- `RenderersFactory` custom mendaftarkan `MediaCodecAudioRenderer` dengan audio sink berisi `PitchAudioProcessor`.
- Playback speed via `ExoPlayer.setPlaybackParameters(PlaybackParameters(speed, pitch))` — **kunci:** set `pitch = 1.0` di parameter, dan pitch shift dilakukan oleh processor kita, sehingga tempo independen.
- Ingest: gunakan `DefaultDataSource` sehingga local file & HTTP stream URL sama penanganannya.

### 4.4 iOS — AVAudioEngine (Swift)

```swift
let engine = AVAudioEngine()
let timePitch = AVAudioUnitTimePitch()   // pitch & tempo independen ⭐
let player = AVAudioPlayerNode()

engine.attach(player)
engine.attach(timePitch)
engine.connect(player, to: timePitch, format: format)
engine.connect(timePitch, to: engine.mainMixerNode, format: format)

timePitch.pitch = 1200 * log2(ratio)   // cents
timePitch.rate = 1.0                    // tempo locked
```

**Mengapa `AVAudioUnitTimePitch`, bukan `AVAudioUnitVarispeed`:** `Varispeed` mengubah pitch & rate sekaligus (seperti speed biasa). `TimePitch` memisahkan keduanya — persis kebutuhan kita.

### 4.5 Wrapper Dart — plugin `melodic_audio`

> **Keputusan:** engine audio ditulis sebagai **plugin Flutter federated sendiri** bernama `melodic_audio` (lihat section 10.1), bukan fork `just_audio`.

```dart
// melodic_audio/lib/melodic_audio.dart (public API plugin)
abstract class MelodicAudio {
  Future<void> play({required String path, required SourceType type});
  Future<void> pause();
  Future<void> resume();
  Future<void> seek(Duration position);
  Future<void> stop();

  Future<void> setPitch(double ratio);   // 0.5–2.0, tempo terkunci
  Future<void> setTempo(double ratio);   // default 1.0
  Stream<Duration> get positionStream;
  Stream<PlayerEvent> get eventStream;
}

// data/datasources/dsp_channel.dart (consumer di app)
class DspChannel implements MelodicAudio {
  DspChannel(this._plugin);
  final MelodicAudio _plugin;
  // delegasi + logging + error mapping → Failure
}
```

Federated structure plugin:
```text
melodic_audio/
├── melodic_audio/              # Dart interface + common models
├── melodic_audio_android/      # ExoPlayer + PitchAudioProcessor (Kotlin)
├── melodic_audio_ios/          # AVAudioEngine + TimePitch (Swift)
```

---

## 5. State Management — Riverpod Provider Graph

```text
┌─────────────────────────────────────────────────────────────┐
│  dspChannelProvider          (DataSource, singleton)        │
│  hiveProvider                (Box accessor)                 │
│  dioProvider                 (Dio + interceptors)           │
└───────────────┬─────────────────────────────────────────────┘
                │
┌───────────────▼─────────────────────────────────────────────┐
│  audioPlayerRepositoryProvider  (Repository impl)           │
│  queueRepositoryProvider                                     │
│  musicLibraryRepositoryProvider                              │
│  onlineSearchRepositoryProvider                              │
│  lyricsRepositoryProvider                                    │
└───────────────┬─────────────────────────────────────────────┘
                │
┌───────────────▼─────────────────────────────────────────────┐
│  playerControllerProvider   (StateNotifier<PlayerState>)    │
│  queueControllerProvider    (StateNotifier<QueueState>)     │
│  frequencyControllerProvider(StateNotifier<FrequencyState>) │
│  searchControllerProvider   (StateNotifier<SearchState>)    │
│  lyricsControllerProvider   (StateNotifier<LyricsState>)    │
└───────────────┬─────────────────────────────────────────────┘
                │
        ┌───────┴────────┬──────────────┬─────────────┐
        ▼                ▼              ▼             ▼
   PlayerScreen     MiniPlayerBar   SearchScreen  LyricsPanel
```

### State shape utama

```dart
@freezed
class PlayerState with _$PlayerState {
  const factory PlayerState({
    required Track? currentTrack,
    required PlayerStatus status,      // loading / playing / paused / completed / error
    required Duration position,
    required Duration duration,
    required double volume,
    required double tempo,             // default 1.0
  }) = _PlayerState;
}

@freezed
class FrequencyState with _$FrequencyState {
  const factory FrequencyState({
    required double frequencyHz,       // default 440
    required PresetOrigin origin,      // presetStandard / preset432 / preset528 / custom
  }) = _FrequencyState;
}
```

**Aturan:** `frequencyControllerProvider` memanggil `pitchRatioForFrequency()` lalu meneruskan ratio ke `playerControllerProvider.setPitch(ratio)`. UI **tidak pernah** menyentuh MethodChannel langsung.

---

## 6. Backend API Contract

**Base URL:** `https://api.melodicdsp.app/v1` (sementara: Railway PR preview URL)
**Auth:** `X-API-Key` header (di-embed di app, rotate per release)

### 6.1 `GET /search`

```jsonc
// Request
GET /search?q=fade%20into%20you&type=track&limit=20

// Response 200
{
  "tracks": [
    {
      "id": "audius:D7yKj9...",
      "title": "Fade Into You",
      "artist": "Mazzy Star",
      "album": "So Tonight That I Might See",
      "durationMs": 263000,
      "coverUrl": "https://.../cover.jpg",
      "provider": "audius",
      "isPreview": false
    }
  ],
  "total": 1,
  "cacheHit": true
}
```

### 6.2 `GET /track/{id}` → metadata lengkap + streamUrl segar

```jsonc
{
  "id": "audius:D7yKj9...",
  "title": "Fade Into You",
  "artist": "Mazzy Star",
  "album": "...",
  "durationMs": 263000,
  "coverUrl": "https://.../cover.jpg",
  "streamUrl": "https://discoveryprovider.audius.co/v1/tracks/.../stream",
  "streamExpiresAt": "2026-10-05T13:10:00Z",
  "provider": "audius",
  "isPreview": false
}
```

### 6.3 `GET /stream/{id}` → 302 redirect ke CDN URL (client memutar langsung)
### 6.4 `GET /cover/{id}` → 200 image/webp (cache 30 hari)
### 6.5 `GET /health` → `{"status":"ok","providers":{"audius":"up","deezer":"up","jamendo":"up"}}`

### 6.6 `AudioProvider` interface & fallback chain

```python
class AudioProvider(Protocol):
    async def search(self, q: str, limit: int) -> list[TrackDTO]: ...
    async def resolve(self, track_id: str) -> ResolvedTrackDTO: ...  # fresh streamUrl
    @property
    def name(self) -> str: ...

# Chain: Audius → Deezer (preview 30s) → Jamendo (CC)
```

- **Audius** — stream penuh, gratis, no API key (discovery node)
- **Deezer** — metadata kaya + preview 30 detik (butuh API key)
- **Jamendo** — musik Creative Commons (butuh API key)

### 6.7 Aturan caching & limit

- **Redis cache:** search result TTL 24 jam, `streamUrl` TTL 10 menit (sesuai expiry provider).
- **Rate limit:** 100 req/menit/IP (slowapi), burst 20.
- **Error code:** `429` (rate limited), `502` (semua provider down), `404` (track tidak ada).

---

## 7. Persistensi Lokal (Hive)

| Box | Isi | TTL |
|---|---|---|
| `queueBox` | Daftar `QueueItem` + currentIndex | Permanen |
| `recentsBox` | 50 track terakhir diputar (key: timestamp) | Permanen |
| `searchHistoryBox` | 20 query terakhir | Permanen |
| `playlistsBox` | Playlist user + items | Permanen |
| `cacheMetaBox` | Metadata track online (key: trackId) | 7 hari |
| `lyricsBox` | LRC mentah (key: `artist\|title`) | 30 hari |

**Audio cache:** disimpan di `getApplicationCacheDirectory()`, dibatasi **200 MB total**, **20 MB/tracks**, eviction LRU. Hanya untuk provider yang CDN-nya legal untuk di-cache.

---

## 8. Strategi Error Handling

| Skenario | Penanganan |
|---|---|
| Stream URL expired (401/403 saat play) | Auto re-fetch `/track/{id}`, maks. 1 retry; gagal → skip + toast |
| Offline mode | Banner non-intrusif, queue online di-marker "unavailable", local tetap jalan |
| Backend 502 (semua provider down) | Toast "Layanan online sedang tidak tersedia", tab search menampilkan cached results |
| Rate limited (429) | Backoff eksponensial (1s, 2s, 4s) + pesan "coba lagi sebentar" |
| File lokal corrupt / DRM | Skip track, log ke Sentry (opt-in), tetap di queue tapi disabled |
| Permission storage ditolak | Empty state dengan tombol "Buka pengaturan" (deep link settings) |

Semua failure memakai pattern `Either<Failure, T>` (dartz) di repository layer — tidak ada exception leak ke UI.

---

## 9. Strategi Testing

| Layer | Tools | Target |
|---|---|---|
| **Unit (Dart)** | `flutter_test`, `mocktail` | 100% logic: pitch_math, queue manager, lrc parser, repository |
| **Widget** | `flutter_test` | Key screens (mini player, tuner sheet, search) |
| **Integration** | `integration_test` | E2E: scan → play → background → resume |
| **Backend** | `pytest`, `httpx.AsyncClient`, `pytest-asyncio` | 100% endpoint + provider fallback |
| **Manual DSP** | Checklist QA Android + iOS | Pitch 432/528 tanpa artifact, latency < 50ms |

**CI gates:** `analyze` + `test` + `coverage ≥ 80%` (logic layer) sebelum merge ke `main`.

---

## 10. Keputusan Teknis (Locked)

| # | Pertanyaan | Keputusan | Alasan |
|---|---|---|---|
| 1 | Fork `just_audio` atau plugin sendiri? | ✅ **Plugin sendiri: `melodic_audio`** (federated) | Kontrol penuh atas DSP, tidak terikat upstream. Estimasi +2–3 minggu di Fase 1 |
| 2 | Persistence: Hive atau Isar? | **Hive CE** (rekomendasi) | Matang, komunitas besar — konfirmasi saat Fase 1 mulai |
| 3 | Routing: GoRouter atau auto_route? | **GoRouter** (rekomendasi) | Official, declarative — konfirmasi saat Fase 2 mulai |
| 4 | Backend host? | ✅ **Railway** | Cold start cepat, deploy dari git langsung, free tier cukup untuk beta |
| 5 | Provider legal mana saja? | ✅ **Audius + Deezer + Jamendo** (iTunes **dihapus**) | Audius stream penuh, Deezer metadata mainstream, Jamendo arsip CC |
| 6 | Minimum Android SDK? | **minSdk 21** | Coverage 99%+, ExoPlayer butuh API 21+ |
| 7 | Minimum iOS version? | **iOS 14** | AVAudioUnitTimePitch stabil, coverage baik |

### 10.1 Catatan implementasi `melodic_audio`

Karena memilih plugin sendiri, **Fase 1 roadmap bertambah ~2–3 minggu** untuk:
- Mendefinisikan public API + model (`PlayerEvent`, `SourceType`) di package Dart
- Implementasi Android (Kotlin/ExoPlayer + `PitchAudioProcessor`)
- Implementasi iOS (Swift/AVAudioEngine + `AVAudioUnitTimePitch`)
- Unit test platform masing-masing + contoh app demo plugin

**Saran:** plugin diinisialisasi **lebih dulu** di Fase 0 (sebagai bagian PoC), sehingga Fase 1 tinggal integrasi ke app utama. PoC Minggu 2 sudah menghasilkan skeleton plugin federated ini.

---

## 11. Dependensi Yang Direncanakan

```yaml
# pubspec.yaml (inti) — app utama
dependencies:
  melodic_audio:                   # plugin federated internal (path/git dep)
    path: ../melodic_audio
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  go_router: ^14.0.0
  dio: ^5.4.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  cached_network_image: ^3.3.1
  audio_service: ^0.18.13          # media notification, connect ke melodic_audio
  on_audio_query: ^2.9.0
  permission_handler: ^11.3.0
  dartz: ^0.10.1
  sentry_flutter: ^8.4.0

dev_dependencies:
  build_runner: ^2.4.9
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.3
  hive_generator: ^2.0.1
  very_good_analysis: ^6.0.0
  mocktail: ^1.0.4
  integration_test:
    sdk: flutter
```

```yaml
# melodic_audio/pubspec.yaml — plugin Dart interface
dependencies:
  flutter:
    sdk: flutter
  plugin_platform_interface: ^2.1.8
```

> **Catatan:** Native Android memakai `androidx.media3:media3-exoplayer:1.x` + `media3-common`.
> iOS memakai `AVAudioEngine` + `AVAudioUnitTimePitch` (framework bawaan, no pod tambahan).
> **`audio_service`** tetap dipakai untuk media notification & lockscreen — cukup connect ke stream `melodic_audio`.

---

## 12. Referensi

- ExoPlayer custom audio sink: `androidx.media3` docs — "Customizing audio processing"
- `AVAudioUnitTimePitch`: Apple Developer docs — pitch & rate independen
- Audius API: `docs.audius.org` (discovery node, no auth untuk stream)
- Deezer API: `developers.deezer.com` (butuh API key, preview 30 detik)
- Jamendo API: `developer.jamendo.com` (client ID, musik CC)
- LRCLIB: `lrclib.net/docs` — `/api/get` & `/api/search`
- Hive CE: pub.dev/packages/hive_ce
- Flutter federated plugin: docs.flutter.dev — "Developing plugin packages"
