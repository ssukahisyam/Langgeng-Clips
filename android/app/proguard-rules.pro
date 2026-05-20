# Flutter embedding and generated plugin registrant.
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# Langgeng Clip native channels.
-keep class com.langgeng.langgeng_clip.** { *; }

# Android media APIs are referenced directly by the render/probe pipeline.
-keep class android.media.** { *; }

# Future Media3/Pigeon integrations should be safe with these package-level rules.
-keep class androidx.media3.** { *; }
-keep class dev.flutter.pigeon.** { *; }
