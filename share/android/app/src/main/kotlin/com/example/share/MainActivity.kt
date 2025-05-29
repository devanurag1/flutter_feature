// File: android/app/src/main/kotlin/com/example/your_app/MainActivity.kt

package com.example.share

import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.share/share"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveImage" -> {
                    val imageBytes = call.argument<ByteArray>("imageBytes")
                    if (imageBytes != null) {
                        val imagePath = saveImageToCache(imageBytes)
                        result.success(imagePath)
                    } else {
                        result.error("INVALID_ARGUMENT", "Image bytes is null", null)
                    }
                }
                "shareImage" -> {
                    val imagePath = call.argument<String>("imagePath")
                    val text = call.argument<String>("text")
                    if (imagePath != null) {
                        shareImage(imagePath, text ?: "")
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Image path is null", null)
                    }
                }
                "shareToTwitter" -> {
                    val imagePath = call.argument<String>("imagePath")
                    val text = call.argument<String>("text")
                    if (imagePath != null) {
                        shareToTwitter(imagePath, text ?: "")
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Image path is null", null)
                    }
                }
                "shareToWhatsApp" -> {
                    val imagePath = call.argument<String>("imagePath")
                    val text = call.argument<String>("text")
                    if (imagePath != null) {
                        shareToWhatsApp(imagePath, text ?: "")
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Image path is null", null)
                    }
                }
                "shareText" -> {
                    val text = call.argument<String>("text")
                    if (text != null) {
                        shareText(text)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Text is null", null)
                    }
                }
                "shareTextToTwitter" -> {
                    val text = call.argument<String>("text")
                    if (text != null) {
                        shareTextToTwitter(text)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Text is null", null)
                    }
                }
                "shareTextToWhatsApp" -> {
                    val text = call.argument<String>("text")
                    if (text != null) {
                        shareTextToWhatsApp(text)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Text is null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun saveImageToCache(imageBytes: ByteArray): String {
        val cacheDir = applicationContext.cacheDir
        val imageFile = File(cacheDir, "share_image_${System.currentTimeMillis()}.png")
        imageFile.writeBytes(imageBytes)
        return imageFile.absolutePath
    }

    private fun shareImage(imagePath: String, text: String) {
        try {
            val imageFile = File(imagePath)
            val imageUri = FileProvider.getUriForFile(
                this,
                "${applicationContext.packageName}.fileprovider",
                imageFile
            )

            val shareIntent = Intent().apply {
                action = Intent.ACTION_SEND
                type = "image/*"
                putExtra(Intent.EXTRA_STREAM, imageUri)
                putExtra(Intent.EXTRA_TEXT, text)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }

            startActivity(Intent.createChooser(shareIntent, "Share Image"))
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun shareToTwitter(imagePath: String, text: String) {
        try {
            val imageFile = File(imagePath)
            val imageUri = FileProvider.getUriForFile(
                this,
                "${applicationContext.packageName}.fileprovider",
                imageFile
            )

            val twitterIntent = Intent().apply {
                action = Intent.ACTION_SEND
                type = "image/*"
                putExtra(Intent.EXTRA_STREAM, imageUri)
                putExtra(Intent.EXTRA_TEXT, text)
                setPackage("com.twitter.android")
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }

            try {
                startActivity(twitterIntent)
            } catch (e: Exception) {
                // Twitter app not installed, use web intent
                val webIntent = Intent(Intent.ACTION_VIEW, Uri.parse("https://twitter.com/intent/tweet?text=${Uri.encode(text)}"))
                startActivity(webIntent)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun shareToWhatsApp(imagePath: String, text: String) {
        try {
            val imageFile = File(imagePath)
            val imageUri = FileProvider.getUriForFile(
                this,
                "${applicationContext.packageName}.fileprovider",
                imageFile
            )

            val whatsappIntent = Intent().apply {
                action = Intent.ACTION_SEND
                type = "image/*"
                putExtra(Intent.EXTRA_STREAM, imageUri)
                putExtra(Intent.EXTRA_TEXT, text)
                setPackage("com.whatsapp")
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }

            try {
                startActivity(whatsappIntent)
            } catch (e: Exception) {
                // WhatsApp not installed, show general share dialog
                shareImage(imagePath, text)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun shareText(text: String) {
        val shareIntent = Intent().apply {
            action = Intent.ACTION_SEND
            type = "text/plain"
            putExtra(Intent.EXTRA_TEXT, text)
        }
        startActivity(Intent.createChooser(shareIntent, "Share Text"))
    }

    private fun shareTextToTwitter(text: String) {
        try {
            val twitterIntent = Intent().apply {
                action = Intent.ACTION_SEND
                type = "text/plain"
                putExtra(Intent.EXTRA_TEXT, text)
                setPackage("com.twitter.android")
            }

            try {
                startActivity(twitterIntent)
            } catch (e: Exception) {
                // Twitter app not installed, use web intent
                val webIntent = Intent(Intent.ACTION_VIEW, Uri.parse("https://twitter.com/intent/tweet?text=${Uri.encode(text)}"))
                startActivity(webIntent)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun shareTextToWhatsApp(text: String) {
        try {
            val whatsappIntent = Intent().apply {
                action = Intent.ACTION_SEND
                type = "text/plain"
                putExtra(Intent.EXTRA_TEXT, text)
                setPackage("com.whatsapp")
            }

            try {
                startActivity(whatsappIntent)
            } catch (e: Exception) {
                // WhatsApp not installed, show general share dialog
                shareText(text)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}