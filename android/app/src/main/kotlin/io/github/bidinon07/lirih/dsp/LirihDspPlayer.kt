package io.github.bidinon07.lirih.dsp

import android.content.Context
import android.util.Log
import androidx.media3.common.AudioAttributes
import androidx.media3.common.MediaItem
import androidx.media3.common.MediaMetadata
import androidx.media3.common.PlaybackException
import androidx.media3.common.PlaybackParameters
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import java.io.File
import kotlin.math.log2

/**
 * Pemutar audio native **Lirih** — PoC task **0.6** (pitch shift tempo-locked).
 *
 * Membungkus [ExoPlayer] (Media3) dan menyediakan kontrol **pitch** serta
 * **tempo** yang independen. Pitch diterapkan via [PlaybackParameters]:
 * media3 meneruskannya ke `AudioTrack`, yang melakukan *time-stretch* pada
 * API 23+ sehingga **tempo tetap konstan** saat tinggi nada berubah.
 *
 * Catatan desain (lihat `MelodicDSP-Technical-Design-Doc.md` §4.3): bila
 * kualitas jalur ini tidak lolos validasi 0.9 (artifact pada 432/528 Hz),
 * pitch dipindahkan ke `PitchAudioProcessor` (Sonic) pada custom audio sink.
 * Method [setPitch] tetap menjadi kontrak tunggal sehingga penggantian mesin
 * tidak mengubah sisi Dart.
 */
class LirihDspPlayer(private val context: Context) {

    private var player: ExoPlayer? = null
    private var tempo: Float = 1.0f
    private var pitch: Float = 1.0f

    /**
     * Callback event ke Dart: `("completed", null)` saat playback selesai,
     * `("error", pesan)` saat terjadi kegagalan.
     */
    var onEvent: ((event: String, extra: String?) -> Unit)? = null

    /** Membuat [ExoPlayer] secara malas dan memasang listener event. */
    private fun ensurePlayer(): ExoPlayer {
        player?.let { return it }
        val newPlayer = ExoPlayer.Builder(context).build()
        // Handle audio focus otomatis (jeda saat notifikasi/panggilan) dan
        // jeda saat headphone dicabut (task 1.7).
        newPlayer.setAudioAttributes(AudioAttributes.DEFAULT, true)
        newPlayer.setHandleAudioBecomingNoisy(true)
        newPlayer.addListener(
            object : Player.Listener {
                override fun onPlaybackStateChanged(playbackState: Int) {
                    if (playbackState == Player.STATE_ENDED) {
                        onEvent?.invoke("completed", null)
                    }
                }

                override fun onPlayerError(error: PlaybackException) {
                    Log.e(TAG, "Player error", error)
                    onEvent?.invoke("error", error.message)
                }
            },
        )
        player = newPlayer
        return newPlayer
    }

    /**
     * Instance [ExoPlayer] aktif (dibuat malas). Dipakai
     * [LirihPlaybackService] untuk membangun [MediaSession] agar kontrol
     * media (notifikasi/lockscreen) menggerakkan pemutar yang sama.
     */
    internal fun sessionPlayer(): ExoPlayer = ensurePlayer()

    /**
     * Memutar berkas audio di [path] (absolute filesystem path).
     *
     * Metadata opsional ([title], [artist], [artUri]) dipasang ke
     * [MediaItem] sehingga notifikasi media & lockscreen (task 1.7)
     * menampilkan judul, artis, dan sampul album. Tanpa metadata,
     * notifikasi media3 tampil kosong — pada beberapa perangkat (mis.
     * MIUI/HyperOS) notifikasi kosong bahkan disembunyikan.
     */
    fun playFile(
        path: String,
        title: String? = null,
        artist: String? = null,
        artUri: String? = null,
    ) {
        val uri = if (path.startsWith("content:") || path.startsWith("file:")) {
            android.net.Uri.parse(path)
        } else {
            android.net.Uri.fromFile(File(path))
        }
        Log.i(TAG, "playFile: $uri")
        val metadata = MediaMetadata.Builder()
            .setTitle(title ?: "Lirih")
            .setArtist(artist)
            .setArtworkUri(artUri?.let(android.net.Uri::parse))
            .build()
        with(ensurePlayer()) {
            stop()
            clearMediaItems()
            setMediaItem(
                MediaItem.Builder()
                    .setUri(uri)
                    .setMediaMetadata(metadata)
                    .build(),
            )
            prepare()
            play()
        }
    }

    /** Menjeda playback. */
    fun pause() = player?.pause() ?: Unit

    /** Melanjutkan playback. */
    fun resume() = player?.play() ?: Unit

    /** Menghentikan dan melepas media item. */
    fun stop() = player?.stop() ?: Unit

    /** Melompat ke posisi [positionMs] (milidetik). */
    fun seek(positionMs: Long) = player?.seekTo(positionMs) ?: Unit

    /**
     * Mengatur rasio pitch (0.5–2.0). `1.0` = tidak berubah; `432/440`
     * ≈ 0.9818 untuk preset 432 Hz. Berlaku real-time tanpa memutus lagu.
     */
    fun setPitch(ratio: Float) {
        pitch = ratio.coerceIn(MIN_RATIO, MAX_RATIO)
        applyParameters()
    }

    /**
     * Mengatur rasio tempo (0.5–2.0), terpisah dari pitch — tempo tidak
     * mengubah tinggi nada dan sebaliknya.
     */
    fun setTempo(ratio: Float) {
        tempo = ratio.coerceIn(MIN_RATIO, MAX_RATIO)
        applyParameters()
    }

    /** Rasio pitch aktif. */
    fun getPitch(): Float = pitch

    /** Posisi playback saat ini dalam milidetik. */
    fun getPosition(): Long = player?.currentPosition ?: 0L

    /** Durasi media saat ini dalam milidetik. */
    fun getDuration(): Long = player?.duration ?: 0L

    /** Melepas seluruh sumber daya audio. */
    fun release() {
        player?.release()
        player = null
    }

    private fun applyParameters() {
        val p = ensurePlayer()
        p.playbackParameters = PlaybackParameters(tempo, pitch)
        val cents = 1200.0 * log2(pitch.toDouble())
        Log.i(TAG, "tempo=$tempo pitch=$pitch (offset ${"%.2f".format(cents)} cents)")
    }

    companion object {
        private const val TAG = "LirihDsp"

        /** Rentang aman pitch & tempo sesuai spec (task 0.4 / TDD §4). */
        private const val MIN_RATIO = 0.5f
        private const val MAX_RATIO = 2.0f
    }
}
