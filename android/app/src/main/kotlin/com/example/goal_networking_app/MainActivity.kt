package com.example.goal_networking_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.app.WallpaperManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.util.DisplayMetrics
import java.net.URL
import kotlin.concurrent.thread
import java.io.IOException
import android.os.Build

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.waytree.app/wallpaper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setWallpaper") {
                val url = call.argument<String>("url")
                val networkName = call.argument<String>("networkName")
                val codeId = call.argument<String>("codeId")
                
                if (url != null && networkName != null && codeId != null) {
                    setWallpaper(url, networkName, codeId, result)
                } else {
                    result.error("INVALID_ARGUMENT", "URL, network name, and code ID are required", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun setWallpaper(url: String, networkName: String, codeId: String, result: MethodChannel.Result) {
        thread {
            try {
                // Get screen dimensions
                val displayMetrics = DisplayMetrics()
                windowManager.defaultDisplay.getRealMetrics(displayMetrics)
                val screenWidth = displayMetrics.widthPixels
                val screenHeight = displayMetrics.heightPixels
                
                // Convert 1 inch to pixels for bottom margin
                val dpi = displayMetrics.densityDpi
                val oneInchPx = (dpi / 160f) * 160 // 1 inch in pixels
                
                // Calculate QR code size (reasonable size for visibility)
                val qrSize = (screenWidth * 0.6).toInt() // 60% of screen width
                
                // Create background bitmap with light beige color (matching image)
                val wallpaperBitmap = Bitmap.createBitmap(screenWidth, screenHeight, Bitmap.Config.ARGB_8888)
                val canvas = Canvas(wallpaperBitmap)
                
                // Fill with light beige background color
                canvas.drawColor(Color.parseColor("#F5F1E8"))
                
                // Download and decode QR code
                val inputStream = URL(url).openStream()
                val qrBitmap = BitmapFactory.decodeStream(inputStream)
                val scaledQrBitmap = Bitmap.createScaledBitmap(qrBitmap, qrSize, qrSize, true)
                
                // Center QR code horizontally and vertically on screen
                val qrLeft = (screenWidth - qrSize) / 2
                val qrTop = (screenHeight - qrSize) / 2
                
                // Draw QR code on canvas
                canvas.drawBitmap(scaledQrBitmap, qrLeft.toFloat(), qrTop.toFloat(), null)
                
                // Text paint for labels
                val textPaint = Paint().apply {
                    color = Color.parseColor("#2C2C2C")
                    textAlign = Paint.Align.CENTER
                    isAntiAlias = true
                }
                
                // Draw network name above QR code
                textPaint.textSize = 56f
                textPaint.typeface = android.graphics.Typeface.create(android.graphics.Typeface.DEFAULT, android.graphics.Typeface.BOLD)
                val nameY = qrTop - 60f
                canvas.drawText(networkName, (screenWidth / 2).toFloat(), nameY, textPaint)
                
                // Draw code ID below QR code
                textPaint.textSize = 44f
                textPaint.typeface = android.graphics.Typeface.create(android.graphics.Typeface.DEFAULT, android.graphics.Typeface.NORMAL)
                textPaint.color = Color.parseColor("#6B6B6B")
                val codeIdY = qrTop + qrSize + 80f
                canvas.drawText("Code: $codeId", (screenWidth / 2).toFloat(), codeIdY, textPaint)
                
                // Draw "1 in" text below code ID
                textPaint.textSize = 36f
                val textY = codeIdY + 60f
                canvas.drawText("1 in", (screenWidth / 2).toFloat(), textY, textPaint)
                
                // Set as wallpaper
                val wallpaperManager = WallpaperManager.getInstance(context)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    wallpaperManager.setBitmap(wallpaperBitmap, null, false, WallpaperManager.FLAG_LOCK)
                } else {
                    wallpaperManager.setBitmap(wallpaperBitmap)
                }
                
                // Clean up
                scaledQrBitmap.recycle()
                qrBitmap.recycle()
                
                runOnUiThread {
                    result.success(true)
                }
            } catch (e: IOException) {
                e.printStackTrace()
                runOnUiThread {
                    result.error("IO_ERROR", "Failed to load image or set wallpaper", e.localizedMessage)
                }
            } catch (e: Exception) {
                e.printStackTrace()
                runOnUiThread {
                    result.error("ERROR", "An unexpected error occurred", e.localizedMessage)
                }
            }
        }
    }
}
