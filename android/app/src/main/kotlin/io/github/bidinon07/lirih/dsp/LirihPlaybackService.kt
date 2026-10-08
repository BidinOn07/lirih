package io.github.bidinon07.lirih.dsp

import android.app.PendingIntent
import android.content.Intent
import androidx.media3.session.MediaSession
import androidx.media3.session.MediaSessionService
import io.github.bidinon07.lirih.MainActivity

/**
 * Foreground service pemutar **Lirih** (task 1.7).
 *
 * Membungkus [LirihDspPlayer] (yang dimiliki [DspPlugin]) dalam sebuah
 * [MediaSession] sehingga:
 *
 * - playback **tetap berjalan saat aplikasi di-background** atau layar mati;
 * - kontrol muncul di notifikasi media dan lockscreen;
 * - audio focus dikelola (jeda otomatis saat panggilan/notifikasi).
 *
 * Service ini **tidak memiliki** player sendiri — ia memakai instance yang
 * sama dengan UI (via [PlaybackHost]) agar pitch & posisi selalu sinkron.
 * Notifikasi memakai `DefaultMediaNotificationProvider` bawaan media3.
 */
class LirihPlaybackService : MediaSessionService() {

    private var mediaSession: MediaSession? = null

    override fun onCreate() {
        super.onCreate()

        val player = PlaybackHost.player
        if (player == null) {
            // Tidak ada yang diputar — tidak perlu ada session.
            stopSelf()
            return
        }

        val sessionActivity = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            sessionActivity,
            PendingIntent.FLAG_IMMUTABLE,
        )

        val session = MediaSession.Builder(this, player.sessionPlayer())
            .setSessionActivity(pendingIntent)
            .build()
        mediaSession = session
    }

    override fun onGetSession(
        controllerInfo: MediaSession.ControllerInfo,
    ): MediaSession? = mediaSession

    override fun onDestroy() {
        mediaSession?.release()
        mediaSession = null
        super.onDestroy()
    }
}
