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

// ── Patch izin on_audio_query_android (task 1.12) ───────────────────────
// Plugin lawas (tak terawat sejak Mei 2023) meminta DUA izin di Android 13+:
// READ_MEDIA_AUDIO dan READ_MEDIA_IMAGES. Dampaknya ganda:
//   1) Lirih hanya butuh akses audio — meminta izin foto pada pemutar musik
//      adalah overreach privasi (merugikan Review Play & kepercayaan user).
//   2) permissionStatus() AND-kan kedua izin, sedangkan requestPermission()
//      hanya mengecek grantResults[0]. Saat query dipanggil dalam keadaan
//      "belum granted", plugin membalas method channel DUA kali
//      (result.error lalu result.success) → "Reply already submitted" →
//      FATAL EXCEPTION di thread main → crash. Inilah yang menjatuhkan app
//      di perangkat Xiaomi (log: TransactionExecutor gagal + Shutting down
//      VM). Lihat AGENTS.md §PoC & task 1.12.
// Patch mengecilkan array izin: audio saja (API 33+) / read storage saja
// (API ≤ 32), dan menyederhanakan retryRequestPermission() yang tadinya
// mengakses permissions[1] (kini di luar batas). Idempoten: melompat bila
// sudah ditambal. Sama blok afterEvaluate di atas, ini HARUS dipasang
// sebelum evaluationDependsOn(":app") di bawah.
subprojects {
    afterEvaluate {
        val controller = layout.projectDirectory
            .file(
                "src/main/kotlin/com/lucasjosino/on_audio_query/controllers/" +
                    "PermissionController.kt",
            )
            .asFile
        if (!controller.exists()) return@afterEvaluate
        val patchTask = tasks.register("patchOnAudioQueryPermission") {
            doLast {
                val original = controller.readText()
                if (original.contains("LIRIH-PATCHED-AUDIO-ONLY")) {
                    return@doLast
                }
                controller.writeText(
                    original
                        .replace(
                            Regex(
                                "Manifest\\.permission\\.READ_MEDIA_AUDIO,\\s*" +
                                    "Manifest\\.permission\\.READ_MEDIA_IMAGES",
                            ),
                            "Manifest.permission.READ_MEDIA_AUDIO" +
                                " // LIRIH-PATCHED-AUDIO-ONLY",
                        )
                        .replace(
                            Regex(
                                "Manifest\\.permission\\.READ_EXTERNAL_STORAGE,\\s*" +
                                    "Manifest\\.permission\\.WRITE_EXTERNAL_STORAGE",
                            ),
                            "Manifest.permission.READ_EXTERNAL_STORAGE",
                        )
                        .replace(
                            Regex(
                                "ActivityCompat\\.shouldShowRequestPermissionRationale" +
                                    "\\(activity, permissions\\[0\\]\\)\\s*\\|\\|\\s*" +
                                    "ActivityCompat\\.shouldShowRequestPermissionRationale" +
                                    "\\(activity, permissions\\[1\\]\\)",
                            ),
                            "ActivityCompat.shouldShowRequestPermissionRationale" +
                                "(activity, permissions[0])",
                        ),
                )
            }
        }
        tasks.matching {
            it.name == "compileDebugKotlin" || it.name == "compileReleaseKotlin"
        }.configureEach { dependsOn(patchTask) }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
