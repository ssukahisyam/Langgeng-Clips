package com.langgeng.langgeng_clip.render

/**
 * Skeleton for the future Media3 Transformer render path.
 *
 * The current MVP exporter still uses MediaExtractor/MediaMuxer for fast trim-only
 * stream copy. This composer captures the API shape for the re-encode path that
 * will later handle 9:16 crop, target resolution scaling, and codec selection.
 */
class Media3RenderComposer {
    fun supports(request: Media3RenderRequest): Boolean {
        return request.requiresReencode
    }
}

data class Media3RenderRequest(
    val sourcePath: String,
    val startMillis: Int,
    val endMillis: Int,
    val resolution: String,
    val frameRate: String,
    val codec: String,
    val cropToPortrait: Boolean,
) {
    val requiresReencode: Boolean
        get() = cropToPortrait || resolution != "source" || codec != "copy"
}
