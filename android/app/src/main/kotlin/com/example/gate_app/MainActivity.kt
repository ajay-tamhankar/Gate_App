package com.example.gate_app

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException

class MainActivity : FlutterActivity() {
    private val fileChannelName = "gate_reco/files"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, fileChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveFileToDownloads" -> {
                        try {
                            val fileName = call.argument<String>("fileName")
                            val mimeType = call.argument<String>("mimeType")
                            val bytes = call.argument<ByteArray>("bytes")

                            if (fileName.isNullOrBlank() || mimeType.isNullOrBlank() || bytes == null) {
                                result.error("invalid_args", "Missing required arguments", null)
                                return@setMethodCallHandler
                            }

                            val savedUri = saveFileToDownloads(
                                fileName = fileName,
                                mimeType = mimeType,
                                bytes = bytes,
                            )
                            result.success(savedUri)
                        } catch (e: Exception) {
                            result.error("save_failed", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    @Throws(IOException::class)
    private fun saveFileToDownloads(
        fileName: String,
        mimeType: String,
        bytes: ByteArray,
    ): String {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            return saveFileToLegacyDownloads(fileName, bytes)
        }

        val resolver = applicationContext.contentResolver
        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
            put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
            put(
                MediaStore.MediaColumns.RELATIVE_PATH,
                Environment.DIRECTORY_DOWNLOADS
            )
            put(MediaStore.MediaColumns.IS_PENDING, 1)
        }

        val collection = MediaStore.Downloads.EXTERNAL_CONTENT_URI
        val itemUri = resolver.insert(collection, values)
            ?: throw IOException("Unable to create file in Downloads")

        resolver.openOutputStream(itemUri)?.use { stream ->
            stream.write(bytes)
            stream.flush()
        } ?: throw IOException("Unable to open output stream")

        val finalizeValues = ContentValues().apply {
            put(MediaStore.MediaColumns.IS_PENDING, 0)
        }
        resolver.update(itemUri, finalizeValues, null, null)

        return itemUri.toString()
    }

    @Throws(IOException::class)
    private fun saveFileToLegacyDownloads(
        fileName: String,
        bytes: ByteArray,
    ): String {
        val downloadsDir = Environment.getExternalStoragePublicDirectory(
            Environment.DIRECTORY_DOWNLOADS
        )
        val outFile = File(downloadsDir, fileName)
        outFile.outputStream().use { stream ->
            stream.write(bytes)
            stream.flush()
        }

        return outFile.absolutePath
    }
}
