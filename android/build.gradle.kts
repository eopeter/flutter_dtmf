plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
}

group = "com.eopeter.flutter_dtmf"
version = "1.0-SNAPSHOT"

android {
    namespace = "com.eopeter.flutter_dtmf"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        minSdk = 24
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    lint {
        isCheckReleaseBuilds = false
        disable.add("InvalidPackage")
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {}
