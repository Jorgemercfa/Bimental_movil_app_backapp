plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // <-- IMPORTANTE: plugin de Firebase
}

android {
    namespace = "com.example.bimental"
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        ndkVersion = "27.0.12077973"
        applicationId = "com.example.bimental"
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    packagingOptions {
        pickFirst("lib/**/libtensorflowlite.so")
        pickFirst("lib/**/libtensorflowlite_select_tf_ops.so")
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("org.tensorflow:tensorflow-lite:2.15.0.so")
    implementation("org.tensorflow:tensorflow-lite-select-tf-ops:2.15.0.so")

    // Ejemplos de dependencias Firebase (añade según las que uses en Dart)
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
}