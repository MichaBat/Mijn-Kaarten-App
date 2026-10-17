# Home screen widget classes are only referenced by name from
# AndroidManifest.xml / Intent, not from Kotlin call sites directly.
-keep class com.batelaan.bonidus_apidus.CardWidgetProvider { *; }
-keep class com.batelaan.bonidus_apidus.CardWidgetFactory { *; }
-keep class com.batelaan.bonidus_apidus.CardWidgetService { *; }

# ML Kit barcode scanning (used by mobile_scanner) relies on reflection
# internally. Its AAR ships its own consumer rules; this is a safety net.
-keep class com.google.mlkit.vision.barcode.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_barcode.** { *; }
