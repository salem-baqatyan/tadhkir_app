allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
subprojects {
    project.afterEvaluate {
        if (project.hasProperty("android")) {
            val androidExtension = project.extensions.findByName("android") as? com.android.build.gradle.AppExtension
            androidExtension?.let {
                if (it.namespace == null) {
                    it.namespace = project.group.toString()
                }
            }
        }
    }
}


val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
