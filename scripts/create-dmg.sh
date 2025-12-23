#!/bin/bash
# DMG creation script
# Creates DMG file for GitHub Releases
#
# Usage: ./scripts/create-dmg.sh [version]
# Example: ./scripts/create-dmg.sh 1.0.0

set -e  # Stop on error

# Configuration
APP_NAME="DispTog"
VERSION="${1:-1.0.0}"
BUILD_DIR="build"
DMG_DIR="$BUILD_DIR/dmg"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
APP_BUNDLE="$BUILD_DIR/${APP_NAME}.app"

echo "📦 Starting DMG creation: $DMG_NAME"

# Check if built app exists
if [ ! -d "$APP_BUNDLE" ]; then
    echo "❌ Error: $APP_BUNDLE not found"
    echo "   Please run 'make build' first"
    exit 1
fi

# Cleanup existing DMG directory
rm -rf "$DMG_DIR"
mkdir -p "$DMG_DIR"

# Create temporary directory for DMG
STAGING_DIR="$DMG_DIR/staging"
mkdir -p "$STAGING_DIR"

# Copy app
echo "  📋 Copying app..."
cp -R "$APP_BUNDLE" "$STAGING_DIR/"

# Create symbolic link to Applications (for drag & drop)
ln -s /Applications "$STAGING_DIR/Applications"

# Optional: Directory for background image
# mkdir -p "$STAGING_DIR/.background"

# Create DMG
echo "  💿 Creating DMG..."
hdiutil create \
    -volname "$APP_NAME" \
    -srcfolder "$STAGING_DIR" \
    -ov \
    -format UDZO \
    "$DMG_DIR/$DMG_NAME"

# Cleanup temporary directory
rm -rf "$STAGING_DIR"

# Display result
DMG_PATH="$DMG_DIR/$DMG_NAME"
DMG_SIZE=$(du -h "$DMG_PATH" | cut -f1)

echo ""
echo "✅ DMG creation complete!"
echo "   File: $DMG_PATH"
echo "   Size: $DMG_SIZE"
echo ""
echo "📤 To upload to GitHub Releases:"
echo "   gh release create v$VERSION $DMG_PATH --title \"v$VERSION\" --notes \"Release v$VERSION\""
