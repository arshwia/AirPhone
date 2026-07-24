#!/usr/bin/env bash
set -euo pipefail

readonly APP_NAME="AirPhone"
readonly BIN_DIR="$HOME/.local/bin"
readonly CONFIG_DIR="$HOME/.config/airphone"
readonly APP_DIR="$HOME/.local/share/applications"
readonly ICON_DIR="$HOME/.local/share/icons"

mkdir -p "$BIN_DIR" "$CONFIG_DIR" "$APP_DIR" "$ICON_DIR"

cp airphone "$BIN_DIR/airphone"
chmod +x "$BIN_DIR/airphone"

if [[ ! -f "$CONFIG_DIR/config.conf" ]]; then
    cp config.conf "$CONFIG_DIR/config.conf"
fi

# Copy icon from assets folder
cp ../assets/airphone.png "$ICON_DIR/airphone.png"

sed \
    -e "s|__EXEC__|$BIN_DIR/airphone|g" \
    -e "s|__ICON__|$ICON_DIR/airphone.png|g" \
    airphone.desktop > "$APP_DIR/airphone.desktop"

update-desktop-database "$APP_DIR" 2>/dev/null || true

echo "✅ $APP_NAME installed successfully."
echo "You can now run it from the applications menu."