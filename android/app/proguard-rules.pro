# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep Flutter Engine and Dart entrypoints
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable

# Firebase & Google Play Services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**
-dontwarn com.google.android.play.core.**

# Kotlin Coroutines & Reflection
-keepclassmembers class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**

# Dio / OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**

# VibeCraft custom native classes
-keep class com.vibecraft.app.** { *; }
