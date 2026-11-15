import com.android.build.api.dsl.LibraryExtension

allprojects {
    repositories {
        google()
        mavenCentral()
        maven("https://jitpack.io")
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Supply a namespace only for legacy plugins missing one, without modifying
// their source in the shared Pub cache. Keep each plugin's declared compileSdk.
subprojects {
    plugins.withId("com.android.library") {
        extensions.configure<LibraryExtension> {
            if (namespace == null) {
                namespace = "com.flutter.plugins.${project.name.replace('-', '_').replace('.', '_')}"
            }
        }
    }
}

// Regression guard: migrations must remove KGP, not hide Flutter's warnings.
tasks.register("verifyBuiltInKotlin") {
    group = "verification"
    description = "Check that every Android module uses built-in Kotlin, not legacy KGP"
    doLast {
        val androidProjects = subprojects.filter {
            it.plugins.hasPlugin("com.android.application") || it.plugins.hasPlugin("com.android.library")
        }
        check(androidProjects.isNotEmpty()) { "No Android modules were configured" }
        androidProjects.forEach { module ->
            check(!module.plugins.hasPlugin("org.jetbrains.kotlin.android") &&
                !module.plugins.hasPlugin("kotlin-android")) {
                "${module.path} still applies the legacy Kotlin Android plugin"
            }
            // Built-in Kotlin is part of AGP, not a separately applied plugin
            // ID. Verify its extension and compiler task with the flag enabled.
            check(providers.gradleProperty("android.builtInKotlin").orNull == "true" &&
                module.extensions.findByName("kotlin") != null &&
                module.tasks.names.any { it.startsWith("compile") && it.endsWith("DebugKotlin") }) {
                "${module.path} has not enabled AGP built-in Kotlin"
            }
        }
        logger.lifecycle("Verified built-in Kotlin for ${androidProjects.size} Android modules")
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
