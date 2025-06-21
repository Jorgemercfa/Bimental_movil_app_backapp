// build.gradle.kts (nivel raíz)

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Plugins necesarios
        classpath("com.android.tools.build:gradle:8.3.0")
        classpath("com.google.gms:google-services:4.4.1") // Plugin de Firebase
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()

        // Repositorio para TensorFlow
        maven {
            url = uri("https://storage.googleapis.com/tensorflow/maven")
        }
    }
}

// --- CONFIGURACIÓN PERSONALIZADA DE BUILD ---
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // Esto asegura que el plugin se aplique correctamente
    afterEvaluate {
        if (plugins.hasPlugin("com.android.application")) {
            apply(plugin = "com.google.gms.google-services")
        }
    }
}

// Evaluación forzada de :app primero
subprojects {
    project.evaluationDependsOn(":app")
}

// Tarea clean personalizada
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
