package com.langgeng.langgeng_clip

import android.content.ContentValues
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.media.MediaExtractor
import android.media.MediaFormat
import android.media.MediaMetadataRetriever
import android.media.MediaMuxer
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import com.langgeng.langgeng_clip.pigeon.FlutterError
import com.langgeng.langgeng_clip.pigeon.NativeRenderApi
import com.langgeng.langgeng_clip.pigeon.RenderRequest
import com.langgeng.langgeng_clip.pigeon.RenderResult
import java.io.File
import java.io.FileInputStream
import java.nio.ByteBuffer

class MainActivity : FlutterActivity() {
    private val exportNotificationId = 3101
    private val exportChannelId = "langgeng_clip_exports"
    private var exportProgressSink: EventChannel.EventSink? = null
    @Volatile
    private var isExportCancelled = false
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        ensureExportNotificationChannel()

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.langgeng.clip/video_probe",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "probe" -> probeVideo(call.argument<String>("path"), result)
                else -> result.notImplemented()
            }
        }

        NativeRenderApi.setUp(
            flutterEngine.dartExecutor.binaryMessenger,
            object : NativeRenderApi {
                override fun exportTrim(
                    request: RenderRequest,
                    callback: (Result<RenderResult>) -> Unit,
                ) {
                    exportTrim(request, callback)
                }

                override fun cancelExport(callback: (Result<Unit>) -> Unit) {
                    isExportCancelled = true
                    callback(Result.success(Unit))
                }
            },
        )

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.langgeng.clip/trim_export_progress",
        ).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    exportProgressSink = events
                }

                override fun onCancel(arguments: Any?) {
                    exportProgressSink = null
                }
            },
        )

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.langgeng.clip/export_actions",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "share" -> shareExport(
                    uri = call.argument<String>("uri"),
                    title = call.argument<String>("title") ?: "Langgeng Clip export",
                    result = result,
                )
                else -> result.notImplemented()
            }
        }
    }

    private fun shareExport(uri: String?, title: String, result: MethodChannel.Result) {
        if (uri.isNullOrBlank()) {
            result.error("invalid_uri", "URI export tidak tersedia.", null)
            return
        }

        val shareIntent = Intent(Intent.ACTION_SEND).apply {
            type = "video/mp4"
            putExtra(Intent.EXTRA_STREAM, Uri.parse(uri))
            putExtra(Intent.EXTRA_TITLE, title)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        startActivity(Intent.createChooser(shareIntent, title))
        result.success(null)
    }

    private fun probeVideo(path: String?, result: MethodChannel.Result) {
        if (path.isNullOrBlank()) {
            result.error("invalid_path", "Path video kosong.", null)
            return
        }

        val retriever = MediaMetadataRetriever()
        try {
            retriever.setDataSource(path)
            result.success(
                mapOf(
                    "durationMillis" to retriever.extractInt(
                        MediaMetadataRetriever.METADATA_KEY_DURATION,
                    ),
                    "width" to retriever.extractInt(
                        MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH,
                    ),
                    "height" to retriever.extractInt(
                        MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT,
                    ),
                    "rotationDegrees" to retriever.extractInt(
                        MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION,
                    ),
                    "mimeType" to (
                        retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_MIMETYPE)
                            ?: "unknown"
                    ),
                ),
            )
        } catch (error: Exception) {
            result.error("probe_failed", error.message ?: "Gagal membaca metadata video.", null)
        } finally {
            retriever.release()
        }
    }

    private fun MediaMetadataRetriever.extractInt(keyCode: Int): Int {
        return extractMetadata(keyCode)?.toIntOrNull() ?: 0
    }

    private fun exportTrim(request: RenderRequest, callback: (Result<RenderResult>) -> Unit) {
        if (request.sourcePath.isBlank()) {
            callback(
                Result.failure(
                    FlutterError("invalid_source", "Path sumber video kosong.", null),
                ),
            )
            return
        }
        if (request.endMillis <= request.startMillis) {
            callback(
                Result.failure(
                    FlutterError("invalid_range", "Range export tidak valid.", null),
                ),
            )
            return
        }
        if (request.targetWidth <= 0 || request.targetHeight <= 0) {
            callback(
                Result.failure(
                    FlutterError("invalid_target", "Resolusi target export tidak valid.", null),
                ),
            )
            return
        }

        isExportCancelled = false
        Thread {
            try {
                sendExportProgress(0.0)
                val outputFile = File(cacheDir, "langgeng_clip_${System.currentTimeMillis()}.mp4")
                trimWithMuxer(
                    request.sourcePath,
                    outputFile.absolutePath,
                    request.startMillis.toInt(),
                    request.endMillis.toInt(),
                )
                ensureExportNotCancelled()
                sendExportProgress(0.95)
                val galleryUri = saveToGallery(outputFile)
                ensureExportNotCancelled()
                sendExportProgress(1.0)
                mainHandler.post {
                    callback(
                        Result.success(
                            RenderResult(
                                cachePath = outputFile.absolutePath,
                                galleryUri = galleryUri,
                                resolution = request.resolution,
                                frameRate = request.frameRate,
                                codec = request.codec,
                                targetWidth = request.targetWidth,
                                targetHeight = request.targetHeight,
                                cropToPortrait = request.cropToPortrait,
                                requiresReencode = request.requiresReencode,
                            ),
                        ),
                    )
                }
            } catch (error: ExportCancelledException) {
                mainHandler.post {
                    callback(
                        Result.failure(
                            FlutterError("export_cancelled", "Export dibatalkan.", null),
                        ),
                    )
                }
            } catch (error: Exception) {
                mainHandler.post {
                    callback(
                        Result.failure(
                            FlutterError("export_failed", error.message ?: "Export trim gagal.", null),
                        ),
                    )
                }
            }
        }.start()
    }

    private fun ensureExportNotCancelled() {
        if (isExportCancelled) {
            throw ExportCancelledException()
        }
    }

    private fun sendExportProgress(value: Double) {
        mainHandler.post {
            showExportNotification(value)
            exportProgressSink?.success(
                mapOf(
                    "progress" to value.coerceIn(0.0, 1.0),
                ),
            )
        }
    }

    private fun ensureExportNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }

        val notificationManager = getSystemService(NotificationManager::class.java)
        val channel = NotificationChannel(
            exportChannelId,
            "Export progress",
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = "Shows Langgeng Clip export progress."
        }
        notificationManager.createNotificationChannel(channel)
    }

    private fun showExportNotification(value: Double) {
        val notificationManager = getSystemService(NotificationManager::class.java)
        val progress = (value.coerceIn(0.0, 1.0) * 100).toInt()
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, exportChannelId)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }

        val notification = builder
            .setSmallIcon(android.R.drawable.stat_sys_upload)
            .setContentTitle("Langgeng Clip export")
            .setContentText(if (progress >= 100) "Export complete" else "Exporting... $progress%")
            .setProgress(100, progress, false)
            .setOngoing(progress < 100)
            .build()

        try {
            notificationManager.notify(exportNotificationId, notification)
        } catch (_: SecurityException) {
            // Android 13+ can require runtime notification permission; export still works.
        }
    }

    private fun saveToGallery(outputFile: File): String? {
        val resolver = applicationContext.contentResolver
        val values = ContentValues().apply {
            put(MediaStore.Video.Media.DISPLAY_NAME, outputFile.name)
            put(MediaStore.Video.Media.MIME_TYPE, "video/mp4")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(MediaStore.Video.Media.RELATIVE_PATH, "Movies/Langgeng Clip")
                put(MediaStore.Video.Media.IS_PENDING, 1)
            }
        }

        val uri = resolver.insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, values)
            ?: return null

        resolver.openOutputStream(uri)?.use { outputStream ->
            FileInputStream(outputFile).use { inputStream ->
                inputStream.copyTo(outputStream)
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            values.clear()
            values.put(MediaStore.Video.Media.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
        }

        return uri.toString()
    }

    private fun trimWithMuxer(
        sourcePath: String,
        outputPath: String,
        startMillis: Int,
        endMillis: Int,
    ) {
        val extractor = MediaExtractor()
        var muxer: MediaMuxer? = null
        var muxerStarted = false

        try {
            extractor.setDataSource(sourcePath)
            muxer = MediaMuxer(outputPath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)

            val trackMap = mutableMapOf<Int, Int>()
            var maxInputSize = 1 * 1024 * 1024

            for (trackIndex in 0 until extractor.trackCount) {
                val format = extractor.getTrackFormat(trackIndex)
                val mime = format.getString(MediaFormat.KEY_MIME) ?: continue
                if (mime.startsWith("video/") || mime.startsWith("audio/")) {
                    extractor.selectTrack(trackIndex)
                    trackMap[trackIndex] = muxer.addTrack(format)
                    if (format.containsKey(MediaFormat.KEY_MAX_INPUT_SIZE)) {
                        maxInputSize = maxOf(
                            maxInputSize,
                            format.getInteger(MediaFormat.KEY_MAX_INPUT_SIZE),
                        )
                    }
                }
            }

            if (trackMap.isEmpty()) {
                throw IllegalStateException("Tidak ada track video/audio yang bisa diexport.")
            }

            muxer.start()
            muxerStarted = true

            val buffer = ByteBuffer.allocate(maxInputSize)
            val bufferInfo = android.media.MediaCodec.BufferInfo()
            val startUs = startMillis * 1000L
            val endUs = endMillis * 1000L

            extractor.seekTo(startUs, MediaExtractor.SEEK_TO_PREVIOUS_SYNC)

            while (true) {
                ensureExportNotCancelled()
                val sampleTrackIndex = extractor.sampleTrackIndex
                if (sampleTrackIndex < 0) {
                    break
                }

                val sampleTime = extractor.sampleTime
                if (sampleTime > endUs) {
                    break
                }

                val rangeUs = maxOf(1L, endUs - startUs)
                val progress = ((sampleTime - startUs).toDouble() / rangeUs)
                    .coerceIn(0.0, 0.9)
                sendExportProgress(progress)

                val muxerTrackIndex = trackMap[sampleTrackIndex]
                if (muxerTrackIndex == null) {
                    extractor.advance()
                    continue
                }

                buffer.clear()
                val sampleSize = extractor.readSampleData(buffer, 0)
                if (sampleSize < 0) {
                    break
                }

                bufferInfo.set(
                    0,
                    sampleSize,
                    maxOf(0L, sampleTime - startUs),
                    extractor.sampleFlags,
                )
                muxer.writeSampleData(muxerTrackIndex, buffer, bufferInfo)
                extractor.advance()
            }
        } finally {
            extractor.release()
            if (muxerStarted) {
                muxer?.stop()
            }
            muxer?.release()
        }
    }

    private class ExportCancelledException : Exception("Export dibatalkan.")
}
