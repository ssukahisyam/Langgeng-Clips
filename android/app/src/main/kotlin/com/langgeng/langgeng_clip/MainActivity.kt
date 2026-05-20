package com.langgeng.langgeng_clip

import android.media.MediaMetadataRetriever
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.langgeng.clip/video_probe",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "probe" -> probeVideo(call.argument<String>("path"), result)
                else -> result.notImplemented()
            }
        }
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
}
