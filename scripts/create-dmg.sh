#!/bin/bash
set -e

echo "🎨 ChromaDock - Building Installer..."

APP_NAME="ChromaDock"
BUILD_DIR=".build/release"
APP_FILE="$BUILD_DIR/$APP_NAME"
OUTPUT_DIR="./dist"
DMG_FILE="$OUTPUT_DIR/$APP_NAME.dmg"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Build release binary
echo "⚡ Building release binary..."
swift build --configuration release

# Check if binary exists
if [ ! -f "$APP_FILE" ]; then
    echo "❌ Build failed - no binary found"
    exit 1
fi

# Create a temporary app bundle structure
TEMP_APP="$BUILD_DIR/$APP_NAME.app"
mkdir -p "$TEMP_APP/Contents/MacOS"
mkdir -p "$TEMP_APP/Contents/Resources"

# Create Info.plist
cat > "$TEMP_APP/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.chromadock.app</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# Copy binary into app bundle
cp "$APP_FILE" "$TEMP_APP/Contents/MacOS/$APP_NAME"
chmod +x "$TEMP_APP/Contents/MacOS/$APP_NAME"

# Create the DMG
echo "📦 Creating DMG..."
hdiutil create -volname "$APP_NAME" -srcfolder "$TEMP_APP" -ov -format UDZO "$DMG_FILE"

echo "✅ DMG created at: $DMG_FILE"
echo "🎉 Done! Double-click the DMG to install."
