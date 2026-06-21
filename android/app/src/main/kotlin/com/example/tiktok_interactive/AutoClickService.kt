package com.example.tiktok_interactive

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.content.Context
import android.graphics.Color
import android.graphics.Path
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.view.accessibility.AccessibilityEvent
import android.widget.TextView

class AutoClickService : AccessibilityService() {

    private var windowManager: WindowManager? = null
    private val pointerViews = mutableListOf<View>()

    companion object {
        var instance: AutoClickService? = null

        fun triggerAction(action: String?) {
            val prefs = instance?.getSharedPreferences("TouchPrefs", Context.MODE_PRIVATE) ?: return
            
            when (action) {
                "recall_3x" -> instance?.executeTripleTap(prefs.getFloat("recall_x", 300f), prefs.getFloat("recall_y", 300f))
                "skill_1" -> instance?.performSingleTap(prefs.getFloat("skill1_x", 300f), prefs.getFloat("skill1_y", 500f))
                "ultimate" -> instance?.performSingleTap(prefs.getFloat("ulti_x", 300f), prefs.getFloat("ulti_y", 700f))
                "show_overlay" -> instance?.showOverlay()
                "hide_overlay" -> instance?.hideOverlay()
            }
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
    }

    private fun showOverlay() {
        if (pointerViews.isNotEmpty()) return

        addDraggablePointer("RCL", "recall_x", "recall_y")
        addDraggablePointer("SK1", "skill1_x", "skill1_y")
        addDraggablePointer("ULT", "ulti_x", "ulti_y")
    }

    private fun hideOverlay() {
        pointerViews.forEach { windowManager?.removeView(it) }
        pointerViews.clear()
    }

    private fun addDraggablePointer(label: String, prefX: String, prefY: String) {
        val prefs = getSharedPreferences("TouchPrefs", Context.MODE_PRIVATE)
        val layoutParams = WindowManager.LayoutParams(
            120, 120,
            WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = prefs.getFloat(prefX, 300f).toInt()
            y = prefs.getFloat(prefY, 300f).toInt()
        }

        val button = TextView(this).apply {
            text = label
            setTextColor(Color.parseColor("#000000"))
            gravity = Gravity.CENTER
            textSize = 12f
            
            val shape = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.parseColor("#DEFF9A"))
                setStroke(4, Color.parseColor("#0F172A"))
            }
            background = shape
        }

        var initialX = 0
        var initialY = 0
        var initialTouchX = 0f
        var initialTouchY = 0f

        button.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = layoutParams.x
                    initialY = layoutParams.y
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    layoutParams.x = initialX + (event.rawX - initialTouchX).toInt()
                    layoutParams.y = initialY + (event.rawY - initialTouchY).toInt()
                    windowManager?.updateViewLayout(button, layoutParams)
                    true
                }
                MotionEvent.ACTION_UP -> {
                    // Menyimpan posisi secara instan ke memori lokal
                    prefs.edit()
                         .putFloat(prefX, layoutParams.x.toFloat() + 60f) 
                         .putFloat(prefY, layoutParams.y.toFloat() + 60f)
                         .apply()
                    true
                }
                else -> false
            }
        }

        windowManager?.addView(button, layoutParams)
        pointerViews.add(button)
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
        hideOverlay()
        instance = null
        return super.onUnbind(intent)
    }
}
