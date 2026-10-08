package io.github.bidinon07.lirih.dsp

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/// Nama MethodChannel DSP — TERKUNCI task 0N.4.
const val DSP_CHANNEL = "io.github.bidinon07.lirih/dsp"

/**
 * Jembatan MethodChannel `io.github.bidinon07.lirih/dsp` — PoC task **0.8**.
 *
 * Menerjemahkan panggilan Dart menjadi operasi [LirihDspPlayer] dan
 * meneruskan event player kembali ke Dart. Berjalan di main thread
 * (thread application ExoPlayer) sehingga tidak butuh pengelolaan thread
 * tambahan.
 */
class DspPlugin(private val context: Context) : MethodChannel.MethodCallHandler {

    private val player = LirihDspPlayer(context)
    private var channel: MethodChannel? = null

    /** Mendaftarkan channel pada [messenger] dan mulai mendengar event. */
    fun attach(messenger: BinaryMessenger) {
        val ch = MethodChannel(messenger, DSP_CHANNEL)
        ch.setMethodCallHandler(this)
        channel = ch
        player.onEvent = { event, data ->
            ch.invokeMethod("onEvent", mapOf("event" to event, "data" to data))
        }
    }

    /** Melepas channel dan melepaskan sumber daya player. */
    fun detach() {
        player.onEvent = null
        channel?.setMethodCallHandler(null)
        channel = null
        player.release()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "play" -> {
                    player.playFile(call.argument<String>("path")!!)
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
