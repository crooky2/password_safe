import org.gradle.api.JavaVersion
import org.gradle.api.plugins.JavaPluginExtension
import org.gradle.api.GradleException

if (JavaVersion.current() < JavaVersion.VERSION_17) {
    throw GradleException("Gradle 9.1.0 requires JVM 17 or later. Please set Gradle JVM/JAVA_HOME to JDK 17+.")
}

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
    project.evaluationDependsOn(":app")
}

subprojects {
    plugins.withId("java") {
        extensions.configure(JavaPluginExtension::class.java) {
            toolchain.languageVersion.set(org.gradle.jvm.toolchain.JavaLanguageVersion.of(17))
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
