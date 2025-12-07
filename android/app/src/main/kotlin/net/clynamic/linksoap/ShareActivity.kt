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
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.FlutterCallbackInformation

class ShareActivity : Activity() {
    companion object {
        private var backgroundEngine: FlutterEngine? = null
        private const val TIMEOUT_MS = 10000L // 10 second timeout
    }
    
    private var timeoutHandler: Handler? = null
    private var timeoutRunnable: Runnable? = null
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
        timeoutHandler = Handler(Looper.getMainLooper())
        timeoutRunnable = Runnable {
            Log.e("ShareActivity", "Processing timed out after ${TIMEOUT_MS}ms")
            Toast.makeText(this, "Link processing timed out", Toast.LENGTH_SHORT).show()
            finishSafely()
        }
        timeoutHandler?.postDelayed(timeoutRunnable!!, TIMEOUT_MS)
    }
    
    private fun cancelTimeout() {
        timeoutRunnable?.let { timeoutHandler?.removeCallbacks(it) }
        timeoutHandler = null
        timeoutRunnable = null
    }
    
    private fun finishSafely() {
        if (!isFinishing) {
            isFinishing = true
            cancelTimeout()
            finish()
        }
    }

    private fun processShare(sharedText: String) {
        val flutterEngine = FlutterEngineCache.getInstance().get("main")

        if (flutterEngine != null) {
            // App is running, use existing engine
            val channel = MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                "net.clynamic.linksoap/share"
            )
            channel.invokeMethod("processSharedText", sharedText, object : MethodChannel.Result {
                override fun success(result: Any?) {
                    val cleanedText = result as? String
                    if (cleanedText != null) {
                        setClipboard(cleanedText)
                    }
                    finishSafely()
                }
                
                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                    Log.e("ShareActivity", "Share processing failed: $errorCode - $errorMessage")
                    Toast.makeText(this@ShareActivity, "Failed to process link", Toast.LENGTH_SHORT).show()
                    finishSafely()
                }
                
                override fun notImplemented() {
                    Log.e("ShareActivity", "Share processing not implemented")
                    finishSafely()
                }
            })
        } else {
            // App is not running - create background engine
            startBackgroundEngine(sharedText)
        }
    }
    
    private fun setClipboard(text: String) {
        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = ClipData.newPlainText("Cleaned link", text)
        clipboard.setPrimaryClip(clip)
    }

    private fun startBackgroundEngine(sharedText: String) {
        if (backgroundEngine == null) {
            val callbackHandle = applicationContext.getSharedPreferences("linksoap_prefs", android.content.Context.MODE_PRIVATE)
                .getLong("share_callback_handle", 0)
            
            if (callbackHandle == 0L) {
                Log.w("ShareActivity", "No callback handle found. Launching main app to register it.")
                Toast.makeText(this, "Opening LinkSoap to set up share functionality...", Toast.LENGTH_LONG).show()
                
                // Launch MainActivity to register the callback handle
                val mainIntent = Intent(this, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    putExtra("shared_text", sharedText)
                }
                startActivity(mainIntent)
                finishSafely()
                return
            }
            
            val flutterLoader = FlutterInjector.instance().flutterLoader()
            
            if (!flutterLoader.initialized()) {
                flutterLoader.startInitialization(applicationContext)
            }
            
            Handler(Looper.getMainLooper()).post {
                flutterLoader.ensureInitializationComplete(applicationContext, null)
                
                val callbackInfo = FlutterCallbackInformation.lookupCallbackInformation(callbackHandle)
                
                if (callbackInfo == null) {
                    Log.e("ShareActivity", "Failed to lookup callback info for handle $callbackHandle")
                    Toast.makeText(this@ShareActivity, "Failed to initialize link processing", Toast.LENGTH_SHORT).show()
                    finishSafely()
                    return@post
                }
                
                backgroundEngine = FlutterEngine(applicationContext)
                
                val dartCallback = DartExecutor.DartCallback(
                    applicationContext.assets,
                    flutterLoader.findAppBundlePath(),
                    callbackInfo
                )
                
                backgroundEngine!!.dartExecutor.executeDartCallback(dartCallback)
                
                // Wait for initialization, then invoke method
                Handler(Looper.getMainLooper()).postDelayed({
                    invokeMethodOnBackgroundEngine(sharedText)
                }, 500)
            }
        } else {
            // Reuse existing background engine
            invokeMethodOnBackgroundEngine(sharedText)
        }
    }
    
    private fun invokeMethodOnBackgroundEngine(sharedText: String) {
        if (backgroundEngine == null) {
            Log.e("ShareActivity", "Background engine is null")
            finishSafely()
            return
        }
        
        try {
            val channel = MethodChannel(
                backgroundEngine!!.dartExecutor.binaryMessenger,
                "net.clynamic.linksoap/share"
            )
            channel.invokeMethod("processSharedText", sharedText, object : MethodChannel.Result {
                override fun success(result: Any?) {
                    val cleanedText = result as? String
                    if (cleanedText != null) {
                        setClipboard(cleanedText)
                    }
                    finishSafely()
                }
                
                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                    Log.e("ShareActivity", "Share processing failed: $errorCode - $errorMessage")
                    Toast.makeText(this@ShareActivity, "Failed to process link", Toast.LENGTH_SHORT).show()
                    finishSafely()
                }
                
                override fun notImplemented() {
                    Log.e("ShareActivity", "Share processing not implemented")
                    finishSafely()
                }
            })
        } catch (e: Exception) {
            Log.e("ShareActivity", "Exception invoking method: ${e.message}", e)
            Toast.makeText(this, "Error processing link", Toast.LENGTH_SHORT).show()
            finishSafely()
        }
    }
}
