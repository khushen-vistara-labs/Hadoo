pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_PROJECT)
    repositories {
        google()
        mavenCentral()
        maven("https://jitpack.io")
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // Gradle 9.6+ removed internal APIs used by AGP 8.x. Keep application and
    // native-library plugins on the same stable AGP release.
    id("com.android.application") version "9.4.1" apply false
    id("com.android.library") version "9.4.1" apply false
    id("org.jetbrains.kotlin.plugin.compose") version "2.4.21" apply false
}

include(":app")

// Rive 0.1.11 still unconditionally applies legacy KGP. Use a version-scoped
// build script overlay, keeping its native sources and setup tool unchanged.
// Never rewrite shared Pub-cache files as part of project configuration.
findProject(":rive_native")?.let { rive ->
    val pubspec = rive.projectDir.parentFile.resolve("pubspec.yaml").readText()
    require(Regex("(?m)^version:\\s*0\\.1\\.11\\s*$").containsMatchIn(pubspec)) {
        "Re-evaluate the rive_native Kotlin build overlay after changing its version."
    }
    rive.buildFileName = rive.projectDir.toPath()
        .relativize(file("compat/rive_native.gradle").toPath()).toString()
}

// home_widget guards KGP at runtime, but Flutter 3.47 scans its Groovy script
// text and still reports the legacy declaration. Use a genuinely built-in-only
// build script, preserving source sets and dependencies, rather than suppressing
// Flutter's diagnostics or applying a legacy plugin under a different name.
findProject(":home_widget")?.let { widget ->
    val pubspec = widget.projectDir.parentFile.resolve("pubspec.yaml").readText()
    require(Regex("(?m)^version:\\s*0\\.10\\.0\\s*$").containsMatchIn(pubspec)) {
        "Re-evaluate the home_widget Kotlin build overlay after changing its version."
    }
    widget.buildFileName = widget.projectDir.toPath()
        .relativize(file("compat/home_widget.gradle").toPath()).toString()
}
