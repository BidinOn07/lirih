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
// ── Patch AGP 9 untuk plugin lawas ───────────────────────────────────────
// 1) namespace: AGP 9 mewajibkan setiap modul library mendeklarasikannya.
//    on_audio_query_android 1.1.0 (versi terakhir; tak terawat sejak Mei
//    2023) belum punya → ambil dari `group`-nya, sama dengan `package` di
//    AndroidManifest.xml plugin ("com.lucasjosino.on_audio_query").
// 2) Java 17: samakan dengan jvmTarget Kotlin 17 (AGP default 11 → memicu
//    "Inconsistent JVM-target compatibility").
// 3) compileSdk 36: AGP 9.1.0 (pin Flutter 3.47.6) maksimum mendukung 36.
//    on_audio_query_android masih compileSdkVersion 33 padahal dependency
//    androidx-nya (fragment 1.7.1, window 1.2.0, …) mewajibkan ≥ 34.
//    compileSdk hanya menentukan API saat kompilasi — tidak mengubah minSdk
//    atau perilaku runtime (backward compatible).
//
// afterEvaluate dipasang SEBELUM `evaluationDependsOn(":app")` di bawah,
// karena subproject yang sudah ter-evaluasi menolak pendaftaran hook
// afterEvaluate. afterEvaluate juga mengalahkan deklarasi `android { }`
// di dalam build file plugin itu sendiri.
subprojects {
    afterEvaluate {
        plugins.withId("com.android.library") {
            extensions.configure<com.android.build.gradle.LibraryExtension> {
                if (namespace.isNullOrBlank()) {
                    val groupNs = project.group.toString()
                    if (groupNs.isNotBlank()) {
                        namespace = groupNs
                    }
                }
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
                compileSdk = 36
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
