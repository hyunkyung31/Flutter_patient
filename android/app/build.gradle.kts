plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

fun readKakaoNativeAppKey(): String {
    val envFile = rootProject.file("../.env")
    if (!envFile.exists()) return ""

    return envFile.readLines()
        .map { it.trim() }
        .firstOrNull { !it.startsWith("#") && it.startsWith("KAKAO_NATIVE_APP_KEY=") }
        ?.substringAfter("=")
        ?.trim()
        ?.trim('"')
        .orEmpty()
}

val kakaoNativeAppKey = readKakaoNativeAppKey()

android {
    namespace = "com.vena.patient_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.vena.patient_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Kakao redirect scheme: kakao{NATIVE_APP_KEY}
        // Must match KAKAO_NATIVE_APP_KEY in the project .env file.
        // Also register this applicationId + key hash in Kakao Developers Console.
        manifestPlaceholders["kakaoScheme"] = "kakao$kakaoNativeAppKey"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
