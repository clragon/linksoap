package net.clynamic.linksoap

import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

object SharePlugin {
    fun register(flutterEngine: FlutterEngine, context: Context, initialIntent: Intent?) {
        FlutterEngineCache.getInstance().put(ShareConstants.ENGINE_ID, flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ShareConstants.CHANNEL_NAME)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    ShareConstants.METHOD_REGISTER_HANDLE -> {
                        val handle = call.arguments as? Long ?: run {
                            result.error("INVALID_ARG", "Handle must be Long", null)
                            return@setMethodCallHandler
                        }
                        context.getSharedPreferences(ShareConstants.PREFS_NAME, Context.MODE_PRIVATE)
                            .edit()
                            .putLong(ShareConstants.CALLBACK_HANDLE_KEY, handle)
                            .apply()
                        result.success(null)
                    }
                    ShareConstants.METHOD_IS_SETUP_BOOT -> {
                        val isSetupBoot = initialIntent?.getBooleanExtra(ShareConstants.EXTRA_SETUP_BOOT, false) ?: false
                        result.success(isSetupBoot)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
