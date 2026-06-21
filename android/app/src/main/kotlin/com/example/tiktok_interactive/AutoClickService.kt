package com.example.tiktok_interactive

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.graphics.Path
import android.view.accessibility.AccessibilityEvent

class AutoClickService : AccessibilityService() {

    companion object {
        var instance: AutoClickService? = null

        fun triggerAction(action: String?, x: Float, y: Float) {
            if (instance == null) return

            if (action == "recall_3x") {
                instance?.executeTripleTap(x, y)
            } else {
                instance?.performSingleTap(x, y)
            }
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
    }

    private fun performSingleTap(x: Float, y: Float) {
        val path = Path().apply { moveTo(x, y) }
        val builder = GestureDescription.Builder()
        builder.addStroke(GestureDescription.StrokeDescription(path, 0, 40))
        dispatchGesture(builder.build(), null, null)
    }

    private fun executeTripleTap(x: Float, y: Float) {
        val path = Path().apply { moveTo(x, y) }
        val builder = GestureDescription.Builder()
        
        builder.addStroke(GestureDescription.StrokeDescription(path, 0, 40))
        builder.addStroke(GestureDescription.StrokeDescription(path, 50, 40))
        builder.addStroke(GestureDescription.StrokeDescription(path, 100, 40))
        
        dispatchGesture(builder.build(), null, null)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {}
    override fun onInterrupt() {}

    override fun onUnbind(intent: android.content.Intent?): Boolean {
        instance = null
        return super.onUnbind(intent)
    }
}
