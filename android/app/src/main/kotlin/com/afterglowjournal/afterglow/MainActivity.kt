package com.afterglowjournal.afterglow

import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity is required by local_auth (BiometricPrompt).
class MainActivity : FlutterFragmentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        // Secure by default from the very first frame; Dart may turn it off
        // once settings are loaded (user toggle "Hide in recent apps").
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "afterglow/window")
            .setMethodCallHandler { call, result ->
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
                    else -> result.notImplemented()
                }
            }
    }
}
