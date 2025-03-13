#!/bin/bash

# ───────────────────────────────────────────────────────────────────────────────
# DMG Creation Script for "Eldoria Chronicles"
# Extracts an existing Godot-built DMG, replaces the background, and repackages it.
# ───────────────────────────────────────────────────────────────────────────────

# ─── Configuration ─────────────────────────────────────────────────────────────

APP_NAME="Eldoria Chronicles"                   # Application name (without extension)
DMG_NAME="eldoria-chronicles-raw.dmg"           # Name of the existing Godot DMG (inside 'source' dir)
NEW_DMG_NAME="eldoria-chronicles-1.0.0-mac.dmg" # Name of the DMG that will be created (inside 'build' dir)
BACKGROUND_IMG="dmg-background.png"             # Background image for the new DMG (inside 'source' dir)
SOURCE_DIR="source"                             # Directory containing the original DMG
OUTPUT_DIR="build"                              # Output directory for the final DMG
TEMP_DIR="temp"                                 # Temporary directory for extracted app (will be deleted)
MOUNT_POINT="/Volumes/$APP_NAME"                # Mount point for the DMG (usually unchanged)

# ─── Dependency Check ─────────────────────────────────────────────────────────

if ! command -v create-dmg &>/dev/null; then
    if ! command -v brew &>/dev/null; then
        echo "❌ 'create-dmg' not found. Install Homebrew first. Exiting..."
        exit 1
    fi
    read -p "⚠️  'create-dmg' is not installed. Install now? (y/n) " -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "❌ 'create-dmg' is required. Exiting..."
        exit 1
    fi
    echo "📦 Installing 'create-dmg'..."
    BREW_OUTPUT=$(brew install create-dmg 2>&1)
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install 'create-dmg'. Details:"
        echo "$BREW_OUTPUT"
        exit 1
    fi
fi

# ─── Setup ─────────────────────────────────────────────────────────────────────

mkdir -p "$OUTPUT_DIR" "$TEMP_DIR"
rm -f "$OUTPUT_DIR/$NEW_DMG_NAME"
rm -rf "$TEMP_DIR/$APP_NAME.app"

# Validate required files exist
for file in "$SOURCE_DIR/$DMG_NAME" "$SOURCE_DIR/$BACKGROUND_IMG"; do
    if [ ! -f "$file" ]; then
        echo "❌ Error: Required file '$file' not found. Exiting..."
        exit 1
    fi
done

# ─── DMG Extraction ────────────────────────────────────────────────────────────

# Cleanup function to ensure the DMG is unmounted properly
cleanup() {
    if mount | grep -q "$MOUNT_POINT"; then
        echo "📤 Unmounting $MOUNT_POINT..."
        hdiutil detach "$MOUNT_POINT" -quiet
    fi
}

# Ensure cleanup runs on unexpected exit
trap cleanup EXIT

# Mount the DMG
echo "📀 Mounting '$DMG_NAME'..."
if ! MOUNT_OUTPUT=$(hdiutil attach "$SOURCE_DIR/$DMG_NAME" -nobrowse -quiet 2>&1); then
    echo "❌ Failed to mount DMG. Details:"
    echo "$MOUNT_OUTPUT"
    exit 1
fi

# Ensure the mount point is accessible
ATTEMPTS=5
while [ ! -d "$MOUNT_POINT" ] && [ "$ATTEMPTS" -gt 0 ]; do
    sleep 1
    ((ATTEMPTS--))
done

if [ ! -d "$MOUNT_POINT" ]; then
    echo "❌ Mount point did not appear. Unmounting and exiting..."
    cleanup
    exit 1
fi

# Validate the extracted .app exists
if [ ! -d "$MOUNT_POINT/$APP_NAME.app" ]; then
    echo "❌ Error: '$APP_NAME.app' not found inside DMG. Unmounting and exiting..."
    cleanup
    exit 1
fi

# Copy the app to the temporary directory
echo "📂 Copying '$APP_NAME.app' to temporary directory..."
cp -R "$MOUNT_POINT/$APP_NAME.app" "$TEMP_DIR/"

# Unmount the DMG
cleanup
echo "✅ Application extracted successfully."

# ─── DMG Creation ──────────────────────────────────────────────────────────────

echo "📦 Creating new DMG..."
CREATE_DMG_OUTPUT=$(create-dmg \
    --volname "$APP_NAME Installer" \
    --background "$SOURCE_DIR/$BACKGROUND_IMG" \
    --window-pos 200 120 \
    --window-size 600 420 \
    --icon-size 100 \
    --icon "$APP_NAME.app" 150 190 \
    --app-drop-link 450 190 \
    --hide-extension "$APP_NAME.app" \
    --format UDBZ \
    "$OUTPUT_DIR/$NEW_DMG_NAME" \
    "$TEMP_DIR" 2>&1)

if [ $? -ne 0 ]; then
    echo "❌ Failed to create DMG. Here's what went wrong:"
    echo "$CREATE_DMG_OUTPUT"
    exit 1
fi

# ─── Cleanup ───────────────────────────────────────────────────────────────────

rm -rf "$TEMP_DIR"
echo "🎉 DMG successfully created: '$OUTPUT_DIR/$NEW_DMG_NAME'"
