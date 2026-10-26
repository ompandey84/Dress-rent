allprojects {
    repositories {
        google()
        mavenCentral()
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
            force("androidx.core:core:1.12.0")
            force("androidx.core:core-ktx:1.12.0")
        }
    }
}
subprojects {
    val subproject = this
    subproject.pluginManager.withPlugin("com.android.library") {
        val androidExt = subproject.extensions.findByName("android")
        if (androidExt is com.android.build.gradle.BaseExtension) {
            androidExt.compileSdkVersion(34)
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
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
