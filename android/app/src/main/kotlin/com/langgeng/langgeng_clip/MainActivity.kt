package com.langgeng.langgeng_clip

import android.media.MediaExtractor
import android.media.MediaFormat
import android.media.MediaMetadataRetriever
import android.media.MediaMuxer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.nio.ByteBuffer

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

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.langgeng.clip/trim_export",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "exportTrim" -> exportTrim(
                    sourcePath = call.argument<String>("sourcePath"),
                    startMillis = call.argument<Int>("startMillis") ?: 0,
                    endMillis = call.argument<Int>("endMillis") ?: 0,
                    result = result,
                )
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

    private fun exportTrim(
        sourcePath: String?,
        startMillis: Int,
        endMillis: Int,
        result: MethodChannel.Result,
    ) {
        if (sourcePath.isNullOrBlank()) {
            result.error("invalid_source", "Path sumber video kosong.", null)
            return
        }
        if (endMillis <= startMillis) {
            result.error("invalid_range", "Range export tidak valid.", null)
            return
        }

        try {
            val outputFile = File(cacheDir, "langgeng_clip_${System.currentTimeMillis()}.mp4")
            trimWithMuxer(sourcePath, outputFile.absolutePath, startMillis, endMillis)
            result.success(outputFile.absolutePath)
        } catch (error: Exception) {
            result.error("export_failed", error.message ?: "Export trim gagal.", null)
        }
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
                val sampleTrackIndex = extractor.sampleTrackIndex
                if (sampleTrackIndex < 0) {
                    break
                }

                val sampleTime = extractor.sampleTime
                if (sampleTime > endUs) {
                    break
                }

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
}
