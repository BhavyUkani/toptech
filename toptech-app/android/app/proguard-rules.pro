# Keep WorkManager classes from being obfuscated or stripped
-keep class androidx.work.** { *; }
-dontwarn androidx.work.**

# Keep Room database classes from being obfuscated or stripped
-keep class androidx.room.** { *; }
-dontwarn androidx.room.**

# Keep all subclasses of RoomDatabase (WorkManager's WorkDatabase uses Room internally)
-keep class * extends androidx.room.RoomDatabase { *; }
-keep class * extends androidx.work.RxWorker { *; }
-keep class * extends androidx.work.Worker { *; }
-keep class * extends androidx.work.ListenableWorker { *; }
