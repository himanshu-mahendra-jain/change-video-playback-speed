#!/usr/bin/env bash

set -euo pipefail

DIST_DIR="dist"

CHROMIUM_MANIFEST="manifest.json"
FIREFOX_MANIFEST="manifest-firefox.json"


# Check whether zip is installed.
if ! command -v zip >/dev/null 2>&1; then
    echo "Error: zip is not installed."
    echo
    echo "Install it using your system package manager:"
    echo
    echo "Debian/Ubuntu: sudo apt install zip"
    exit 1
fi


# Check required files and directories.
for path in \
    "$CHROMIUM_MANIFEST" \
    "$FIREFOX_MANIFEST" \
    "icons" \
    "options" \
    "src"
do
    if [ ! -e "$path" ]; then
        echo "Error: $path not found."
        exit 1
    fi
done


# Read a string field from a manifest file.
read_manifest_field() {
    local manifest="$1"
    local field="$2"

    sed -n \
        "s/.*\"$field\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" \
        "$manifest" \
        | head -n 1
}


# Convert an extension name into a filename-friendly slug.
make_slug() {
    printf '%s' "$1" \
        | tr '[:upper:]' '[:lower:]' \
        | sed 's/[^a-z0-9][^a-z0-9]*/-/g; s/^-//; s/-$//'
}


# Read Chromium manifest metadata.
CHROMIUM_NAME=$(read_manifest_field "$CHROMIUM_MANIFEST" "name")
CHROMIUM_VERSION=$(read_manifest_field "$CHROMIUM_MANIFEST" "version")


# Read Firefox manifest metadata.
FIREFOX_NAME=$(read_manifest_field "$FIREFOX_MANIFEST" "name")
FIREFOX_VERSION=$(read_manifest_field "$FIREFOX_MANIFEST" "version")


# Validate manifest metadata.
if [ -z "$CHROMIUM_NAME" ] || [ -z "$CHROMIUM_VERSION" ]; then
    echo "Error: Could not read name or version from $CHROMIUM_MANIFEST."
    exit 1
fi

if [ -z "$FIREFOX_NAME" ] || [ -z "$FIREFOX_VERSION" ]; then
    echo "Error: Could not read name or version from $FIREFOX_MANIFEST."
    exit 1
fi


# Generate filename-safe extension names.
CHROMIUM_SLUG=$(make_slug "$CHROMIUM_NAME")
FIREFOX_SLUG=$(make_slug "$FIREFOX_NAME")


# Define output filenames.
CHROME_ZIP="$DIST_DIR/${CHROMIUM_SLUG}-chrome-v${CHROMIUM_VERSION}.zip"
EDGE_ZIP="$DIST_DIR/${CHROMIUM_SLUG}-edge-v${CHROMIUM_VERSION}.zip"
FIREFOX_ZIP="$DIST_DIR/${FIREFOX_SLUG}-firefox-v${FIREFOX_VERSION}.zip"


# Define temporary staging directories.
CHROMIUM_STAGE="$DIST_DIR/.chromium"
FIREFOX_STAGE="$DIST_DIR/.firefox"


# Create a clean distribution directory.
rm -rf "$DIST_DIR"

mkdir -p \
    "$CHROMIUM_STAGE" \
    "$FIREFOX_STAGE"


# Prepare Chromium package files.
cp "$CHROMIUM_MANIFEST" "$CHROMIUM_STAGE/manifest.json"
cp -R "icons" "$CHROMIUM_STAGE/icons"

if [ ! -f "options/placeholder" ]; then
cp -R "options" "$CHROMIUM_STAGE/options"
fi

cp -R "src" "$CHROMIUM_STAGE/src"

# Prepare Firefox package files.
cp "$FIREFOX_MANIFEST" "$FIREFOX_STAGE/manifest.json"
cp -R "icons" "$FIREFOX_STAGE/icons"

if [ ! -f "options/placeholder" ]; then
cp -R "options" "$FIREFOX_STAGE/options"
fi

cp -R "src" "$FIREFOX_STAGE/src"

# Create Chrome package.
(
    cd "$CHROMIUM_STAGE"
    zip -qr "../$(basename "$CHROME_ZIP")" .
)


# Create Edge package.
(
    cd "$CHROMIUM_STAGE"
    zip -qr "../$(basename "$EDGE_ZIP")" .
)


# Create Firefox package.
(
    cd "$FIREFOX_STAGE"
    zip -qr "../$(basename "$FIREFOX_ZIP")" .
)


# Remove temporary staging directories.
rm -rf \
    "$CHROMIUM_STAGE" \
    "$FIREFOX_STAGE"


echo "Build complete:"
echo
echo "  $CHROME_ZIP"
echo "  $EDGE_ZIP"
echo "  $FIREFOX_ZIP"