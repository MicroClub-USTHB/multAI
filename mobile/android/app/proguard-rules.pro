# Flutter specific
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep Dart SDK classes
-keep class dart:** { *; }

# Keep FlutterSecureStorage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Keep google_sign_in
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }

# Keep Firebase
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable

# Keep Dio
-keep class com.android.org.conscrypt.** { *; }
-keep class org.apache.harmony.xnet.provider.jsse.** { *; }

# Keep models used with json_serializable
-keep class com.example.multai_mobile.** { *; }

# Obfuscation settings
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int d(...);
    public static int i(...);
    public static int w(...);
}
