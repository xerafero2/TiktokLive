package com.example.tiktok_interactive

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.tiktok/autoclick"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "performTap") {
                val action = call.argument<String>("action")
                val x = call.argument<Double>("x")?.toFloat() ?: 0f
                val y = call.argument<Double>("y")?.toFloat() ?: 0f
                
                AutoClickService.triggerAction(action, x, y)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}
