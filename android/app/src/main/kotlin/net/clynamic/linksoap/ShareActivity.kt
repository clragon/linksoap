package net.clynamic.linksoap

import android.app.Activity
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.widget.Toast
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.FlutterCallbackInformation

class ShareActivity : Activity() {
    companion object {
        private var backgroundEngine: FlutterEngine? = null
    }
    
    private var timeoutHandler: Handler? = null
    private var isFinishing = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Make the window completely invisible
        window.setBackgroundDrawableResource(android.R.color.transparent)
        
        startTimeout()
        handleIntent(intent)
    }
    
    override fun onDestroy() {
        super.onDestroy()
        cancelTimeout()
    }
    
    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }
    
    private fun handleIntent(intent: Intent?) {
        if (isFinishing) {
            Log.w("ShareActivity", "Already finishing, ignoring intent")
            return
        }
        
        if (intent?.action == Intent.ACTION_SEND && intent.type == "text/plain") {
            val sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)

            if (sharedText != null) {
                processShare(sharedText)
            } else {
                Log.w("ShareActivity", "No shared text found")
                finishSafely()
            }
        } else {
            Log.w("ShareActivity", "Invalid intent action or type")
            finishSafely()
        }
    }
    
    private fun startTimeout() {
        timeoutHandler = Handler(Looper.getMainLooper()).apply {
            postDelayed({
                Log.e("ShareActivity", "Processing timed out")
                Toast.makeText(this@ShareActivity, "Link processing timed out", Toast.LENGTH_SHORT).show()
                finishSafely()
            }, ShareConstants.TIMEOUT_MS)
        }
    }
    
    private fun cancelTimeout() {
        timeoutHandler?.removeCallbacksAndMessages(null)
        timeoutHandler = null
    }
    
    private fun finishSafely() {
        if (!isFinishing) {
            isFinishing = true
            cancelTimeout()
            finish()
        }
    }

    private fun processShare(sharedText: String) {
        val engine = FlutterEngineCache.getInstance().get(ShareConstants.ENGINE_ID)
        if (engine != null) {
            invokeMethod(engine, sharedText)
        } else {
            startBackgroundEngine(sharedText)
        }
    }
    
    private fun invokeMethod(engine: FlutterEngine, text: String) {
        MethodChannel(engine.dartExecutor.binaryMessenger, ShareConstants.CHANNEL_NAME)
            .invokeMethod(ShareConstants.METHOD_PROCESS_TEXT, text, createResultHandler())
    }
    
    private fun createResultHandler() = object : MethodChannel.Result {
        override fun success(result: Any?) {
            (result as? String)?.let { setClipboard(it) }
            finishSafely()
        }
        
        override fun error(code: String, message: String?, details: Any?) {
            Log.e("ShareActivity", "Failed: $code - $message")
            Toast.makeText(this@ShareActivity, "Failed to process link", Toast.LENGTH_SHORT).show()
            finishSafely()
        }
        
        override fun notImplemented() {
            Log.e("ShareActivity", "Not implemented")
            finishSafely()
        }
    }
    
    private fun setClipboard(text: String) {
        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = ClipData.newPlainText("Cleaned link", text)
        clipboard.setPrimaryClip(clip)
    }

    private fun startBackgroundEngine(text: String) {
        backgroundEngine?.let {
            invokeMethod(it, text)
            return
        }
        
        val handle = getSharedPreferences(ShareConstants.PREFS_NAME, Context.MODE_PRIVATE)
            .getLong(ShareConstants.CALLBACK_HANDLE_KEY, 0)
        
        if (handle == 0L) {
            launchMainActivity(text)
            return
        }
        
        val loader = FlutterInjector.instance().flutterLoader()
        if (!loader.initialized()) {
            loader.startInitialization(applicationContext)
        }
        
        Handler(Looper.getMainLooper()).post {
            loader.ensureInitializationComplete(applicationContext, null)
            
            val callbackInfo = FlutterCallbackInformation.lookupCallbackInformation(handle) ?: run {
                Log.e("ShareActivity", "Failed to lookup callback")
                Toast.makeText(this, "Failed to initialize", Toast.LENGTH_SHORT).show()
                finishSafely()
                return@post
            }
            
            backgroundEngine = FlutterEngine(applicationContext).apply {
                dartExecutor.executeDartCallback(
                    DartExecutor.DartCallback(
                        applicationContext.assets,
                        loader.findAppBundlePath(),
                        callbackInfo
                    )
                )
            }
            
            Handler(Looper.getMainLooper()).postDelayed({
                backgroundEngine?.let { invokeMethod(it, text) }
            }, ShareConstants.INIT_DELAY_MS)
        }
    }
    
    private fun launchMainActivity(text: String) {
        Log.w("ShareActivity", "No callback handle found. Launching main app.")
        
        startActivity(Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra(ShareConstants.EXTRA_SETUP_BOOT, true)
        })
        
        // Wait for MainActivity to cache the engine, then use it
        Handler(Looper.getMainLooper()).postDelayed({
            val engine = FlutterEngineCache.getInstance().get(ShareConstants.ENGINE_ID)
            if (engine != null) {
                invokeMethod(engine, text)
            } else {
                Log.e("ShareActivity", "Engine still not available after launching MainActivity")
                finishSafely()
            }
        }, 2000) // Wait 2 seconds for MainActivity to start
    }

}
