plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

fun readKakaoNativeAppKey(): String {
    // 1) android/local.properties (gitignored)
    val localProperties = rootProject.file("local.properties")
    if (localProperties.exists()) {
        val fromLocal = localProperties.readLines()
            .map { it.trim() }
            .firstOrNull { !it.startsWith("#") && it.startsWith("kakao.native.app.key=") }
            ?.substringAfter("=")
            ?.trim()
            ?.trim('"')
            .orEmpty()
        if (fromLocal.isNotEmpty()) return fromLocal
    }

    // 2) project root .env (gitignored, used by flutter_dotenv)
    val envFile = rootProject.file("../.env")
    if (envFile.exists()) {
        val fromEnv = envFile.readLines()
            .map { it.trim() }
            .firstOrNull { !it.startsWith("#") && it.startsWith("KAKAO_NATIVE_APP_KEY=") }
            ?.substringAfter("=")
            ?.trim()
            ?.trim('"')
            .orEmpty()
        if (fromEnv.isNotEmpty()) return fromEnv
    }

    return ""
}

val kakaoNativeAppKey = readKakaoNativeAppKey()
if (kakaoNativeAppKey.isBlank()) {
    throw GradleException(
        """
        Missing Kakao native app key for Android redirect scheme.
        Set one of (do NOT commit secrets):
          - android/local.properties -> kakao.native.app.key=YOUR_KEY
          - project root .env -> KAKAO_NATIVE_APP_KEY=YOUR_KEY
        Then run a full rebuild: flutter clean && flutter run
        """.trimIndent()
    )
}

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
        // Becomes kakao{NATIVE_APP_KEY}. Key is read from gitignored local files.
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
