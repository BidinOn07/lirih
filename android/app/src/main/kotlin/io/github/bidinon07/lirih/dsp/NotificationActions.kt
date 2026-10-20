package io.github.bidinon07.lirih.dsp

import android.content.Context
import android.os.Build
import android.os.Bundle
import androidx.media3.session.CommandButton
import androidx.media3.session.SessionCommand
import io.github.bidinon07.lirih.R

/**
 * Aksi kustom tombol notifikasi media (task 3.5).
 *
 * Karena ExoPlayer hanya memegang **satu** [LirihDspPlayer] MediaItem
 * (antrean dikelola di Dart), tombol standar media3 untuk next/prev tidak
 * bisa dipakai. Semua tombol notifikasi dibuat *custom command* dan
 * diteruskan ke [DspPlugin] lewat [onAction] agar [LirihPlaybackService]
 * tidak perlu memegang MethodChannel sendiri (service hidup terpisah
 * dari Activity).
 *
 * State tombol ([NotificationState]) didorong dari Dart setiap kali
 * pemutar berubah, sehingga ikon yang ditampilkan (mis. play vs pause,
 * repeat vs repeat-one, favorit terisi/kosong) selalu sinkron dengan
 * [LirihDspPlayer].
 *
 * Urutan baris tombol (lihat [allActions] & [buildButtons]):
 * **favorit, sebelumnya, putar/jeda, berikutnya, mode** — sama dengan
 * urutan mini player, kecuali ulang & acak digabung jadi satu tombol "mode"
 * agar muat di batas 5 slot notifikasi Android 13+ (favorit tetap di depan).
 * Di notifikasi (Android 13+), tombol putar/jeda kustom dibuang oleh
 * [buildNotificationButtons] karena slot tengah diisi tombol standar,
 * sehingga barisnya menjadi **favorit, sebelumnya, berikutnya, mode**
 * (maks. 5 slot; slot tengah = Putar/Jeda standar).
 */
object NotificationActions {

    /** Menandai/hapus trek aktif sebagai favorit. */
    const val ACTION_FAVORITE = "io.github.bidinon07.lirih.action.FAVORITE"

    /** Trek sebelumnya. */
    const val ACTION_PREVIOUS = "io.github.bidinon07.lirih.action.PREVIOUS"

    /** Jeda/lanjutkan pemutaran. */
    const val ACTION_TOGGLE_PLAY = "io.github.bidinon07.lirih.action.TOGGLE_PLAY"

    /** Trek berikutnya. */
    const val ACTION_NEXT = "io.github.bidinon07.lirih.action.NEXT"

    /**
     * Memutar mode pemutaran gabungan: mati → ulang semua → ulang satu →
     * acak → mati. Ulang & acak digabung dalam satu tombol agar semua fungsi
     * muat di batas 5 slot notifikasi (Android 13+).
     */
    const val ACTION_MODE = "io.github.bidinon07.lirih.action.MODE"

    /** Indeks tiap aksi di [allActions] — dipakai [buildButtons]. */
    private const val IDX_FAVORITE = 0
    private const val IDX_PREVIOUS = 1
    private const val IDX_TOGGLE_PLAY = 2
    private const val IDX_NEXT = 3
    private const val IDX_MODE = 4

    /** Semua aksi tombol kustom — sekaligus menentukan **urutan** baris. */
    val allActions: List<SessionCommand> = listOf(
        SessionCommand(ACTION_FAVORITE, Bundle.EMPTY),
        SessionCommand(ACTION_PREVIOUS, Bundle.EMPTY),
        SessionCommand(ACTION_TOGGLE_PLAY, Bundle.EMPTY),
        SessionCommand(ACTION_NEXT, Bundle.EMPTY),
        SessionCommand(ACTION_MODE, Bundle.EMPTY),
    )

    /**
     * State tampilan tombol — didorong dari Dart.
     *
     * @param isPlaying apakah pemutar sedang memutar (ikon play vs pause).
     * @param isShuffling apakah mode acak aktif.
     * @param repeatMode mode pengulangan: 0 = off, 1 = all, 2 = one.
     * @param isFavorite apakah trek aktif ditandai favorit.
     */
    data class NotificationState(
        val isPlaying: Boolean = false,
        val isShuffling: Boolean = false,
        val repeatMode: Int = 0,
        val isFavorite: Boolean = false,
    )

    /** State tombol saat ini — dibaca [LirihMediaNotificationProvider]
     * saat membangun baris tombol notifikasi. */
    @Volatile
    var state: NotificationState = NotificationState()

    /**
     * Dipanggil setiap kali [state] berubah — didaftarkan oleh
     * [LirihPlaybackService] agar notifikasi dibangun ulang (ikon play/pause,
     * repeat-one, favorit harus ikut berubah). Lihat [DspPlugin] handler
     * `setNotificationState`.
     */
    @Volatile
    var onStateChanged: (() -> Unit)? = null

    /** Dipanggil [LirihPlaybackService] saat tombol kustom ditekan. */
    @Volatile
    var onAction: ((action: String) -> Unit)? = null

    /**
     * Membangun baris tombol kustom **dalam urutan tetap** (favorit,
     * sebelumnya, putar/jeda, berikutnya, mode) sesuai [allActions].
     *
     * Ikon putar/jeda, mode, dan favorit bergantung [state].
     *
     * ## Penempatan slot (Android 13+ / MIUI-HyperOS)
     *
     * SystemUI Android 13+ menderivasi tombol media dari `PlaybackState`:
     * slot tengah (SLOT_CENTRAL) **selalu** diisi tombol Putar/Jeda standar
     * dari *state* playback, dan hanya menyediakan 5 slot. Karena itu layout
     * notifikasi yang dicapai: **[Favorit][Sebelumnya][Putar/Jeda]
     * [Berikutnya][Mode]** — gunakan [buildNotificationButtons] yang membuang
     * tombol putar/jeda kustom di API 33+ (lihat kdoc-nya).
     *
     * `CommandButton.setSlots` di sini sengaja dibuat **konsisten** dengan
     * urutan di [allActions] (favorit=BACK, sebelumnya=BACK_SECONDARY,
     * berikutnya=FORWARD, mode=FORWARD_SECONDARY) agar tak peduli apakah
     * perangkat memakai urutan custom action atau slot media3 untuk menata
     * tombol, hasilnya sama. Pada API < 33 (media3 merender notifikasinya
     * sendiri), compact view menjadi [Favorit][Putar/Jeda][Berikutnya].
     */
    fun buildButtons(context: Context): List<CommandButton> {
        val state = this.state
        return allActions.mapIndexed { index, command ->
            CommandButton.Builder()
                .setSessionCommand(command)
                .apply {
                    when (index) {
                        IDX_FAVORITE -> {
                            setSlots(CommandButton.SLOT_BACK)
                            setIconResId(
                                if (state.isFavorite) R.drawable.ic_favorite
                                else R.drawable.ic_favorite_border,
                            )
                            setDisplayName(
                                if (state.isFavorite) {
                                    "Hapus dari favorit"
                                } else {
                                    "Tambah ke favorit"
                                },
                            )
                        }
                        IDX_PREVIOUS -> {
                            setSlots(CommandButton.SLOT_BACK_SECONDARY)
                            setIconResId(R.drawable.ic_previous)
                            setDisplayName("Sebelumnya")
                        }
                        IDX_TOGGLE_PLAY -> {
                            setSlots(CommandButton.SLOT_CENTRAL)
                            setIconResId(
                                if (state.isPlaying) {
                                    R.drawable.ic_pause
                                } else {
                                    R.drawable.ic_play
                                },
                            )
                            setDisplayName(if (state.isPlaying) "Jeda" else "Putar")
                        }
                        IDX_NEXT -> {
                            setSlots(CommandButton.SLOT_FORWARD)
                            setIconResId(R.drawable.ic_next)
                            setDisplayName("Berikutnya")
                        }
                        IDX_MODE -> {
                            setSlots(CommandButton.SLOT_FORWARD_SECONDARY)
                            // Mode gabungan: acak > ulang-satu > ulang-semua >
                            // mati (prioritas agar tak ada mode ambigu).
                            when {
                                state.isShuffling -> {
                                    setIconResId(R.drawable.ic_shuffle)
                                    setDisplayName("Acak")
                                }
                                state.repeatMode == 2 -> {
                                    setIconResId(R.drawable.ic_repeat_one)
                                    setDisplayName("Ulang satu")
                                }
                                state.repeatMode == 1 -> {
                                    setIconResId(R.drawable.ic_repeat)
                                    setDisplayName("Ulang semua")
                                }
                                else -> {
                                    setIconResId(R.drawable.ic_repeat)
                                    setDisplayName("Ulang")
                                }
                            }
                        }
                    }
                }
                .build()
        }
    }

    /**
     * Baris tombol untuk **notifikasi media** — sama dengan [buildButtons],
     * kecuali tombol putar/jeda kustom dibuang di Android 13+ (API 33+).
     *
     * SystemUI Android 13+ **memaksa** tombol Putar/Jeda standar di slot
     * tengah (diturunkan dari *state* playback, bukan dari custom action).
     * Bila tombol kustom putar/jeda tetap disertakan, akan muncul **dua**
     * tombol putar/jeda (standar + kustom). Karena itu di API 33+ kita
     * mengandalkan tombol standar tersebut — ia memanggil `play()`/`pause()`
     * player sesi secara langsung, dan Dart turut diberi tahu lewat listener
     * perubahan state player. Hasil akhirnya: **[Favorit][Sebelumnya]
     * [Putar/Jeda][Berikutnya][Mode]** (5 slot).
     *
     * Pada API < 33, media3 merender notifikasinya sendiri dan tombol standar
     * tak disisipkan otomatis, jadi tombol kustom putar/jeda tetap diperlukan.
     */
    fun buildNotificationButtons(context: Context): List<CommandButton> {
        val buttons = buildButtons(context)
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            buttons.filterNot {
                it.sessionCommand?.customAction == ACTION_TOGGLE_PLAY
            }
        } else {
            buttons
        }
    }
}

