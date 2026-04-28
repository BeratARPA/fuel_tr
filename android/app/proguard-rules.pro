# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# WorkManager
-keep class androidx.work.** { *; }

# Local Notifications
-keep class com.dexterous.** { *; }

# HTTP/XML
-dontwarn org.xmlpull.**
-keep class org.xmlpull.** { *; }

# Deferred Components / Play Core
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
