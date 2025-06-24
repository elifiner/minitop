#!/bin/bash

set -e

APP_NAME="MiniTop"
DOWNLOADS_DIR="downloads"

echo "Building universal $APP_NAME..."

# Clean and create directories
rm -rf "$DOWNLOADS_DIR"
mkdir -p "$DOWNLOADS_DIR"

# Build for Apple Silicon (arm64)
echo "Building for Apple Silicon (arm64)..."
swiftc main.swift -o "$APP_NAME-arm64" -target arm64-apple-macos10.15

# Build for Intel (x86_64) 
echo "Building for Intel (x86_64)..."
swiftc main.swift -o "$APP_NAME-x86_64" -target x86_64-apple-macos10.15

# Create universal binary
echo "Creating universal binary..."
lipo -create -output "$APP_NAME-universal" "$APP_NAME-arm64" "$APP_NAME-x86_64"

# Verify the universal binary
echo "Verifying universal binary..."
lipo -info "$APP_NAME-universal"

# Compress for distribution
echo "Compressing for distribution..."
zip -9 "$DOWNLOADS_DIR/$APP_NAME-universal.zip" "$APP_NAME-universal"

# Clean up temporary files
rm "$APP_NAME-arm64" "$APP_NAME-x86_64" "$APP_NAME-universal"

echo "Build complete! Universal binary created at: $DOWNLOADS_DIR/$APP_NAME-universal.zip"
echo "Compatible with macOS 10.15+ on both Intel and Apple Silicon Macs" 