package io.github.bidinon07.lirih

import android.content.Intent
import io.github.bidinon07.lirih.dsp.DspPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    private var dspPlugin: DspPlugin? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // PoC task 0.6/0.8 — MethodChannel DSP pitch shift.
        dspPlugin = DspPlugin(this).also { it.attach(flutterEngine.dartExecutor) }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        // Teruskan hasil pemilihan berkas audio ke DspPlugin.
        dspPlugin?.onActivityResult(requestCode, resultCode, data)
    }

    override fun onDestroy() {
        dspPlugin?.detach()
        dspPlugin = null
        super.onDestroy()
    }
}
