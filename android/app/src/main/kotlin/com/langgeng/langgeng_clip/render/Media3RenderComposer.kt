package com.langgeng.langgeng_clip.render

import android.content.Context
import android.net.Uri
import androidx.annotation.OptIn
import androidx.media3.common.Effect
import androidx.media3.common.MediaItem
import androidx.media3.common.MimeTypes
import androidx.media3.common.util.ExperimentalApi
import androidx.media3.effect.Presentation
import androidx.media3.transformer.Composition
import androidx.media3.transformer.EditedMediaItem
import androidx.media3.transformer.EditedMediaItemSequence
import androidx.media3.transformer.Effects
import androidx.media3.transformer.ExportException
import androidx.media3.transformer.ExportResult
import androidx.media3.transformer.ProgressHolder
import androidx.media3.transformer.Transformer
import java.io.File
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicReference

class Media3RenderComposer(private val context: Context) {
    fun supports(request: Media3RenderRequest): Boolean {
        return request.requiresReencode
    }

    @OptIn(ExperimentalApi::class)
    fun render(
        request: Media3RenderRequest,
        outputFile: File,
        isCancelled: () -> Boolean,
        onProgress: (Double) -> Unit,
    ) {
        val errorRef = AtomicReference<Exception?>()
        val completeLatch = CountDownLatch(1)
        val mediaItem = MediaItem.Builder()
            .setUri(Uri.fromFile(File(request.sourcePath)))
            .setClippingConfiguration(
                MediaItem.ClippingConfiguration.Builder()
                    .setStartPositionMs(request.startMillis.toLong())
                    .setEndPositionMs(request.endMillis.toLong())
                    .build(),
            )
            .build()

        val editedItem = EditedMediaItem.Builder(mediaItem)
            .setFrameRate(request.frameRate.toIntOrNull() ?: 30)
            .setEffects(Effects(emptyList(), request.videoEffects()))
            .build()
        val sequence = EditedMediaItemSequence.Builder(editedItem).build()
        val composition = Composition.Builder(sequence).build()
        val transformer = Transformer.Builder(context)
            .setVideoMimeType(request.videoMimeType())
            .addListener(
                object : Transformer.Listener {
                    override fun onCompleted(composition: Composition, exportResult: ExportResult) {
                        completeLatch.countDown()
                    }

                    override fun onError(
                        composition: Composition,
                        exportResult: ExportResult,
                        exportException: ExportException,
                    ) {
                        errorRef.set(exportException)
                        completeLatch.countDown()
                    }
                },
            )
            .build()

        transformer.start(composition, outputFile.absolutePath)
        val progressHolder = ProgressHolder()
        while (!completeLatch.await(250, TimeUnit.MILLISECONDS)) {
            if (isCancelled()) {
                transformer.cancel()
                throw Media3RenderCancelledException()
            }
            if (transformer.getProgress(progressHolder) != Transformer.PROGRESS_STATE_NOT_STARTED) {
                onProgress((progressHolder.progress / 100.0).coerceIn(0.0, 0.9))
            }
        }

        errorRef.get()?.let { throw it }
        if (isCancelled()) {
            throw Media3RenderCancelledException()
        }
    }

    @OptIn(ExperimentalApi::class)
    private fun Media3RenderRequest.videoEffects(): List<Effect> {
        if (!cropToPortrait) {
            return emptyList()
        }

        return listOf(
            Presentation.createForWidthAndHeight(
                targetWidth,
                targetHeight,
                Presentation.LAYOUT_SCALE_TO_FIT_WITH_CROP,
            ),
        )
    }

    private fun Media3RenderRequest.videoMimeType(): String {
        return when (codec.lowercase()) {
            "hevc", "h.265", "h265" -> MimeTypes.VIDEO_H265
            else -> MimeTypes.VIDEO_H264
        }
    }
}

data class Media3RenderRequest(
    val sourcePath: String,
    val startMillis: Int,
    val endMillis: Int,
    val resolution: String,
    val frameRate: String,
    val codec: String,
    val targetWidth: Int,
    val targetHeight: Int,
    val cropToPortrait: Boolean,
) {
    val requiresReencode: Boolean
        get() = cropToPortrait || resolution != "source" || codec != "copy"
}

class Media3RenderCancelledException : Exception("Export dibatalkan.")
