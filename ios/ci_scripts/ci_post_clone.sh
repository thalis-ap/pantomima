#!/bin/sh
# Fail this script if any command fails
set -e

# 1. navigate to the root of the repository immediately
# This fixes the "pubspec.yaml not found" error
cd $CI_PRIMARY_REPOSITORY_PATH

echo "📍 Current Directory: $(pwd)"

echo "🔧 Installing Flutter..."
# Cache path
FLUTTER_CACHE="$HOME/flutter"

# Clone Flutter if not cached
if [ ! -d "$FLUTTER_CACHE" ]; then
  git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_CACHE
fi

# Add Flutter to PATH
export PATH="$FLUTTER_CACHE/bin:$PATH"

flutter --version
flutter precache --ios

# 3. NOW run pub get (We are at root, so this works)
echo "📦 Running Flutter Pub Get..."
flutter pub get

# 4. Install Pods
echo "🍎 Installing Pods..."
cd ios
rm -rf Pods Podfile.lock
pod repo update
pod install

cd ..
flutter build ios --release --no-codesign

echo "✅ ci_post_clone.sh script finished successfully."