import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

fun signingValue(name: String): String? {
    return (keystoreProperties.getProperty(name) ?: System.getenv("LANGGENG_${name.uppercase()}"))
        ?.takeIf { it.isNotBlank() }
}

android {
    namespace = "com.langgeng.langgeng_clip"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.langgeng.clip"
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val storeFilePath = signingValue("storeFile")
            if (storeFilePath != null) {
                storeFile = file(storeFilePath)
            }
            storePassword = signingValue("storePassword")
            keyAlias = signingValue("keyAlias")
            keyPassword = signingValue("keyPassword")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    val media3Version = "1.4.1"

    implementation("androidx.media3:media3-common:$media3Version")
    implementation("androidx.media3:media3-effect:$media3Version")
    implementation("androidx.media3:media3-transformer:$media3Version")
    implementation("com.arthenica:ffmpeg-kit-audio:6.0-2")
}
