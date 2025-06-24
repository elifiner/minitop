#!/bin/bash

set -e

APP_NAME="MiniTop"
DIST_DIR="dist"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"
DOWNLOADS_DIR="downloads"

echo "Building $APP_NAME.app bundle..."

# Clean and create directories
rm -rf "$DIST_DIR" "$DOWNLOADS_DIR"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"
mkdir -p "$DOWNLOADS_DIR"

# Build for Apple Silicon (arm64)
echo "Building for Apple Silicon (arm64)..."
swiftc main.swift -o "$APP_NAME-arm64" -target arm64-apple-macos10.15

# Build for Intel (x86_64) 
echo "Building for Intel (x86_64)..."
swiftc main.swift -o "$APP_NAME-x86_64" -target x86_64-apple-macos10.15

# Create universal binary
echo "Creating universal binary..."
lipo -create -output "$APP_BUNDLE/Contents/MacOS/$APP_NAME" "$APP_NAME-arm64" "$APP_NAME-x86_64"

# Verify the universal binary
echo "Verifying universal binary..."
lipo -info "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

# Copy Info.plist
echo "Copying Info.plist..."
cp Info.plist "$APP_BUNDLE/Contents/"

# Create app icon
echo "Creating app icon..."
if [ -f "minitop.png" ]; then
    # Create iconset directory
    mkdir -p icon.iconset
    
    # Generate different icon sizes (using sips - built into macOS)
    sips -z 16 16 minitop.png --out icon.iconset/icon_16x16.png
    sips -z 32 32 minitop.png --out icon.iconset/icon_16x16@2x.png
    sips -z 32 32 minitop.png --out icon.iconset/icon_32x32.png
    sips -z 64 64 minitop.png --out icon.iconset/icon_32x32@2x.png
    sips -z 128 128 minitop.png --out icon.iconset/icon_128x128.png
    sips -z 256 256 minitop.png --out icon.iconset/icon_128x128@2x.png
    sips -z 256 256 minitop.png --out icon.iconset/icon_256x256.png
    sips -z 512 512 minitop.png --out icon.iconset/icon_256x256@2x.png
    sips -z 512 512 minitop.png --out icon.iconset/icon_512x512.png
    sips -z 1024 1024 minitop.png --out icon.iconset/icon_512x512@2x.png
    
    # Convert to icns format
    iconutil -c icns icon.iconset -o "$APP_BUNDLE/Contents/Resources/minitop.icns"
    
    # Clean up
    rm -rf icon.iconset
    
    echo "Icon created successfully"
else
    echo "Warning: minitop.png not found, skipping icon creation"
fi

# Make executable
chmod +x "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

# Create compressed archive
echo "Creating .app bundle archive..."
cd "$DIST_DIR"
zip -r -9 "../$DOWNLOADS_DIR/$APP_NAME.app.zip" "$APP_NAME.app"
cd ..

# Clean up temporary files
rm "$APP_NAME-arm64" "$APP_NAME-x86_64"

echo "Build complete!"
echo "App bundle created at: $APP_BUNDLE"
echo "Compressed archive at: $DOWNLOADS_DIR/$APP_NAME.app.zip"
echo "Compatible with macOS 10.15+ on both Intel and Apple Silicon Macs" 