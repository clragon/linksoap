package net.clynamic.linksoap

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Cache the engine so ShareActivity can use it
        FlutterEngineCache.getInstance().put("main", flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "net.clynamic.linksoap/share")
            .setMethodCallHandler { call, result ->
                if (call.method == "registerCallbackHandle") {
                    val handle = call.arguments as? Long
                    if (handle != null) {
                        getSharedPreferences("linksoap_prefs", Context.MODE_PRIVATE)
                            .edit()
                            .putLong("share_callback_handle", handle)
                            .apply()
                        result.success(null)
                    } else {
                        result.error("INVALID_ARG", "Handle must be Long", null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
