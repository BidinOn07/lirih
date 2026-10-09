package io.github.bidinon07.lirih.dsp

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import androidx.media3.session.DefaultMediaNotificationProvider
import androidx.media3.session.MediaSession
import androidx.media3.session.MediaSessionService
import io.github.bidinon07.lirih.MainActivity

/// ID notifikasi & channel — dipakai **bersama** oleh notifikasi sementara
/// yang diposting sinkron di [onCreate] (lihat [startForegroundImmediately])
/// maupun oleh `DefaultMediaNotificationProvider`. Karena ID-nya sama, saat
/// media3 selesai membangun notifikasi lengkap (judul/artis/sampul/kontrol)
/// ia **menggantikan** notifikasi sementara — bukan menambah notifikasi kedua.
private const val NOTIFICATION_ID = 1001
private const val CHANNEL_ID = "lirih_playback"

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
 *
 * ## Mengapa `startForeground()` dipanggil manual di [onCreate]
 *
 * `DspPlugin` memanggil `startForegroundService()` tepat saat ExoPlayer
 * transisi ke state *playing*. Mekanisme notifikasi otomatis media3 bersifat
 * **reaktif terhadap event perubahan state player**, namun:
 *
 * 1. Session baru dibuat di `onCreate` ini — event transisi *playing* sudah
 *    lewat sebelum session terdaftar di notification manager;
 * 2. Intent start service kita **tidak membawa media action**, sehingga
 *    `onStartCommand` bawaan media3 mengabaikannya dan session tak pernah
 *    ditambahkan secara otomatis;
 * 3. Pipeline notifikasi media3 **asinkron** (koneksi `MediaController` +
 *    pemuatan bitmap sampul).
 *
 * Sistem hanya memberi ~5-10 detik; bila `startForeground()` belum juga
 * dipanggil, **aplikasi dibunuh** dengan
 * `ForegroundServiceDidNotStartInTimeException`. Karena itu notifikasi
 * minimal diposting **sinkron** di [onCreate] (memenuhi deadline), lalu
 * digantikan media3 dengan notifikasi lengkap di ID yang sama.
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

        createNotificationChannel()

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

        // Provider WAJIB dipasang SEBELUM addSession agar
        // MediaNotificationManager dibuat dengan ID/channel yang sama dengan
        // notifikasi sementara — jika tidak, media3 memakai default (1001 /
        // "default_channel_id") dan notifikasi ganda muncul.
        setMediaNotificationProvider(
            DefaultMediaNotificationProvider.Builder(this)
                .setNotificationId(NOTIFICATION_ID)
                .setChannelId(CHANNEL_ID)
                .build(),
        )

        // Memenuhi deadline foreground service seketika (lihat kdoc kelas).
        startForegroundImmediately()

        // Mendaftarkan session ke notification manager media3. Tanpa panggilan
        // eksplisit ini, notifikasi media tak pernah dibuat karena intent
        // start service tidak membawa media action (lihat kdoc kelas butir 2).
        addSession(session)
    }

    override fun onGetSession(
        controllerInfo: MediaSession.ControllerInfo,
    ): MediaSession? = mediaSession

    override fun onDestroy() {
        mediaSession?.release()
        mediaSession = null
        super.onDestroy()
    }

    // ── Notifikasi foreground segera ─────────────────────────────────────

    /**
     * Membuat [CHANNEL_ID] (API 26+). Channel dibuat sekali di sini agar
     * notifikasi sementara bisa langsung diposting; `DefaultMediaNotification
     * Provider` melihat channel sudah ada dan tidak menimpanya.
     */
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(NotificationManager::class.java)
        if (manager?.getNotificationChannel(CHANNEL_ID) != null) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Pemutar Lirih",
            NotificationManager.IMPORTANCE_LOW,
        )
        manager?.createNotificationChannel(channel)
    }

    /**
     * Memanggil `startForeground()` **sinkron** dengan notifikasi minimal.
     *
     * Notifikasi ini bersifat sementara — segera setelah media3 menyelesaikan
     * pipeline-nya (Metadata + sampul + tombol play/jeda), notifikasi pada
     * [NOTIFICATION_ID] yang sama ditimpa dengan versi lengkap.
     */
    private fun startForegroundImmediately() {
        val notification = buildBaseNotification()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK,
            )
        } else {
            @Suppress("DEPRECATION")
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    /**
     * Notifikasi minimal saat service baru saja start. Memakai ikon sistem
     * karena ini hanya mengisi slot selama ~1 detik sebelum media3 menggantinya.
     */
    private fun buildBaseNotification(): Notification {
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
        return builder
            .setSmallIcon(android.R.drawable.ic_media_play)
            .setContentTitle("Lirih")
            .setContentText("Memutar musik")
            .setOngoing(true)
            .build()
    }
}
