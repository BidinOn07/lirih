package io.github.bidinon07.lirih.dsp

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.Bundle
import androidx.media3.common.Player
import androidx.media3.session.CommandButton
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
            .setCustomLayout(buildCustomLayout())
            .setCallback(object : MediaSession.Callback {
                override fun onConnect(
                    session: MediaSession,
                    controller: MediaSession.ControllerInfo,
                ): MediaSession.ConnectionResult {
                    // Daftarkan aksi kustom agar tombolnya dapat ditekan.
                    val commands = MediaSession.ConnectionResult.DEFAULT_SESSION_COMMANDS
                        .buildUpon()
                    for (command in NotificationActions.allActions) {
                        commands.add(command)
                    }
                    return MediaSession.ConnectionResult.AcceptedResultBuilder(session)
                        .setAvailableSessionCommands(commands.build())
                        // Beberkan command transport yang **berfungsi** di
                        // pemutar satu-trek kita: play/pause (mengisi slot
                        // tengah standar notifikasi) & seek (progress bar).
                        //
                        // Tetap JANGAN beberkan seek prev/next, repeat, shuffle
                        // — player hanya memegang satu MediaItem (antrean di
                        // Dart), jadi tombol standarnya tidak berfungsi dan
                        // MIUI/HyperOS merendernya dobel dengan tombol kustom.
                        //
                        // JANGAN pakai Player.Commands.EMPTY di sini: tanpa aksi
                        // transport, PlaybackState.actions jadi minim dan sistem
                        // tak menganggap session ini "active media session" →
                        // mediaPlayback FGS kehilangan exemption & dibunuh
                        // setelah ~17 menit app idle (notifikasi hilang).
                        .setAvailablePlayerCommands(notificationPlayerCommands())
                        .setCustomLayout(buildCustomLayout())
                        .build()
                }

                override fun onCustomCommand(
                    session: MediaSession,
                    controller: MediaSession.ControllerInfo,
                    customCommand: androidx.media3.session.SessionCommand,
                    args: Bundle,
                ): com.google.common.util.concurrent.ListenableFuture<
                    androidx.media3.session.SessionResult,
                > {
                    val action = customCommand.customAction
                    if (action != null) {
                        NotificationActions.onAction?.invoke(action)
                    }
                    return com.google.common.util.concurrent.Futures.immediateFuture(
                        androidx.media3.session.SessionResult(
                            androidx.media3.session.SessionResult.RESULT_SUCCESS,
                        ),
                    )
                }
            })
            .build()
        mediaSession = session

        // Tombol tombol mengandalkan state pemutar — dengarkan perubahan
        // agar ikon (play/pause, repeat) tetap sinkron.
        player.sessionPlayer().addListener(object : Player.Listener {
            override fun onIsPlayingChanged(isPlaying: Boolean) {
                refreshLayout()
            }
        })

        // Saat Dart mendorong state tombol (shuffle/repeat/favorit), bangun
        // ulang custom layout agar ikon notifikasi segar (task 3.5).
        NotificationActions.onStateChanged = { refreshLayout() }

        // Provider WAJIB dipasang SEBELUM addSession agar
        // MediaNotificationManager dibuat dengan ID/channel yang sama dengan
        // notifikasi sementara — jika tidak, media3 memakai default (1001 /
        // "default_channel_id") dan notifikasi ganda muncul.
        //
        // Memakai [LirihMediaNotificationProvider] (bukan default) agar
        // urutan tombol kustom dihormati — lihat kdoc kelas tersebut.
        setMediaNotificationProvider(
            LirihMediaNotificationProvider.create(this, NOTIFICATION_ID, CHANNEL_ID),
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

    // ── Tombol kustom notifikasi (task 3.5) ─────────────────────────────

    /**
     * Membangun baris tombol kustom notifikasi — didelegasikan ke
     * [NotificationActions.buildNotificationButtons] agar urutan, ikon, dan
     * penyaringan tombol putar/jeda (slot tengah standar di Android 13+)
     * konsisten dengan [LirihMediaNotificationProvider].
     */
    private fun buildCustomLayout(): List<CommandButton> =
        NotificationActions.buildNotificationButtons(this)

    /**
     * Command player yang dibebarkan ke controller (notif/lockscreen).
     *
     * Hanya transport yang benar-benar berfungsi pada pemutar satu-trek:
     * [Player.COMMAND_PLAY_PAUSE] mengisi slot tengah standar notifikasi,
     * [Player.COMMAND_SEEK_IN_CURRENT_MEDIA_ITEM] menggambar progress bar.
     * Command seek prev/next, repeat, shuffle sengaja dikecualikan — lihat
     * kdoc [onConnect].
     */
    private fun notificationPlayerCommands(): Player.Commands =
        Player.Commands.Builder()
            .add(Player.COMMAND_PLAY_PAUSE)
            .add(Player.COMMAND_PREPARE)
            .add(Player.COMMAND_STOP)
            .add(Player.COMMAND_SEEK_TO_DEFAULT_POSITION)
            .add(Player.COMMAND_SEEK_IN_CURRENT_MEDIA_ITEM)
            .build()

    /**
     * Memperbarui baris tombol notifikasi setelah state pemutar berubah
     * (mis. play → pause) — membangun ulang custom layout session.
     */
    private fun refreshLayout() {
        val player = PlaybackHost.player
        NotificationActions.state = NotificationActions.state.copy(
            isPlaying = player?.sessionPlayer()?.isPlaying == true,
        )
        mediaSession?.setCustomLayout(buildCustomLayout())
    }

    override fun onDestroy() {
        NotificationActions.onStateChanged = null
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
