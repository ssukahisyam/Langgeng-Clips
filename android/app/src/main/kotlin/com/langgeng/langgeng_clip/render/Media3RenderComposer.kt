package com.langgeng.langgeng_clip.render

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Rect
import android.graphics.RectF
import android.graphics.Typeface
import android.net.Uri
import androidx.annotation.OptIn
import androidx.media3.common.Effect
import androidx.media3.common.MediaItem
import androidx.media3.common.MimeTypes
import androidx.media3.common.util.UnstableApi
import androidx.media3.effect.BitmapOverlay
import androidx.media3.effect.OverlayEffect
import androidx.media3.effect.OverlaySettings
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
import com.google.common.collect.ImmutableList

class Media3RenderComposer(private val context: Context) {
    fun supports(request: Media3RenderRequest): Boolean {
        return request.requiresReencode
    }

    @OptIn(UnstableApi::class)
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
        val sequence = EditedMediaItemSequence(editedItem)
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

    @OptIn(UnstableApi::class)
    private fun Media3RenderRequest.videoEffects(): List<Effect> {
        val effects = mutableListOf<Effect>()
        if (cropToPortrait) {
            effects.add(
                Presentation.createForWidthAndHeight(
                    targetWidth,
                    targetHeight,
                    Presentation.LAYOUT_SCALE_TO_FIT_WITH_CROP,
                ),
            )
        }

        effects.add(
            OverlayEffect(
                ImmutableList.copyOf(
                    buildList {
                        watermark?.let { add(createWatermarkOverlay(it)) }
                        if (captionSegments.isNotEmpty()) {
                            add(createCaptionOverlay(captionSegments))
                        }
                    },
                ),
            ),
        )
        return effects
    }

    private fun createCaptionOverlay(segments: List<Media3CaptionSegment>): BitmapOverlay {
        val emptyBitmap = Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888)
        return object : BitmapOverlay() {
            override fun getBitmap(presentationTimeUs: Long): Bitmap {
                val timeMillis = presentationTimeUs / 1000
                val active = segments.firstOrNull {
                    timeMillis >= it.startMillis && timeMillis <= it.endMillis
                } ?: return emptyBitmap
                return createCaptionBitmap(active.text)
            }

            override fun getOverlaySettings(presentationTimeUs: Long): OverlaySettings {
                return OverlaySettings.Builder()
                    .setBackgroundFrameAnchor(0f, -0.48f)
                    .setOverlayFrameAnchor(0f, -1f)
                    .setScale(0.92f, 0.22f)
                    .setAlphaScale(1f)
                    .build()
            }
        }
    }

    private fun createWatermarkOverlay(config: Media3WatermarkConfig): BitmapOverlay {
        val imageBitmap = config.imagePath
            ?.takeIf { it.isNotBlank() }
            ?.let { BitmapFactory.decodeFile(it) }
        val bitmap = imageBitmap ?: createWatermarkBitmap(config.text?.takeIf { it.isNotBlank() } ?: "Langgeng Clip")
        val anchors = overlayAnchors(config.anchor)
        return BitmapOverlay.createStaticBitmapOverlay(
            bitmap,
            OverlaySettings.Builder()
                .setBackgroundFrameAnchor(anchors.first, anchors.second)
                .setOverlayFrameAnchor(anchors.first, anchors.second)
                .setScale(0.82f * config.scale, 0.16f * config.scale)
                .setAlphaScale(config.opacity)
                .build(),
        )
    }

    private fun overlayAnchors(anchor: String): Pair<Float, Float> {
        return when (anchor) {
            "topLeft" -> -1f to 1f
            "topCenter" -> 0f to 1f
            "topRight" -> 1f to 1f
            "centerLeft" -> -1f to 0f
            "center" -> 0f to 0f
            "centerRight" -> 1f to 0f
            "bottomLeft" -> -1f to -1f
            "bottomCenter" -> 0f to -1f
            else -> 1f to -1f
        }
    }

    private fun createWatermarkBitmap(text: String): Bitmap {
        val width = 960
        val height = 160
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val backgroundPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(150, 0, 0, 0)
        }
        canvas.drawRoundRect(RectF(0f, 0f, width.toFloat(), height.toFloat()), 40f, 40f, backgroundPaint)

        val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            textSize = 54f
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            textAlign = Paint.Align.CENTER
        }
        val bounds = Rect()
        textPaint.getTextBounds(text, 0, text.length, bounds)
        canvas.drawText(
            text,
            width / 2f,
            height / 2f - bounds.exactCenterY(),
            textPaint,
        )
        return bitmap
    }

    private fun createCaptionBitmap(text: String): Bitmap {
        val width = 1080
        val height = 240
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val backgroundPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(175, 0, 0, 0)
        }
        canvas.drawRoundRect(RectF(0f, 0f, width.toFloat(), height.toFloat()), 36f, 36f, backgroundPaint)

        val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            textSize = 64f
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            textAlign = Paint.Align.CENTER
        }
        val lines = text.chunked(28).take(2)
        val lineHeight = 76f
        val firstBaseline = height / 2f - ((lines.size - 1) * lineHeight / 2f) + 24f
        lines.forEachIndexed { index, line ->
            canvas.drawText(line.trim(), width / 2f, firstBaseline + index * lineHeight, textPaint)
        }
        return bitmap
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
    val watermark: Media3WatermarkConfig?,
    val captionSegments: List<Media3CaptionSegment>,
) {
    val requiresReencode: Boolean
        get() = cropToPortrait || resolution != "source" || codec != "copy"
}

data class Media3CaptionSegment(
    val text: String,
    val startMillis: Int,
    val endMillis: Int,
)

data class Media3WatermarkConfig(
    val text: String?,
    val imagePath: String?,
    val anchor: String,
    val customX: Float?,
    val customY: Float?,
    val opacity: Float,
    val scale: Float,
)

class Media3RenderCancelledException : Exception("Export dibatalkan.")
