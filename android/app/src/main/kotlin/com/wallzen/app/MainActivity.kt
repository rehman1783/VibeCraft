package com.wallzen.app

import android.app.WallpaperManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.wall_zen/wallpaper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setWallpaper") {
                val filePath = call.argument<String>("filePath")
                val location = call.argument<Int>("target") ?: call.argument<Int>("location") ?: 1

                if (filePath.isNullOrEmpty()) {
                    result.error("INVALID_PATH", "File path cannot be null or empty", null)
                    return@setMethodCallHandler
                }

                val file = File(filePath)
                if (!file.exists()) {
                    result.error("FILE_NOT_FOUND", "Wallpaper file does not exist at $filePath", null)
                    return@setMethodCallHandler
                }

                // Run native bitmap decoding and setting on Dispatchers.IO background thread
                CoroutineScope(Dispatchers.IO).launch {
                    try {
                        // 1. Get display metrics to target exact screen resolution
                        val displayMetrics = resources.displayMetrics
                        val reqWidth = displayMetrics.widthPixels
                        val reqHeight = displayMetrics.heightPixels

                        // 2. First pass: Decode bounds only to calculate sample size
                        val options = BitmapFactory.Options().apply {
                            inJustDecodeBounds = true
                        }
                        BitmapFactory.decodeFile(file.absolutePath, options)

                        // 3. Calculate optimal sample size & downsample bitmap
                        options.inSampleSize = calculateInSampleSize(options, reqWidth, reqHeight)
                        options.inJustDecodeBounds = false
                        options.inPreferredConfig = Bitmap.Config.RGB_565

                        val bitmap = BitmapFactory.decodeFile(file.absolutePath, options)
                        if (bitmap == null) {
                            withContext(Dispatchers.Main) {
                                result.error("DECODE_FAILED", "Failed to decode image file into Bitmap", null)
                            }
                            return@launch
                        }

                        val wallpaperManager = WallpaperManager.getInstance(applicationContext)

                        when (location) {
                            1 -> { // Home Screen Only
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                    wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_SYSTEM)
                                } else {
                                    wallpaperManager.setBitmap(bitmap)
                                }
                            }
                            2 -> { // Lock Screen Only
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                    wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_LOCK)
                                } else {
                                    wallpaperManager.setBitmap(bitmap)
                                }
                            }
                            3 -> { // Both Screens
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                    wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_SYSTEM or WallpaperManager.FLAG_LOCK)
                                } else {
                                    wallpaperManager.setBitmap(bitmap)
                                }
                            }
                            else -> {
                                wallpaperManager.setBitmap(bitmap)
                            }
                        }

                        // Free native bitmap memory immediately after applying
                        bitmap.recycle()

                        withContext(Dispatchers.Main) {
                            result.success(true)
                        }
                    } catch (e: Exception) {
                        withContext(Dispatchers.Main) {
                            result.error("SET_WALLPAPER_FAILED", e.localizedMessage, e.stackTraceToString())
                        }
                    }
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun calculateInSampleSize(options: BitmapFactory.Options, reqWidth: Int, reqHeight: Int): Int {
        val (height: Int, width: Int) = options.outHeight to options.outWidth
        var inSampleSize = 1

        if (height > reqHeight || width > reqWidth) {
            val halfHeight: Int = height / 2
            val halfWidth: Int = width / 2

            while (halfHeight / inSampleSize >= reqHeight && halfWidth / inSampleSize >= reqWidth) {
                inSampleSize *= 2
            }
        }
        return inSampleSize
    }
}

