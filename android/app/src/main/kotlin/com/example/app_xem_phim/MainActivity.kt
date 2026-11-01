package com.example.app_xem_phim

import android.app.PictureInPictureParams
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Rational
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.app_xem_phim/pip"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "enterPip") {
                triggerPip()
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        triggerPip()
    }

    private fun triggerPip() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Tăng độ trễ lên 300ms để JavaScript cô lập video hoàn tất trước khi Android chụp ảnh PiP
            Handler(Looper.getMainLooper()).postDelayed({
                val aspectRatio = Rational(16, 9)
                val params = PictureInPictureParams.Builder()
                    .setAspectRatio(aspectRatio)
                    .build()
                enterPictureInPictureMode(params)
            }, 300)
        }
    }
}