plugins { id("com.android.application"); id("kotlin-android"); id("dev.flutter.flutter-gradle-plugin") }

android {
    namespace = "com.kidsgame.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    compileOptions { sourceCompatibility = JavaVersion.VERSION_17; targetCompatibility = JavaVersion.VERSION_17 }
    kotlinOptions { jvmTarget = JavaVersion.VERSION_17.toString() }
    defaultConfig { applicationId = "com.kidsgame.app"; minSdk = flutter.minSdkVersion; targetSdk = flutter.targetSdkVersion; versionCode = flutter.versionCode; versionName = flutter.versionName }
    flavorDimensions += "environment"
    productFlavors {
        create("development") { dimension = "environment"; applicationIdSuffix = ".dev"; resValue("string", "app_name", "GenGames") }
        create("staging") { dimension = "environment"; applicationIdSuffix = ".staging"; resValue("string", "app_name", "GenGames STAGING") }
        create("production") { dimension = "environment"; resValue("string", "app_name", "GenGames") }
    }
    buildTypes { release { signingConfig = signingConfigs.getByName("debug") } }
}
flutter { source = "../.." }

