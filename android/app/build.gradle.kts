plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "dev.samuel.shopping_list"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "dev.samuel.shopping_list"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Keep debug signing available for CI when environment signing settings are absent.
            val keystore = System.getenv("SHOPPING_LIST_KEYSTORE")
            signingConfig = if (keystore != null) {
                val password = System.getenv("SHOPPING_LIST_KEYSTORE_PASSWORD")
                    ?: throw GradleException("SHOPPING_LIST_KEYSTORE_PASSWORD is required when SHOPPING_LIST_KEYSTORE is set")
                val alias = System.getenv("SHOPPING_LIST_KEY_ALIAS")
                    ?: throw GradleException("SHOPPING_LIST_KEY_ALIAS is required when SHOPPING_LIST_KEYSTORE is set")
                signingConfigs.create("release") {
                    storeFile = file(keystore)
                    storePassword = password
                    keyPassword = password
                    keyAlias = alias
                }
            } else {
                signingConfigs.getByName("debug")
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
