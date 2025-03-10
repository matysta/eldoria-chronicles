#!/bin/bash

# ───────────────────────────────────────────────────────────────────────────────
# EXE Creation Script for "Eldoria Chronicles"
# Modifies the icon and version information of a Windows executable using 'rcedit'
# ───────────────────────────────────────────────────────────────────────────────

# ─── Configuration ─────────────────────────────────────────────────────────────

SOURCE_DIR="source"                             # Directory containing the original EXE
OUTPUT_DIR="build"                              # Output directory for the final EXE
EXE_NAME="eldoria-chronicles-raw.exe"           # Name of the original EXE file
NEW_EXE_NAME="eldoria-chronicles-1.0.0-win.exe" # Name of the modified EXE file
ICON_PATH="../assets/icons/icon-win.ico"        # Path to the icon file
RCEDIT_PATH="$SOURCE_DIR/rcedit-x64.exe"        # Path to 'rcedit.exe'

COMPANY_NAME="Matej Stastny"
DESCRIPTION="A 2D platformer built in Godot 4."
PRODUCT_NAME="Eldoria Chronicles"

# ─── Dependency Check ─────────────────────────────────────────────────────────

if ! command -v wine &>/dev/null; then
    echo "❌ 'wine' is not installed. Please install Wine to proceed. Exiting..."
    exit 1
fi

if [ ! -f "$RCEDIT_PATH" ]; then
    echo "❌ 'rcedit.exe' not found at '$RCEDIT_PATH'. Please download and place it in the source directory. Exiting..."
    exit 1
fi

# ─── Setup ─────────────────────────────────────────────────────────────────────

TEMP_DIR="$(mktemp -d)"

mkdir -p "$OUTPUT_DIR"
rm -f "$OUTPUT_DIR/$NEW_EXE_NAME"

# Validate required files exist
if [ ! -f "$SOURCE_DIR/$EXE_NAME" ]; then
    echo "❌ Error: Original EXE '$SOURCE_DIR/$EXE_NAME' not found. Exiting..."
    exit 1
fi

if [ ! -f "$ICON_PATH" ]; then
    echo "❌ Error: Icon file '$ICON_PATH' not found. Exiting..."
    exit 1
fi

# ─── Duplicate EXE to Temp Directory ───────────────────────────────────────────

echo "📦 Copying EXE to temporary directory..."
cp "$SOURCE_DIR/$EXE_NAME" "$TEMP_DIR/$EXE_NAME"

# ─── Path Conversion ───────────────────────────────────────────────────────────

# Convert paths to absolute paths
RCEDIT_ABS_PATH=$(realpath "$RCEDIT_PATH")
ICON_ABS_PATH=$(realpath "$ICON_PATH")

# Ensure rcedit path points to the EXE file
if [ ! -f "$RCEDIT_ABS_PATH" ]; then
    echo "❌ Error: rcedit executable not found at '$RCEDIT_ABS_PATH'. Exiting..."
    exit 1
fi

# Convert to Windows-compatible paths for Wine
RCEDIT_WIN_PATH=$(winepath -w "$RCEDIT_ABS_PATH")
ICON_WIN_PATH=$(winepath -w "$ICON_ABS_PATH")

# Debugging: Print the converted paths
echo "🔍 Converted Icon Path: $ICON_WIN_PATH"
echo "🔍 Converted rcedit Path: $RCEDIT_WIN_PATH"

# ─── Modify EXE ────────────────────────────────────────────────────────────────

echo "🛠️ Modifying EXE properties..."

WINE_OUTPUT=$(wine "$RCEDIT_WIN_PATH" "$TEMP_DIR/$EXE_NAME" \
    --set-icon "$ICON_WIN_PATH" \
    --set-version-string CompanyName "$COMPANY_NAME" \
    --set-version-string FileDescription "$DESCRIPTION" \
    --set-version-string ProductName "$PRODUCT_NAME" 2>&1)

if [ $? -ne 0 ]; then
    echo "❌ Error modifying EXE properties:"
    echo "$WINE_OUTPUT"
    exit 1
fi

if [[ "$1" == "--wine-output" ]]; then
    echo "Wine command output:"
    echo "$WINE_OUTPUT"
fi

# ─── Move Modified EXE to Build Directory ──────────────────────────────────────

echo "🚚 Moving modified EXE to build directory..."
mv "$TEMP_DIR/$EXE_NAME" "$OUTPUT_DIR/$NEW_EXE_NAME"

# ─── Cleanup ───────────────────────────────────────────────────────────────────

rm -rf "$TEMP_DIR"

echo "🎉 EXE successfully modified and placed in: '$OUTPUT_DIR/$NEW_EXE_NAME'"
diff -sq <(xxd "source/$EXE_NAME") <(xxd "build/$NEW_EXE_NAME")
