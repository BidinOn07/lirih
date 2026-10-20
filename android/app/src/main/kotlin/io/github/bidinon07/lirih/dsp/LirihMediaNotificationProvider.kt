package io.github.bidinon07.lirih.dsp

import android.content.Context
import androidx.media3.common.Player
import androidx.media3.session.CommandButton
import androidx.media3.session.DefaultMediaNotificationProvider
import androidx.media3.session.MediaSession
import com.google.common.collect.ImmutableList
import io.github.bidinon07.lirih.R

/**
 * Penyedia notifikasi media dengan **baris tombol kustom** (task 3.5).
 *
 * `DefaultMediaNotificationProvider` membangun baris tombolnya sendiri:
 * ia **selalu menyisipkan tombol standar** (seek-previous, play/pause,
 * seek-next) di depan custom layout yang kita daftarkan. Karena itu urutan
 * tombol notifikasi sebelumnya tampil **teracak** dan ukurannya tak
 * seragam — tombol standar dibuat via `createMediaAction`, sedangkan tombol
 * kustom via `createCustomActionFromCustomCommandButton`.
 *
 * Provider ini hanya meng-override [getMediaButtons] untuk mengembalikan
 * **hanya** [NotificationActions.buildNotificationButtons] dalam urutan
 * tetap: favorit, acak, sebelumnya, berikutnya, ulang (di Android 13+ slot
 * tengah diisi tombol Putar/Jeda standar dari PlaybackState). `super` TIDAK
 * dipanggil agar tombol standar media3 tidak disisipkan.
 *
 * @param context context aplikasi.
 * @param notificationIdProvider pemberi ID notifikasi konstan (SAM) agar
 *     notifikasi selalu menimpa yang lama.
 * @param channelId channel notifikasi pemutar.
 * @param channelNameResId resource ID nama channel (untuk API 26+).
 */
class LirihMediaNotificationProvider(
    context: Context,
    notificationIdProvider: NotificationIdProvider,
    channelId: String,
    channelNameResId: Int,
) : DefaultMediaNotificationProvider(
    context,
    notificationIdProvider,
    channelId,
    channelNameResId,
) {

    // Field `context` di superclass bersifat private — simpan salinan kita
    // sendiri untuk membangun ikon tombol (resolve R.drawable.*).
    private val appContext: Context = context.applicationContext

    override fun getMediaButtons(
        session: MediaSession,
        playerCommands: Player.Commands,
        customLayout: ImmutableList<CommandButton>,
        requestCompactView: Boolean,
    ): ImmutableList<CommandButton> {
        // Jangan panggil super — ia menyisipkan tombol standar media3
        // (prev/play/next) di depan, yang mengacak urutan & merusak
        // keseragaman ukuran. Kembalikan hanya tombol kustom kita; di
        // Android 13+ tombol putar/jeda kustom sudah dibuang oleh
        // [NotificationActions.buildNotificationButtons] karena slot tengah
        // diisi tombol standar dari PlaybackState.
        val buttons = NotificationActions.buildNotificationButtons(appContext)
        return ImmutableList.copyOf(buttons)
    }

    companion object {
        /**
         * Membuat instance dengan ID notifikasi konstan [notificationId] —
         * agar notifikasi baru selalu menimpa yang lama (bila ID berubah
         * per session, notifikasi ganda bisa muncul).
         */
        fun create(context: Context, notificationId: Int, channelId: String):
            LirihMediaNotificationProvider {
            return LirihMediaNotificationProvider(
                context,
                NotificationIdProvider { notificationId },
                channelId,
                R.string.lirih_playback_channel_name,
            )
        }
    }
}
