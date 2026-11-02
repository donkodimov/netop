#!/usr/bin/env bash
# Build build/Netop.app from the SwiftPM executable.
# A real .app bundle is required for notifications and other bundle-only macOS APIs.
#
#   scripts/bundle.sh [debug|release]   (default: debug)
set -euo pipefail
cd "$(dirname "$0")/.."

config="${1:-debug}"
swift build -c "$config" --product Netop
bin_dir="$(swift build -c "$config" --show-bin-path)"

app="build/Netop.app"
rm -rf "$app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cp "$bin_dir/Netop" "$app/Contents/MacOS/Netop"
cp Support/Info.plist "$app/Contents/Info.plist"
plutil -lint -s "$app/Contents/Info.plist"

# Ad-hoc signature: enough to run on this Mac. Developer ID signing + notarization
# (paid Apple Developer Program) is needed before giving the app to others.
codesign --force --sign - "$app"
codesign --verify "$app"
echo "built $app"
