plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.news_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // FIXED: Replaced deprecated kotlinOptions with compilerOptions
    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    // FIXED: Added this block to handle V1/V2 signing properly
    signingConfigs {
        create("release") {
            // We are using the debug keystore for now, as you requested.
            // This allows V1/V2 signing customization.
            storeFile = file("${System.getProperty("user.home")}/.android/debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
            enableV1Signing = true
            enableV2Signing = true
        }
    }

    defaultConfig {
        applicationId = "com.example.news_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        // ADD THIS BLOCK TO REMOVE x86 (EMULATOR) FILES
        ndk {
            // Only package for physical Android phones
            abiFilters.add("armeabi-v7a")
            abiFilters.add("arm64-v8a")
        }
    }

    buildTypes {
        release {
            // FIXED: Point to the custom config created above
            signingConfig = signingConfigs.getByName("release")
        }
    }

    // Rename the output APK
    applicationVariants.all {
        outputs
            .map { it as com.android.build.gradle.internal.api.ApkVariantOutputImpl }
            .forEach { output ->

                    output.outputFileName = "News App.apk"

            }
    }
}

flutter {
    source = "../.."
}
