#!/bin/bash

set -e

APP_NAME="MiniTop"
DIST_DIR="dist"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"

echo "Building $APP_NAME..."

# Clean and create directories
rm -rf "$DIST_DIR"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Compile the Swift code
swiftc -o "$APP_BUNDLE/Contents/MacOS/$APP_NAME" main.swift -framework Cocoa -framework WebKit

# Copy Info.plist
cp Info.plist "$APP_BUNDLE/Contents/"

echo "Build complete! App created at: $APP_BUNDLE"
echo "To run: open $APP_BUNDLE" 