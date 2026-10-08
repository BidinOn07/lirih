plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "io.github.bidinon07.lirih"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Task 0N.4 — applicationId TERKUNCI, tidak bisa diubah setelah AAB pertama diunggah.
        applicationId = "io.github.bidinon07.lirih"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        //
        // Task 0.2 — keputusan 6 Okt 2026:
        //   minSdk    = 24  (Android 7.0 — default Flutter 3.35; ganti ke 21 bila perlu Android 5.0)
        //   targetSdk = 36  (via flutter.targetSdkVersion — wajib ikut versi terbaru agar lolos Play)
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    // ── Media3 / ExoPlayer (task 0.6 — PoC pitch shift) ───────────────
    // 1.11.1 (10 Sep 2026) — stable terbaru, kompatibel compileSdk 36.
    // Lisensi Apache-2.0 → dicatat di THIRD_PARTY_NOTICES.md (R9).
    // Hanya modul inti: MP3/WAV/AAC/M4A ditangani extractor bawaan +
    // dekoder platform (MediaCodec). FLAC: dekoder platform hanya ada di
    // API 31+, dan ekstensi native media3 (media3-decoder-flac) TIDAK
    // diterbitkan di Maven (harus dibangun dari source media3 + NDK) —
    // lihat catatan risiko di AGENTS.md. Ditangani terpisah untuk v1.
    implementation("androidx.media3:media3-exoplayer:1.11.1")
    // MediaSession + foreground service untuk background playback, notifikasi,
    // dan kontrol lockscreen (task 1.7).
    implementation("androidx.media3:media3-session:1.11.1")
}

flutter {
    source = "../.."
}
