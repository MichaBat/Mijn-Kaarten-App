package com.batelaan.bonidus_apidus

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val exitChannel = "com.batelaan.bonidus_apidus/exit"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, exitChannel)
            .setMethodCallHandler { call, result ->
                if (call.method == "finishAndRemoveTask") {
                    finishAndRemoveTask()
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }
}
