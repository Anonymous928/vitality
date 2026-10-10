package com.afterglowjournal.afterglow

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity is required by local_auth (BiometricPrompt).
class MainActivity : FlutterFragmentActivity() {

    private var channel: MethodChannel? = null

    // "Save to…" via the Storage Access Framework: the user picks the
    // location, so no storage permission is needed.
    private var pendingSave: Pair<ByteArray, MethodChannel.Result>? = null
    private lateinit var savePdf: ActivityResultLauncher<String>
    private lateinit var saveJson: ActivityResultLauncher<String>

    // Set when launched from the home-screen widget's "Log event" button.
    private var launchAction: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        // Secure by default from the very first frame; Dart may turn it off
        // once settings are loaded (user toggle "Hide in recent apps").
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        super.onCreate(savedInstanceState)
        savePdf = registerForActivityResult(
            ActivityResultContracts.CreateDocument("application/pdf"), ::onSaveTarget)
        saveJson = registerForActivityResult(
            ActivityResultContracts.CreateDocument("application/json"), ::onSaveTarget)
        launchAction = actionOf(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        actionOf(intent)?.let { channel?.invokeMethod("launchAction", it) }
    }

    private fun actionOf(intent: Intent?): String? =
        intent?.data?.takeIf { it.scheme == "afterglow" }?.host

    private fun onSaveTarget(uri: Uri?) {
        val (bytes, result) = pendingSave ?: return
        pendingSave = null
        if (uri == null) {
            result.success(false)
            return
        }
        try {
            contentResolver.openOutputStream(uri)!!.use { it.write(bytes) }
            result.success(true)
        } catch (e: Exception) {
            result.error("save_failed", e.message, null)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val ch = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "afterglow/window")
        channel = ch
        ch.setMethodCallHandler { call, result ->
            when (call.method) {
                "setSecure" -> {
                    if (call.arguments as Boolean) {
                        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    } else {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    }
                    result.success(null)
                }
                // Material You wallpaper accent (Android 12+), or null.
                "accentColor" -> result.success(
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        getColor(android.R.color.system_accent1_500)
                    } else {
                        null
                    }
                )
                "saveDocument" -> {
                    val name = call.argument<String>("name")!!
                    val mime = call.argument<String>("mime")!!
                    pendingSave?.second?.success(false)
                    pendingSave = call.argument<ByteArray>("bytes")!! to result
                    if (mime == "application/pdf") savePdf.launch(name) else saveJson.launch(name)
                }
                "updateWidget" -> {
                    LogWidgetProvider.save(
                        this,
                        episodeStart = call.argument<Number>("episodeStart")?.toLong() ?: -1L,
                        expectedDays = call.argument<Int>("expectedDays") ?: 0,
                        hideStatus = call.argument<Boolean>("hideStatus") ?: false,
                    )
                    result.success(null)
                }
                "takeLaunchAction" -> {
                    result.success(launchAction)
                    launchAction = null
                }
                else -> result.notImplemented()
            }
        }
    }
}
