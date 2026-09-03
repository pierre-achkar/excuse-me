import com.android.build.api.dsl.ApkSigningConfig
import org.gradle.api.NamedDomainObjectContainer
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ------------------------------------------------------------------
// Release signing loads from a local, untracked android/key.properties
// (see android/key.properties.example for the safe template). This file
// is never committed; it is ignored by android/.gitignore. This build
// script contains no secret value.
//
// Release builds FAIL CLOSED: when a release variant is assembled and the
// keystore or any required signing property is missing, the build aborts
// instead of silently falling back to debug keys.
//
// Debug and profile builds (the offline / dev path) are UNAFFECTED: they
// keep Flutter's default debug signing and never require release material.
// The fail-closed check is therefore gated to release assemblies so it can
// never break `flutter build apk --debug`.
// ------------------------------------------------------------------

// True only when a release variant is being assembled (e.g. assembleRelease,
// bundleRelease from `flutter build apk/appbundle --release` or `flutter run
// --release`). Debug/profile assemblies use assembleDebug/assembleProfile and
// are never validated here.
val isReleaseAssembly: Boolean = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true)
}

fun loadReleaseKeystoreProperties(): Properties? {
    // key.properties lives in the android/ directory (the Gradle root project).
    val propsFile = rootProject.file("key.properties")
    if (!propsFile.exists()) return null
    val props = Properties()
    FileInputStream(propsFile).use { props.load(it) }
    return props
}

// Build the release signing config lazily only when a release variant is
// assembled. Throws (fail-closed) on any missing required property or when
// the keystore file cannot be found.
fun configureReleaseSigning(signingConfigs: NamedDomainObjectContainer<ApkSigningConfig>): Boolean {
    if (!isReleaseAssembly) return false

    val props = loadReleaseKeystoreProperties()
    val required = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
    val missing = required.filter { props?.getProperty(it).isNullOrBlank() }

    if (props == null || missing.isNotEmpty()) {
        throw GradleException(
            "Release signing is missing required input(s): " +
                (if (missing.isEmpty()) "key.properties" else missing.joinToString()) +
                ".\nCreate android/key.properties from android/key.properties.example " +
                "and provide the local keystore path. Debug builds (`flutter build apk --debug`) " +
                "are unaffected by this check."
        )
    }

    val keystoreFile = rootProject.file(props.getProperty("storeFile"))
    if (!keystoreFile.exists()) {
        throw GradleException(
            "Release keystore not found at: ${keystoreFile.absolutePath}.\n" +
                "Point storeFile=... in android/key.properties at the local keystore."
        )
    }

    signingConfigs.getByName("release").apply {
        storeFile = keystoreFile
        storePassword = props.getProperty("storePassword")
        keyAlias = props.getProperty("keyAlias")
        keyPassword = props.getProperty("keyPassword")
    }
    return true
}

android {
    namespace = "com.pierreachkar.excuse_me"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    signingConfigs {
        create("release") {
            // Populated lazily by configureReleaseSigning() only for release
            // assemblies, so this block never throws for debug builds.
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.pierreachkar.excuse_me"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Release builds are signed from the local, untracked
            // key.properties + keystore and FAIL CLOSED (see
            // configureReleaseSigning) when any required signing input is
            // missing. Debug and profile builds (the offline path) keep
            // Flutter's default debug signing and never require release
            // material.
            if (configureReleaseSigning(signingConfigs)) {
                signingConfig = signingConfigs.getByName("release")
            }
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
