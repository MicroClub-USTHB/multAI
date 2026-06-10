package com.example.multai_mobile

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Prevent screenshots in recent apps (FLAG_SECURE)
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }
}
