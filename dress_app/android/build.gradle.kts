allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://maven.cashfree.com/release")
            content {
                includeGroup("com.cashfree.pg")
                includeGroupByRegex("com\\.cashfree.*")
            }
        }
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
    val subproject = this
    subproject.configurations.all {
        resolutionStrategy {
            force("androidx.core:core:1.13.1")
            force("androidx.core:core-ktx:1.13.1")
            force("com.android.volley:volley:1.2.1")
        }
    }
}
subprojects {
    val subproject = this
    subproject.pluginManager.withPlugin("com.android.library") {
        val androidExt = subproject.extensions.findByName("android")
        if (androidExt is com.android.build.gradle.BaseExtension) {
            androidExt.compileSdkVersion(34)
            androidExt.ndkVersion = "27.0.12077973"
            if (androidExt.namespace == null) {
                androidExt.namespace = subproject.group.toString().takeIf { it.isNotEmpty() } ?: "com.example.${subproject.name}"
            }
            println("Set compileSdkVersion 34 for subproject: ${subproject.name}")
        }
    }
    subproject.tasks.whenTaskAdded {
        if (this.name.contains("verifyReleaseResources", ignoreCase = true) || this.name.contains("verifyDebugResources", ignoreCase = true)) {
            this.enabled = false
        }
    }
}
subprojects {
    if (project.name != "app") {
        project.evaluationDependsOn(":app")
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
