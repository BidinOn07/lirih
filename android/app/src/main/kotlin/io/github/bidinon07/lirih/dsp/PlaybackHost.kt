package io.github.bidinon07.lirih.dsp

/**
 * Pemegang *process-wide* untuk [LirihDspPlayer] — jembatan antara
 * [DspPlugin] (di Activity) dan [LirihPlaybackService] (foreground service).
 *
 * Keduanya berjalan di proses yang sama, sehingga service dapat membangun
 * [androidx.media3.session.MediaSession] di sekitar instance ExoPlayer yang
 * **sama** yang dikendalikan Dart. DspPlugin mengisi [player] sebelum
 * memulai service; service membacanya di `onCreate`.
 */
object PlaybackHost {

    /** Instance pemutar aktif, atau `null` bila belum ada playback. */
    @Volatile
    var player: LirihDspPlayer? = null
}
