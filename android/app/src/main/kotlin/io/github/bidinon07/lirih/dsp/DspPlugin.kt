package io.github.bidinon07.lirih.dsp

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import kotlin.math.min

/// Nama MethodChannel DSP — TERKUNCI task 0N.4.
const val DSP_CHANNEL = "io.github.bidinon07.lirih/dsp"

private const val TAG = "LirihDsp"

/// Request code pemilihan berkas (di luar rentang yang dipakai engine).
private const val RC_PICK_AUDIO = 42420

/// Batas atas tag ID3 yang dibaca ke memori (frame USLT biasanya di awal;
/// frame APIC/cover bisa besar sehingga 2 MB cukup aman).
private const val MAX_TAG_BYTES = 2 * 1024 * 1024

/**
 * Jembatan MethodChannel `io.github.bidinon07.lirih/dsp` — PoC task **0.8**.
 *
 * Menerjemahkan panggilan Dart menjadi operasi [LirihDspPlayer] dan
 * meneruskan event player kembali ke Dart. Berjalan di main thread
 * (thread application ExoPlayer) sehingga tidak butuh pengelolaan thread
 * tambahan.
 *
 * [pickFile] membuka pemilih berkas sistem (Storage Access Framework)
 * menghasilkan `content://` URI dengan akses baca sementara — **tanpa
 * permission** (tidak seperti pindai MediaStore di task 1.12). Hasilnya
 * diterima [onActivityResult] yang diteruskan dari `MainActivity`.
 */
class DspPlugin(
    private val activity: Activity,
) : MethodChannel.MethodCallHandler {

    private val player = LirihDspPlayer(activity as Context)
    private var channel: MethodChannel? = null

    /** Apakah foreground service pemutar sudah berjalan. */
    private var serviceRunning = false

    /** Mendaftarkan channel pada [messenger] dan mulai mendengar event. */
    fun attach(messenger: BinaryMessenger) {
        val ch = MethodChannel(messenger, DSP_CHANNEL)
        ch.setMethodCallHandler(this)
        channel = ch
        player.onEvent = { event, data ->
            ch.invokeMethod("onEvent", mapOf("event" to event, "data" to data))
        }
        // Player dipublikasikan agar LirihPlaybackService dapat membangun
        // MediaSession di sekitar instance yang sama (task 1.7).
        PlaybackHost.player = player
    }

    /** Melepas channel dan melepaskan sumber daya player. */
    fun detach() {
        stopPlaybackService()
        player.onEvent = null
        channel?.setMethodCallHandler(null)
        channel = null
        player.release()
        PlaybackHost.player = null
    }

    /** Memulai foreground service agar playback bertahan di background. */
    private fun startPlaybackService() {
        if (serviceRunning) return
        serviceRunning = true
        PlaybackHost.player = player
        val intent = Intent(activity, LirihPlaybackService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            activity.startForegroundService(intent)
        } else {
            activity.startService(intent)
        }
    }

    /** Menghentikan foreground service bila playback selesai sepenuhnya. */
    private fun stopPlaybackService() {
        if (!serviceRunning) return
        serviceRunning = false
        activity.stopService(Intent(activity, LirihPlaybackService::class.java))
    }

    /**
     * Hasil pemilihan berkas — wajib diteruskan dari
     * `MainActivity.onActivityResult`.
     *
     * @return `true` bila request ini ditangani (pemilihan berkas).
     */
    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != RC_PICK_AUDIO) return false
        val uri: Uri? = if (resultCode == Activity.RESULT_OK) data?.data else null
        if (uri != null) {
            Log.i(TAG, "Berkas dipilih: $uri")
            player.playFile(uri.toString())
            startPlaybackService()
            channel?.invokeMethod("onFilePicked", mapOf("uri" to uri.toString()))
        } else {
            channel?.invokeMethod("onFilePicked", mapOf("uri" to null))
        }
        return true
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "play" -> {
                    player.playFile(
                        call.argument<String>("path")!!,
                        title = call.argument("title"),
                        artist = call.argument("artist"),
                        artUri = call.argument("artUri"),
                    )
                    startPlaybackService()
                    result.success(null)
                }
                "pickFile" -> {
                    val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                        addCategory(Intent.CATEGORY_OPENABLE)
                        type = "audio/*"
                    }
                    activity.startActivityForResult(intent, RC_PICK_AUDIO)
                    result.success(null)
                }
                "pause" -> {
                    player.pause()
                    result.success(null)
                }
                "resume" -> {
                    player.resume()
                    result.success(null)
                }
                "stop" -> {
                    player.stop()
                    stopPlaybackService()
                    result.success(null)
                }
                "seek" -> {
                    player.seek(toLong(call.argument<Number>("positionMs")))
                    result.success(null)
                }
                "setPitch" -> {
                    player.setPitch(toFraction(call.argument<Number>("ratio")))
                    result.success(null)
                }
                "setTempo" -> {
                    player.setTempo(toFraction(call.argument<Number>("ratio")))
                    result.success(null)
                }
                "getPitch" -> result.success(player.getPitch())
                "getPosition" -> result.success(player.getPosition())
                "getDuration" -> result.success(player.getDuration())
                "getLyrics" -> {
                    // Baca lirik tertanam (tag USLT/ID3) — I/O, jadi di
                    // thread latar; hasilnya dikembalikan ke main thread
                    // (task 3.2).
                    val path = call.argument<String>("path")
                    if (path == null) {
                        result.success(null)
                        return
                    }
                    Thread {
                        val lyrics = readLyrics(path)
                        activity.runOnUiThread { result.success(lyrics) }
                    }.start()
                }
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            result.error("DSP_ERROR", e.message, null)
        }
    }

    private fun toLong(value: Number?): Long = value?.toLong() ?: 0L

    private fun toFraction(value: Number?): Float = value?.toFloat() ?: 1.0f

    /**
     * Membaca lirik tertanam dari berkas audio [path] (absolut atau
     * `content://` URI) dengan mem-parsing tag ID3v2 (frame `USLT`).
     *
     * Mengembalikan `null` bila tidak ada frame lirik atau terjadi
     * kegagalan — **best effort**, tidak boleh menghentikan playback.
     * `MediaMetadataRetriever` sengaja tidak dipakai: ia tidak mengekspos
     * kunci lirik (tidak ada `METADATA_KEY_LYRICS` di AOSP).
     */
    private fun readLyrics(path: String): String? {
        return try {
            val uri = if (path.startsWith("content:") || path.startsWith("file:")) {
                Uri.parse(path)
            } else {
                Uri.fromFile(File(path))
            }
            activity.contentResolver.openInputStream(uri)?.use { stream ->
                parseId3Lyrics(stream)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Gagal membaca lirik: $path", e)
            null
        }
    }

    private fun parseId3Lyrics(stream: java.io.InputStream): String? {
        val header = ByteArray(10)
        if (stream.read(header) != 10) return null
        val id3 = header[0] == 'I'.code.toByte() &&
            header[1] == 'D'.code.toByte() &&
            header[2] == '3'.code.toByte()
        if (!id3) return null

        val version = header[3].toInt() and 0xFF
        val tagSize = synchsafeToInt(header, 6)
        if (tagSize <= 0) return null

        val readSize = min(tagSize, MAX_TAG_BYTES)
        val data = ByteArray(readSize)
        var filled = 0
        while (filled < readSize) {
            val n = stream.read(data, filled, readSize - filled)
            if (n <= 0) break
            filled += n
        }

        var offset = 0
        while (offset + 10 <= filled) {
            // Frame ID diawali huruf besar; 0 = padding/akhir tag.
            if (data[offset] <= 0) break
            val frameId = String(data, offset, 4, Charsets.ISO_8859_1)
            val size = if (version >= 4) synchsafeToInt(data, offset + 4)
                       else beToInt(data, offset + 4)
            if (size <= 0 || offset + 10 + size > filled) break
            if (frameId == "USLT") {
                return parseUsltFrame(data, offset + 10, size)
            }
            offset += 10 + size
        }
        return null
    }

    /// Memecah frame `USLT`: encoding(1) + bahasa(3) + deskripsi +
    /// teks lirik.
    private fun parseUsltFrame(data: ByteArray, start: Int, size: Int): String? {
        if (size < 5) return null
        val encoding = data[start].toInt() and 0xFF
        val (charset, termLen) = when (encoding) {
            0 -> Charsets.ISO_8859_1 to 1
            1 -> Charsets.UTF_16 to 2
            2 -> Charsets.UTF_16BE to 2
            3 -> Charsets.UTF_8 to 1
            else -> Charsets.ISO_8859_1 to 1
        }

        // Lewati deskripsi (null-terminated) setelah byte bahasa.
        var i = start + 4
        while (i + termLen <= start + size) {
            val terminated = if (termLen == 1) {
                data[i] == 0.toByte()
            } else {
                data[i] == 0.toByte() && data[i + 1] == 0.toByte()
            }
            if (terminated) break
            i++
        }
        val textStart = i + termLen
        if (textStart >= start + size) return null

        val text = String(data, textStart, start + size - textStart, charset)
        return text.trim().takeIf { it.isNotEmpty() }
    }

    /// 4-byte big-endian ke int.
    private fun beToInt(data: ByteArray, offset: Int): Int =
        ((data[offset].toInt() and 0xFF) shl 24) or
            ((data[offset + 1].toInt() and 0xFF) shl 16) or
            ((data[offset + 2].toInt() and 0xFF) shl 8) or
            (data[offset + 3].toInt() and 0xFF)

    /// 4-byte synchsafe (bit tertinggi tiap byte = 0) ke int.
    private fun synchsafeToInt(data: ByteArray, offset: Int): Int =
        ((data[offset].toInt() and 0x7F) shl 21) or
            ((data[offset + 1].toInt() and 0x7F) shl 14) or
            ((data[offset + 2].toInt() and 0x7F) shl 7) or
            (data[offset + 3].toInt() and 0x7F)
}
