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

/// Nama MethodChannel DSP — TERKUNCI task 0N.4.
const val DSP_CHANNEL = "io.github.bidinon07.lirih/dsp"

private const val TAG = "LirihDsp"

/// Request code pemilihan berkas (di luar rentang yang dipakai engine).
private const val RC_PICK_AUDIO = 42420

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
                    player.playFile(call.argument<String>("path")!!)
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
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            result.error("DSP_ERROR", e.message, null)
        }
    }

    private fun toLong(value: Number?): Long = value?.toLong() ?: 0L

    private fun toFraction(value: Number?): Float = value?.toFloat() ?: 1.0f
}
