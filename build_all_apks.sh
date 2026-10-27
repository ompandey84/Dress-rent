#!/usr/bin/env bash
set -e

OUTPUT_DIR="/home/om-pandey/Desktop/dress/APKs"
mkdir -p "$OUTPUT_DIR"

echo "=========================================="
echo " STEP 1: Building dress_app (arm64 release)"
echo "=========================================="
cd /home/om-pandey/Desktop/dress/dress_app
flutter build apk --release --target-platform=android-arm64 --android-skip-build-dependency-validation

DRESS_APK=$(find /home/om-pandey/Desktop/dress/dress_app/build -name "*.apk" 2>/dev/null | head -n 1)
if [ -z "$DRESS_APK" ]; then
    DRESS_APK=$(find /home/om-pandey/Desktop/dress/build -name "*dress*.apk" 2>/dev/null | head -n 1)
fi

if [ -n "$DRESS_APK" ]; then
    cp "$DRESS_APK" "$OUTPUT_DIR/dress_app_release.apk"
    echo "SUCCESS: Copied dress_app APK to $OUTPUT_DIR/dress_app_release.apk"
else
    echo "ERROR: dress_app APK was not found!"
    exit 1
fi

echo "=========================================="
echo " STEP 2: Building admin_app (arm64 release)"
echo "=========================================="
cd /home/om-pandey/Desktop/dress/admin_app
flutter build apk --release --target-platform=android-arm64 --android-skip-build-dependency-validation

ADMIN_APK=$(find /home/om-pandey/Desktop/dress/admin_app/build -name "*.apk" 2>/dev/null | head -n 1)
if [ -z "$ADMIN_APK" ]; then
    ADMIN_APK=$(find /home/om-pandey/Desktop/dress/build -name "*admin*.apk" 2>/dev/null | head -n 1)
fi

if [ -n "$ADMIN_APK" ]; then
    cp "$ADMIN_APK" "$OUTPUT_DIR/admin_app_release.apk"
    echo "SUCCESS: Copied admin_app APK to $OUTPUT_DIR/admin_app_release.apk"
else
    echo "ERROR: admin_app APK was not found!"
    exit 1
fi

echo "=========================================="
echo " ALL APKS BUILT SUCCESSFULLY!"
echo "=========================================="
ls -lh "$OUTPUT_DIR"/*.apk
