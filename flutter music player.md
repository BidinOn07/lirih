# Project Specification: Flutter Spotify-Style Music Player with Custom Frequency Tuner

## 1. Project Overview & Objectives
*   **Project Name:** Flutter Custom Music Player (Code Name: MelodicDSP)
*   **Target Platform:** Mobile (Android & iOS) using **Flutter (Dart)**.
*   **Core Concept:** A premium, ad-free music player combining an intuitive Spotify-like UI with two major pillars:
    1.  **Dual Source Streaming:** Stream tracks online without forced user login (via a lightweight backend extractor) AND play local audio files stored on the device.
    2.  **Acoustic Frequency Shifter:** Real-time frequency tuning (e.g., 432Hz, 528Hz) using pitch-shifting with tempo-lock, ensuring the song's speed remains unaltered.

---

## 2. Tech Stack & Dependencies
*   **Framework:** Flutter (Dart)
*   **State Management:** `flutter_riverpod` or `flutter_bloc`
*   **Audio Engine:** `just_audio` (Handles playback, volume, speed, and pitch control)
*   **Background Play & Lockscreen:** `audio_service`
*   **Local File Scanning:** `on_audio_query` & `permission_handler`
*   **Network & API Client:** `dio` or `http`
*   **Image Caching:** `cached_network_image`
*   **Online Stream Extractor (Backend):** Python FastAPI / Node.js microservice using `yt-dlp` (deployed on Render/Railway) to fetch direct stream URLs securely without client-side login.

---

## 3. Core Features & Functional Requirements

### A. Dual Source Playback & Unified Queue
*   **Online Search & Stream:** Users can search for any song via the online search bar. The app fetches the direct audio stream URL from the lightweight backend.
*   **Local Library Scanner:** Scans internal device storage for audio files (MP3, FLAC, WAV, AAC) and displays them neatly by Tracks, Artists, and Albums.
*   **Unified Queue:** Users can mix online streaming tracks and local storage files seamlessly into a single active playback queue.

### B. Killer Feature: Custom Frequency Tuner (DSP Engine)
*   Allows users to change the master tuning frequency of the audio output in real-time.
*   **Presets Menu:**
    *   **Standard (440 Hz):** Pitch ratio `1.0` (Original default).
    *   **Verdi’s Tuning (432 Hz):** Pitch ratio `~0.9818` (Warm, organic tone; lowers pitch by ~31.77 cents).
    *   **Solfeggio Frequency (528 Hz):** Pitch ratio `~1.2` (Meditative tone).
    *   **Custom Adjuster:** Fine-tuning slider for experimental frequencies.
*   **Technical Rule:** Pitch adjustment must use *independent pitch and tempo scaling* so that song speed / tempo remains locked at `1.0x`.

### C. Spotify Premium UI/UX Design System
*   **Theme:** Dark Mode dominant (`#121212` background, `#1DB954` or sleek neutral accents).
*   **Layout Structure:**
    *   *Home / Browse Screen:* Recent plays, recommendations, and quick access grids.
    *   *Search Screen:* Instant search bar with clear filters (Online vs. Local).
    *   *Library Screen:* Local folders & playlist manager.
    *   *Persistent Bottom Player Bar:* Mini player pinned above bottom navigation with quick play/pause and progress bar.
    *   *Immersive Full-Screen Player:* Large album art, synchronized lyrics panel, frequency switcher dropdown, and playback controls.

### D. Advanced Enhancements
*   **Background & Lockscreen Playback:** Integrated with `audio_service` so audio continues when the app is minimized or the screen is locked, complete with notification controls.
*   **Synchronized Lyrics:** Fetches time-synced lyrics (.lrc format) using the public **LRCLIB API** based on track metadata.
*   **Offline Caching:** Automatically caches streamed audio chunks locally for smoother replays and reduced data usage.

---

## 4. Architecture & Directory Structure (Flutter)
```text
lib/
│
├── core/
│   ├── constants/       # App colors, themes, API endpoints
│   └── services/        # Audio service, local storage scanner
│
├── features/
│   ├── player/          # Audio controller, frequency shifter logic, player UI
│   ├── search/          # Online search & backend integration
│   ├── library/         # Local file scanner & playlist management
│   └── lyrics/          # Synced lyrics parser & widget
│
├── shared/
│   └── widgets/         # Reusable buttons, cards, bottom player bar
│
└── main.py / app.dart   # App entry point & provider scope