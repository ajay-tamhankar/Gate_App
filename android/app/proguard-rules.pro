# ML Kit text recognition ships one Java entry point that can construct a
# recogniser for ANY script — Latin, Chinese, Devanagari, Japanese, Korean —
# but each script's options class lives in its own artifact. We depend on the
# Latin one only, because every document at the gate is printed in English, so
# R8 finds references to four classes that are not on the classpath and fails
# the release build outright.
#
# Suppressing the warnings is the correct fix rather than a workaround: the
# code paths that would touch these are unreachable, because OnDeviceOcr asks
# for TextRecognitionScript.latin and nothing else. Adding the other four
# artifacts would grow the APK for scripts no invoice here uses.
#
# These rules are exactly what R8 itself generated in
# build/app/outputs/mapping/release/missing_rules.txt.
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions

# The Latin recogniser is reached through reflection by ML Kit's own
# registrar, so keep it and its options rather than letting R8 decide it is
# unused and strip the one script we actually need.
-keep class com.google.mlkit.vision.text.latin.** { *; }
-keep class com.google.mlkit.vision.text.TextRecognition { *; }
